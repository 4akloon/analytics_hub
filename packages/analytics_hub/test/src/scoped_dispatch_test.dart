import 'dart:async';

import 'package:analytics_hub/analytics_hub.dart';
import 'package:test/test.dart';

class _Key extends ProviderIdentifier {
  const _Key() : super(name: 'test');
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
  _Provider({super.interceptors = const []})
      : resolver = _Resolver(),
        super(identifier: const _Key());

  @override
  final _Resolver resolver;
}

class _Event extends Event {
  _Event(super.name, {this.props, this.ctx = const EventContext()});

  final Map<String, Object?>? props;
  final EventContext ctx;

  @override
  Map<String, Object?>? get properties => props;

  @override
  EventContext get context => ctx;

  @override
  List<EventProvider> get providers => const [EventProvider(_Key())];
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
    order.add(name);
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

      await hub.sendEvent(_Event('click'), scope: scope);

      expect(order, equals(['root', 'leaf', 'hub', 'provider']));
      expect(provider.resolver.events, hasLength(1));
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

      expect(order, equals(['a', 'b']));
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

    test('properties and context are snapshotted when sendEvent is called',
        () async {
      final provider = _Provider();
      final hub = AnalyticsHub(providers: [provider]);
      final props = <String, Object?>{'step': 1};
      final event = _Event('click', props: props);

      final pending = hub.sendEvent(event);
      props['step'] = 2;
      await pending;

      expect(provider.resolver.events.single.properties, equals({'step': 1}));
    });

    test('every provider dispatch of one send shares a correlation id',
        () async {
      final a = _Provider();
      final hub = AnalyticsHub(providers: [a]);

      await hub.sendEvent(_Event('click'));
      await hub.sendEvent(_Event('click'));

      final ids = a.resolver.contexts.map((c) => c.correlationId).toList();
      expect(ids[0], isNot(equals(ids[1])));
    });
  });
}
