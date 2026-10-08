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
  _Resolver({this.throwing = false});

  final bool throwing;
  final List<ResolvedEvent> events = [];

  @override
  Future<void> resolve(
    ResolvedEvent event, {
    required EventDispatchContext context,
  }) async {
    if (throwing) throw StateError('backend down');
    events.add(event);
  }
}

class _Provider extends AnalyticsProvider {
  _Provider({super.interceptors = const [], bool throwing = false})
      : resolver = _Resolver(throwing: throwing),
        super(identifier: const _Key());

  @override
  final _Resolver resolver;
}

class _Event extends Event {
  _Event(super.name, {this.props, this.overrides});

  final Map<String, Object?>? props;
  final EventOverrides? overrides;

  @override
  Map<String, Object?>? get properties => props;

  @override
  List<EventProvider> get providers => [
        EventProvider(const _Key(), overrides: overrides),
      ];
}

final class _Add implements EventInterceptor {
  const _Add(this.name, this.values);

  @override
  final String name;
  final Map<String, Object?> values;

  @override
  FutureOr<InterceptorResult> intercept({
    required ResolvedEvent event,
    required EventDispatchContext context,
    required NextEventInterceptor next,
  }) =>
      next(event.withDefaults(values), context);
}

final class _Drop implements EventInterceptor {
  const _Drop();

  @override
  String get name => 'drop';

  @override
  FutureOr<InterceptorResult> intercept({
    required ResolvedEvent event,
    required EventDispatchContext context,
    required NextEventInterceptor next,
  }) =>
      InterceptorResult.drop(event, context: context);
}

final class _Throw implements EventInterceptor {
  const _Throw();

  @override
  String get name => 'boom';

  @override
  FutureOr<InterceptorResult> intercept({
    required ResolvedEvent event,
    required EventDispatchContext context,
    required NextEventInterceptor next,
  }) =>
      throw StateError('boom');
}

final class _AppendContext implements EventInterceptor {
  const _AppendContext();

  @override
  String get name => 'append_context';

  @override
  FutureOr<InterceptorResult> intercept({
    required ResolvedEvent event,
    required EventDispatchContext context,
    required NextEventInterceptor next,
  }) {
    final added = event.context.withEntry(
      const _Page('appended'),
      source: 'interceptor:append_context',
    );
    return next(
      event.copyWith(context: added),
      context.copyWith(context: added),
    );
  }
}

final class _Sink implements TraceSink {
  final List<DispatchTrace> traces = [];

  @override
  void onTrace(DispatchTrace trace) => traces.add(trace);
}

final class _ThrowingSink implements TraceSink {
  @override
  void onTrace(DispatchTrace trace) => throw StateError('sink down');
}

void main() {
  group('DispatchTrace', () {
    test('records every stage in order with its diff', () async {
      final sink = _Sink();
      final provider = _Provider(
        interceptors: const [
          _Add('provider_add', {'p': 1}),
        ],
      );
      final hub = AnalyticsHub(
        providers: [provider],
        interceptors: const [
          _Add('hub_add', {'h': 1}),
        ],
        traceSinks: [sink],
      );
      final scope = AnalyticsScope(
        name: 'home',
        context: const EventContext().withEntry(const _Page('home')),
        interceptors: const [
          _Add('scope_add', {'s': 1}),
        ],
      );

      await hub.sendEvent(
        _Event(
          'click',
          props: {'e': 1},
          overrides: const EventOverrides(name: 'Click'),
        ),
        scope: scope,
      );

      final trace = sink.traces.single;
      expect(trace.eventName, equals('click'));
      expect(trace.provider, equals(const _Key()));
      expect(trace.outcome, isA<DispatchSent>());
      expect(
        trace.stages.map((s) => s.name),
        equals([
          'scope:home',
          'interceptor:scope_add',
          'overrides',
          'interceptor:hub_add',
          'interceptor:provider_add',
          'resolver:test',
        ]),
      );
      expect(
        trace.stages.map((s) => s.kind),
        equals([
          StageKind.scope,
          StageKind.scopeInterceptor,
          StageKind.overrides,
          StageKind.hubInterceptor,
          StageKind.providerInterceptor,
          StageKind.resolver,
        ]),
      );
      expect(trace.stages[0].contextAdded.single.source, equals('scope:home'));
      expect(trace.stages[1].properties.added, equals({'s': 1}));
      expect(trace.stages[2].nameBefore, equals('click'));
      expect(trace.stages[2].nameAfter, equals('Click'));
      expect(trace.stages[3].properties.added, equals({'h': 1}));
      expect(trace.stages[4].properties.added, equals({'p': 1}));
      expect(trace.stages[5].isNoop, isTrue);
    });

    test('records context an interceptor appends', () async {
      final sink = _Sink();
      final hub = AnalyticsHub(
        providers: [_Provider()],
        interceptors: const [_AppendContext()],
        traceSinks: [sink],
      );

      await hub.sendEvent(_Event('click'));

      final stage = sink.traces.single.stages.firstWhere(
        (s) => s.name == 'interceptor:append_context',
      );
      expect(
        stage.contextAdded.single.source,
        equals('interceptor:append_context'),
      );
    });

    test('marks the dropping stage and the outcome', () async {
      final sink = _Sink();
      final provider = _Provider();
      final hub = AnalyticsHub(
        providers: [provider],
        interceptors: const [
          _Drop(),
          _Add('after', {'x': 1}),
        ],
        traceSinks: [sink],
      );

      await hub.sendEvent(_Event('click'));

      final trace = sink.traces.single;
      expect(trace.outcome, isA<DispatchDropped>());
      expect(
        (trace.outcome as DispatchDropped).stage,
        equals('interceptor:drop'),
      );
      expect(trace.stages.last.name, equals('interceptor:drop'));
      expect(trace.stages.last.dropped, isTrue);
      expect(provider.resolver.events, isEmpty);
    });

    test('records a throwing interceptor and rethrows', () async {
      final sink = _Sink();
      final hub = AnalyticsHub(
        providers: [_Provider()],
        interceptors: const [_Throw()],
        traceSinks: [sink],
      );

      await expectLater(hub.sendEvent(_Event('click')), throwsStateError);

      final trace = sink.traces.single;
      expect(trace.outcome, isA<DispatchFailed>());
      expect(
        (trace.outcome as DispatchFailed).stage,
        equals('interceptor:boom'),
      );
      expect(trace.stages.last.error, isStateError);
    });

    test('records a throwing resolver', () async {
      final sink = _Sink();
      final hub = AnalyticsHub(
        providers: [_Provider(throwing: true)],
        traceSinks: [sink],
      );

      await expectLater(hub.sendEvent(_Event('click')), throwsStateError);

      final trace = sink.traces.single;
      expect((trace.outcome as DispatchFailed).stage, equals('resolver:test'));
    });

    test('emits one trace per targeted provider sharing the correlation id',
        () async {
      final sink = _Sink();
      final hub = AnalyticsHub(providers: [_Provider()], traceSinks: [sink]);

      await hub.sendEvent(_Event('click'));
      await hub.sendEvent(_Event('click'));

      expect(sink.traces, hasLength(2));
      expect(
        sink.traces[0].correlationId,
        isNot(equals(sink.traces[1].correlationId)),
      );
    });

    test('a throwing sink does not break the dispatch or later sinks',
        () async {
      final sink = _Sink();
      final provider = _Provider();
      final hub = AnalyticsHub(
        providers: [provider],
        traceSinks: [_ThrowingSink(), sink],
      );

      await hub.sendEvent(_Event('click'));

      expect(provider.resolver.events, hasLength(1));
      expect(sink.traces, hasLength(1));
    });

    test('with no sinks interceptors are not wrapped', () async {
      final seen = <EventInterceptor>[];
      final probe = _ProbeExecutor(seen);
      const interceptor = _Add('hub_add', {'h': 1});
      final dispatcher = EventDispatcher(
        hubInterceptors: [interceptor],
        contextBuilder: const EventDispatchContextBuilder(),
        chainExecutor: probe,
      );

      await dispatcher.dispatch(
        snapshot: EventSnapshot.of(_Event('click')),
        target: DispatchTarget(
          eventProvider: const EventProvider(_Key()),
          provider: _Provider(),
        ),
        correlationId: 'c',
      );

      expect(seen.single, same(interceptor));
    });
  });
}

final class _ProbeExecutor extends InterceptorChainExecutor {
  const _ProbeExecutor(this.seen);

  final List<EventInterceptor> seen;

  @override
  Future<InterceptorResult> execute({
    required List<EventInterceptor> interceptors,
    required ResolvedEvent event,
    required EventDispatchContext context,
    required TerminalDispatch terminal,
  }) {
    seen.addAll(interceptors);
    return super.execute(
      interceptors: interceptors,
      event: event,
      context: context,
      terminal: terminal,
    );
  }
}
