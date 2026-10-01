import 'dart:async';

import 'package:analytics_hub/analytics_hub.dart';
import 'package:test/test.dart';

class _TestProviderKey extends ProviderIdentifier {
  const _TestProviderKey({super.name});
}

const _providerKey = _TestProviderKey(name: 'test');

class _RecordingResolver implements EventResolver {
  final events = <ResolvedEvent>[];
  final contexts = <EventDispatchContext>[];

  @override
  Future<void> resolve(
    ResolvedEvent event, {
    required EventDispatchContext context,
  }) async {
    events.add(event);
    contexts.add(context);
  }
}

class _TestProvider extends AnalyticsProvider {
  _TestProvider({super.interceptors = const []})
      : super(identifier: _providerKey);

  final _resolver = _RecordingResolver();

  List<ResolvedEvent> get events => _resolver.events;

  List<EventDispatchContext> get contexts => _resolver.contexts;

  @override
  EventResolver get resolver => _resolver;
}

class _TestEvent extends Event {
  const _TestEvent(
    super.name, {
    this.props,
    this.ctx = const EventContext(),
    this.overrides,
  });

  final Map<String, Object?>? props;
  final EventContext ctx;
  final EventOverrides? overrides;

  @override
  Map<String, Object?>? get properties => props;

  @override
  EventContext get context => ctx;

  @override
  List<EventProvider> get providers => [
        EventProvider(_providerKey, overrides: overrides),
      ];
}

/// Plain metadata entry: must never reach provider properties.
final class _InternalContextEntry extends ContextEntry {
  const _InternalContextEntry(this.value);

  final String value;
}

/// Second metadata entry type used to verify composition across levels.
final class _EditorContextEntry extends ContextEntry {
  const _EditorContextEntry(this.tool);

  final String tool;
}

final class _FlowSourceContextEntry extends ContextEntry
    implements EventPropertiesContributor {
  const _FlowSourceContextEntry({required this.page, required this.element});

  final String page;
  final String element;

  @override
  Map<String, Object?> toEventProperties() => {
        'source_flow_page': page,
        'source_flow_element': element,
      };
}

class _ContextSpyInterceptor implements EventInterceptor {
  final contexts = <EventDispatchContext>[];
  final events = <ResolvedEvent>[];

  @override
  FutureOr<InterceptorResult> intercept({
    required ResolvedEvent event,
    required EventDispatchContext context,
    required NextEventInterceptor next,
  }) {
    contexts.add(context);
    events.add(event);
    return next(event, context);
  }
}

void main() {
  late _TestProvider provider;
  late AnalyticsHub hub;

  setUp(() {
    provider = _TestProvider();
    hub = AnalyticsHub(providers: [provider]);
  });

  group('AnalyticsHub.sendEvent without scope', () {
    test('sees only event context and keeps properties untouched', () async {
      await hub.sendEvent(const _TestEvent('event'));

      expect(provider.contexts.single.entries, isEmpty);
      expect(provider.events.single.context.entries, isEmpty);
      expect(provider.events.single.properties, isNull);
    });

    test('is not affected by scopes created from the hub', () async {
      hub.scoped(
        context: const EventContext().withEntry(
          const _InternalContextEntry('scoped'),
        ),
      );

      await hub.sendEvent(const _TestEvent('event', props: {'key': 'value'}));

      expect(provider.contexts.single.entries, isEmpty);
      expect(provider.events.single.properties, equals({'key': 'value'}));
    });
  });

  group('AnalyticsHub.scoped', () {
    test('single scope adds its context to the dispatch', () async {
      final scope = hub.scoped(
        context: const EventContext().withEntry(
          const _InternalContextEntry('a'),
        ),
      );

      await scope.sendEvent(const _TestEvent('event'));

      expect(
        provider.contexts.single.entry<_InternalContextEntry>()?.value,
        equals('a'),
      );
      expect(
        provider.events.single.context.entry<_InternalContextEntry>()?.value,
        equals('a'),
      );
      expect(provider.contexts.single.originalEvent.context.isEmpty, isTrue);
    });

    test('nested scopes combine outer, inner and event context', () async {
      final outer = hub.scoped(
        context: const EventContext().withEntry(
          const _InternalContextEntry('a'),
        ),
      );
      final inner = outer.scoped(
        context: const EventContext().withEntry(
          const _EditorContextEntry('b'),
        ),
      );

      await inner.sendEvent(
        _TestEvent(
          'event',
          ctx: const EventContext().withEntry(
            const _FlowSourceContextEntry(page: 'c', element: 'c'),
          ),
        ),
      );

      final context = provider.contexts.single;
      expect(context.entries, hasLength(3));
      expect(context.entry<_InternalContextEntry>()?.value, equals('a'));
      expect(context.entry<_EditorContextEntry>()?.tool, equals('b'));
      expect(context.entry<_FlowSourceContextEntry>()?.page, equals('c'));
    });

    test('precedence is outer < inner < event for the same entry type',
        () async {
      final outer = hub.scoped(
        context: const EventContext().withEntry(
          const _InternalContextEntry('outer'),
        ),
      );
      final inner = outer.scoped(
        context: const EventContext().withEntry(
          const _InternalContextEntry('inner'),
        ),
      );

      await inner.sendEvent(const _TestEvent('from_inner'));
      await inner.sendEvent(
        _TestEvent(
          'from_event',
          ctx: const EventContext().withEntry(
            const _InternalContextEntry('event'),
          ),
        ),
      );

      expect(
        provider.contexts
            .map((context) => context.entry<_InternalContextEntry>()?.value),
        equals(['inner', 'event']),
      );
    });

    test('creating a child scope does not mutate its parent', () async {
      final parent = hub.scoped(
        context: const EventContext().withEntry(
          const _InternalContextEntry('a'),
        ),
      );
      parent.scoped(
        context: const EventContext()
            .withEntry(const _InternalContextEntry('b'))
            .withEntry(const _EditorContextEntry('b')),
      );

      await parent.sendEvent(const _TestEvent('event'));

      final context = provider.contexts.single;
      expect(context.entries, hasLength(1));
      expect(context.entry<_InternalContextEntry>()?.value, equals('a'));
    });

    test('concurrent scopes stay isolated', () async {
      final scopeA = hub.scoped(
        context: const EventContext().withEntry(
          const _FlowSourceContextEntry(page: 'a', element: 'a'),
        ),
      );
      final scopeB = hub.scoped(
        context: const EventContext().withEntry(
          const _FlowSourceContextEntry(page: 'b', element: 'b'),
        ),
      );

      await Future.wait([
        scopeA.sendEvent(const _TestEvent('event_a')),
        scopeB.sendEvent(const _TestEvent('event_b')),
      ]);

      final pages = {
        for (final event in provider.events)
          event.name: event.properties?['source_flow_page'],
      };
      expect(pages, equals({'event_a': 'a', 'event_b': 'b'}));
    });
  });

  group('EventPropertiesContributor', () {
    test('plain context entry is visible in context but not in properties',
        () async {
      final scope = hub.scoped(
        context: const EventContext().withEntry(
          const _InternalContextEntry('internal'),
        ),
      );

      await scope.sendEvent(const _TestEvent('event', props: {'key': 'v'}));

      expect(
        provider.contexts.single.entry<_InternalContextEntry>()?.value,
        equals('internal'),
      );
      expect(provider.events.single.properties, equals({'key': 'v'}));
    });

    test('contributing entry adds its properties', () async {
      final scope = hub.scoped(
        context: const EventContext().withEntry(
          const _FlowSourceContextEntry(page: 'home', element: 'create_video'),
        ),
      );

      await scope.sendEvent(const _TestEvent('event'));

      expect(
        provider.events.single.properties,
        equals({
          'source_flow_page': 'home',
          'source_flow_element': 'create_video',
        }),
      );
    });

    test('contributed properties are merged with event properties', () async {
      final scope = hub.scoped(
        context: const EventContext().withEntry(
          const _FlowSourceContextEntry(page: 'home', element: 'create_video'),
        ),
      );

      await scope.sendEvent(const _TestEvent('event', props: {'model': 'veo'}));

      expect(
        provider.events.single.properties,
        equals({
          'model': 'veo',
          'source_flow_page': 'home',
          'source_flow_element': 'create_video',
        }),
      );
    });

    test('contributed properties win over colliding event properties',
        () async {
      final scope = hub.scoped(
        context: const EventContext().withEntry(
          const _FlowSourceContextEntry(page: 'home', element: 'create_video'),
        ),
      );

      await scope.sendEvent(
        const _TestEvent('event', props: {'source_flow_page': 'chat'}),
      );

      expect(
        provider.events.single.properties?['source_flow_page'],
        equals('home'),
      );
    });

    test('contributed properties are applied on top of provider overrides',
        () async {
      final scope = hub.scoped(
        context: const EventContext().withEntry(
          const _FlowSourceContextEntry(page: 'home', element: 'create_video'),
        ),
      );

      await scope.sendEvent(
        const _TestEvent(
          'event',
          props: {'model': 'veo'},
          overrides: EventOverrides(properties: {'engine': 'veo'}),
        ),
      );

      expect(
        provider.events.single.properties,
        equals({
          'engine': 'veo',
          'source_flow_page': 'home',
          'source_flow_element': 'create_video',
        }),
      );
    });

    test('event-level contributing entry works without a scope', () async {
      await hub.sendEvent(
        _TestEvent(
          'event',
          ctx: const EventContext().withEntry(
            const _FlowSourceContextEntry(page: 'home', element: 'create'),
          ),
        ),
      );

      expect(
        provider.events.single.properties,
        equals({'source_flow_page': 'home', 'source_flow_element': 'create'}),
      );
    });
  });

  group('pipeline access to effective context', () {
    test('hub interceptors, provider interceptors and resolver see it',
        () async {
      final hubSpy = _ContextSpyInterceptor();
      final providerSpy = _ContextSpyInterceptor();
      final provider = _TestProvider(interceptors: [providerSpy]);
      final hub = AnalyticsHub(providers: [provider], interceptors: [hubSpy]);

      await hub
          .scoped(
            context: const EventContext().withEntry(
              const _InternalContextEntry('a'),
            ),
          )
          .scoped(
            context: const EventContext().withEntry(
              const _EditorContextEntry('b'),
            ),
          )
          .sendEvent(const _TestEvent('event'));

      for (final context in [
        hubSpy.contexts.single,
        providerSpy.contexts.single,
        provider.contexts.single,
      ]) {
        expect(context.entry<_InternalContextEntry>()?.value, equals('a'));
        expect(context.entry<_EditorContextEntry>()?.tool, equals('b'));
      }
      expect(
        hubSpy.events.single.context.entry<_EditorContextEntry>()?.tool,
        equals('b'),
      );
    });

    test('hub interceptors see contributed properties', () async {
      final hubSpy = _ContextSpyInterceptor();
      final hub = AnalyticsHub(providers: [provider], interceptors: [hubSpy]);

      await hub
          .scoped(
            context: const EventContext().withEntry(
              const _FlowSourceContextEntry(page: 'home', element: 'create'),
            ),
          )
          .sendEvent(const _TestEvent('event'));

      expect(
        hubSpy.events.single.properties?['source_flow_page'],
        equals('home'),
      );
    });
  });

  test('end to end: nested scopes deliver contributed properties to provider',
      () async {
    final generation = hub.scoped(
      context: const EventContext().withEntry(
        const _FlowSourceContextEntry(page: 'home', element: 'create_video'),
      ),
    );
    final editor = generation.scoped(
      context: const EventContext().withEntry(
        const _EditorContextEntry('trim'),
      ),
    );

    await Future.wait([
      editor.sendEvent(
        const _TestEvent('generation_completed', props: {'model': 'veo'}),
      ),
      hub.sendEvent(const _TestEvent('other_event')),
    ]);

    final completed =
        provider.events.singleWhere((e) => e.name == 'generation_completed');
    expect(
      completed.properties,
      equals({
        'model': 'veo',
        'source_flow_page': 'home',
        'source_flow_element': 'create_video',
      }),
    );
    expect(completed.context.entry<_EditorContextEntry>()?.tool, 'trim');

    final other = provider.events.singleWhere((e) => e.name == 'other_event');
    expect(other.properties, isNull);
    expect(other.context.entries, isEmpty);
  });
}
