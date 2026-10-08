import 'dart:async';

import 'package:analytics_hub/analytics_hub.dart';
import 'package:test/test.dart';

class _Key extends ProviderIdentifier {
  const _Key() : super(name: 'test');
}

class _OtherKey extends ProviderIdentifier {
  const _OtherKey() : super(name: 'other');
}

final class _Page extends ContextEntry {
  const _Page(this.name);

  final String name;
}

class _Resolver implements EventResolver {
  final List<ResolvedEvent> events = [];
  final List<EventDispatchContext> contexts = [];

  @override
  Future<void> resolve(
    ResolvedEvent event, {
    required EventDispatchContext context,
  }) async {
    events.add(event);
    contexts.add(context);
  }
}

class _Provider extends AnalyticsProvider {
  _Provider({
    super.identifier = const _Key(),
    super.interceptors = const [],
  }) : resolver = _Resolver();

  @override
  final _Resolver resolver;
}

class _Event extends Event {
  _Event(
    super.name, {
    this.props,
    this.ctx = const EventContext(),
    this.overrides,
    this.keys = const [_Key()],
  });

  final Map<String, Object?>? props;
  final EventContext ctx;
  final EventOverrides? overrides;
  final List<ProviderIdentifier> keys;

  @override
  Map<String, Object?>? get properties => props;

  @override
  EventContext get context => ctx;

  @override
  List<EventProvider> get providers => [
        for (final key in keys) EventProvider(key, overrides: overrides),
      ];
}

class _MutableEvent extends Event {
  _MutableEvent(
    super.name, {
    required this.currentProps,
    required this.currentContext,
    required this.currentProviders,
  });

  Map<String, Object?> currentProps;
  EventContext currentContext;
  List<EventProvider> currentProviders;

  @override
  Map<String, Object?>? get properties => currentProps;

  @override
  EventContext get context => currentContext;

  @override
  List<EventProvider> get providers => currentProviders;
}

final class _Spy implements EventInterceptor {
  _Spy(this.name, this.order);

  @override
  final String name;
  final List<String> order;

  @override
  FutureOr<InterceptorResult> intercept({
    required ResolvedEvent event,
    required EventDispatchContext context,
    required NextEventInterceptor next,
  }) {
    order.add('$name:${event.name}');
    return next(event, context);
  }
}

final class _SourceAppend implements EventInterceptor {
  const _SourceAppend();

  @override
  String get name => 'source';

  @override
  FutureOr<InterceptorResult> intercept({
    required ResolvedEvent event,
    required EventDispatchContext context,
    required NextEventInterceptor next,
  }) {
    final page = context.entry<_Page>()?.name;
    return next(event.withDefaults({'source_page': page}), context);
  }
}

void main() {
  group('scoped dispatch', () {
    test('scope context precedes the event context, nearest wins', () async {
      final provider = _Provider();
      final hub = AnalyticsHub(providers: [provider]);
      final scope = AnalyticsScope(
        name: 'home',
        context: const EventContext().withEntry(const _Page('home')),
      ).child(
        name: 'builder',
        context: const EventContext().withEntry(const _Page('builder')),
      );

      await ScopedAnalytics(hub, scope).sendEvent(
        _Event(
          'click',
          ctx: const EventContext().withEntry(const _Page('event')),
        ),
      );

      final context = provider.resolver.contexts.single.context;
      expect(
        context.records.map((r) => r.source),
        equals(['scope:home', 'scope:builder', 'event']),
      );
      expect(context.entry<_Page>()?.name, equals('event'));
      expect(
        provider.resolver.events.single.context.records,
        equals(context.records),
      );
    });

    test('stages run scope → overrides → hub → provider → resolver', () async {
      final order = <String>[];
      final provider = _Provider(interceptors: [_Spy('provider', order)]);
      final hub = AnalyticsHub(
        providers: [provider],
        interceptors: [_Spy('hub', order)],
      );
      final scope = AnalyticsScope(
        name: 'root',
        interceptors: [_Spy('root', order)],
      ).child(name: 'leaf', interceptors: [_Spy('leaf', order)]);

      await hub.sendEvent(
        _Event(
          'click',
          overrides: const EventOverrides(name: 'click_overridden'),
        ),
        scope: scope,
      );

      expect(
        order,
        equals([
          'root:click',
          'leaf:click',
          'hub:click_overridden',
          'provider:click_overridden',
        ]),
      );
      expect(provider.resolver.events.single.name, equals('click_overridden'));
    });

    test('scope interceptors see the scope context and run before overrides',
        () async {
      final provider = _Provider();
      final hub = AnalyticsHub(providers: [provider]);
      final scope = AnalyticsScope(
        name: 'home',
        context: const EventContext().withEntry(const _Page('home')),
        interceptors: const [_SourceAppend()],
      );

      await ScopedAnalytics(hub, scope)
          .sendEvent(_Event('click', props: {'a': 1}));

      expect(
        provider.resolver.events.single.properties,
        equals({'a': 1, 'source_page': 'home'}),
      );
    });

    test('a scope interceptor never sees events of a sibling scope', () async {
      final order = <String>[];
      final provider = _Provider();
      final hub = AnalyticsHub(providers: [provider]);
      final root = AnalyticsScope(name: 'root');
      final a = root.child(name: 'a', interceptors: [_Spy('a', order)]);
      final b = root.child(name: 'b', interceptors: [_Spy('b', order)]);

      await ScopedAnalytics(hub, a).sendEvent(_Event('click'));
      await ScopedAnalytics(hub, b).sendEvent(_Event('click'));

      expect(order, equals(['a:click', 'b:click']));
    });

    test('sendEvent without a scope behaves as before', () async {
      final provider = _Provider();
      final hub = AnalyticsHub(providers: [provider]);

      await hub.sendEvent(
        _Event(
          'click',
          ctx: const EventContext().withEntry(const _Page('event')),
        ),
      );

      final context = provider.resolver.contexts.single.context;
      expect(context.records.map((r) => r.source), equals(['event']));
    });

    test('ScopedAnalytics.child nests the scope', () async {
      final provider = _Provider();
      final hub = AnalyticsHub(providers: [provider]);
      final analytics = ScopedAnalytics(hub, AnalyticsScope(name: 'home'))
          .child(name: 'create');

      expect(
        analytics.scope.chain.map((s) => s.name),
        equals(['home', 'create']),
      );
      await analytics.sendEvent(_Event('click'));
      expect(provider.resolver.events, hasLength(1));
    });

    test(
        'name, properties, context and providers are snapshotted when sendEvent is called',
        () async {
      final provider = _Provider();
      final hub = AnalyticsHub(providers: [provider]);
      final event = _MutableEvent(
        'click',
        currentProps: {'step': 1},
        currentContext: const EventContext().withEntry(const _Page('original')),
        currentProviders: const [EventProvider(_Key())],
      );

      final pending = hub.sendEvent(event);
      event.currentProps['step'] = 2;
      event
        ..currentProps = {'step': 3}
        ..currentContext =
            const EventContext().withEntry(const _Page('changed'))
        ..currentProviders = const [];
      await pending;

      expect(provider.resolver.events, hasLength(1));
      final resolved = provider.resolver.events.single;
      expect(resolved.name, equals('click'));
      expect(resolved.properties, equals({'step': 1}));
      expect(resolved.context.entry<_Page>()?.name, equals('original'));
    });

    test('every provider dispatch of one send shares a correlation id',
        () async {
      final first = _Provider();
      final second = _Provider(identifier: const _OtherKey());
      final hub = AnalyticsHub(providers: [first, second]);

      await hub.sendEvent(_Event('click', keys: const [_Key(), _OtherKey()]));

      expect(
        first.resolver.contexts.single.correlationId,
        equals(second.resolver.contexts.single.correlationId),
      );
    });

    test('two sends get different correlation ids', () async {
      final provider = _Provider();
      final hub = AnalyticsHub(providers: [provider]);

      await hub.sendEvent(_Event('click'));
      await hub.sendEvent(_Event('click'));

      final ids =
          provider.resolver.contexts.map((c) => c.correlationId).toList();
      expect(ids[0], isNot(equals(ids[1])));
    });
  });
}
