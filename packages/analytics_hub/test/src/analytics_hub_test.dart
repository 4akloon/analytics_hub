import 'dart:async';

import 'package:analytics_hub/analytics_hub.dart';
import 'package:test/test.dart';

// Test provider and resolver
class TestProviderKey extends ProviderIdentifier {
  const TestProviderKey({super.name});
}

class TestEventResolver implements EventResolver {
  TestEventResolver(this.recorder, this.contextRecorder);

  final List<ResolvedEvent> recorder;
  final List<EventDispatchContext> contextRecorder;

  @override
  Future<void> resolve(
    ResolvedEvent event, {
    required EventDispatchContext context,
  }) async {
    recorder.add(event);
    contextRecorder.add(context);
  }
}

class TestProvider extends AnalytycsProvider {
  TestProvider({
    required super.identifier,
    super.interceptors = const [],
    List<ResolvedEvent>? recorder,
    List<EventDispatchContext>? contextRecorder,
  }) : _resolver = TestEventResolver(recorder ?? [], contextRecorder ?? []);

  final TestEventResolver _resolver;

  @override
  EventResolver get resolver => _resolver;

  var _initialized = false;
  Session? _session;
  var _disposed = false;
  var _flushed = false;

  bool get initialized => _initialized;
  Session? get session => _session;
  bool get disposed => _disposed;
  bool get flushed => _flushed;

  @override
  Future<void> initialize() async {
    _initialized = true;
  }

  @override
  Future<void> setSession(Session? session) async {
    _session = session;
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
  }

  @override
  Future<void> flush() async {
    _flushed = true;
  }
}

class TestLogEvent extends Event {
  const TestLogEvent(
    super.name, {
    this.props,
    this.ctx = const EventContext(),
  });

  final Map<String, Object?>? props;
  final EventContext ctx;

  @override
  Map<String, Object?>? get properties => props;

  @override
  EventContext get context => ctx;

  @override
  List<EventProvider> get providers => [
        const EventProvider(TestProviderKey(name: 'test')),
      ];
}

void main() {
  group('AnalyticsHub', () {
    late StreamController<Session?> sessionController;

    setUp(() {
      sessionController = StreamController<Session?>.broadcast();
    });

    tearDown(() {
      sessionController.close();
    });

    HubSessionDelegate createSessionDelegate({
      Session? initialSession,
    }) {
      return _TestSessionDelegate(
        sessionController.stream,
        initialSession: initialSession,
      );
    }

    test('initialize calls providers initialize and setSession', () async {
      final recorder = <ResolvedEvent>[];
      final contextRecorder = <EventDispatchContext>[];
      final provider = TestProvider(
        identifier: const TestProviderKey(name: 'test'),
        recorder: recorder,
        contextRecorder: contextRecorder,
      );
      const session = Session(id: 'user-123');
      final hub = AnalyticsHub(
        sessionDelegate: createSessionDelegate(initialSession: session),
        providers: [provider],
      );

      await hub.initialize();

      expect(provider.initialized, isTrue);
      expect(provider.session, equals(session));
      await hub.dispose();
    });

    test('initialize works without sessionDelegate', () async {
      final provider =
          TestProvider(identifier: const TestProviderKey(name: 'test'));
      final hub = AnalyticsHub(
        providers: [provider],
      );

      await hub.initialize();

      expect(provider.initialized, isTrue);
      expect(provider.session, isNull);
      await hub.dispose();
    });

    test('sendEvent resolves event with correct provider', () async {
      final recorder = <ResolvedEvent>[];
      final contextRecorder = <EventDispatchContext>[];
      final provider = TestProvider(
        identifier: const TestProviderKey(name: 'test'),
        recorder: recorder,
        contextRecorder: contextRecorder,
      );
      final hub = AnalyticsHub(
        sessionDelegate: createSessionDelegate(),
        providers: [provider],
      );
      await hub.initialize();

      const event = TestLogEvent('test_event', props: {'key': 'value'});
      await hub.sendEvent(event);

      expect(recorder, hasLength(1));
      expect(recorder.first.name, equals('test_event'));
      expect(recorder.first.properties, equals({'key': 'value'}));
      expect(contextRecorder, hasLength(1));
      expect(contextRecorder.first.originalEvent, equals(event));
      expect(contextRecorder.first.providerIdentifier.name, equals('test'));
      await hub.dispose();
    });

    test('sendEvent applies provider overrides before resolver', () async {
      final recorder = <ResolvedEvent>[];
      final provider = TestProvider(
        identifier: const TestProviderKey(name: 'test'),
        recorder: recorder,
      );
      final hub = AnalyticsHub(
        sessionDelegate: createSessionDelegate(),
        providers: [provider],
      );
      await hub.initialize();

      final event = _OverriddenProviderEvent(
        'test_event',
        const TestProviderKey(name: 'test'),
      );
      await hub.sendEvent(event);

      expect(recorder, hasLength(1));
      expect(recorder.first.name, equals('test_event_overridden'));
      expect(
        recorder.first.properties,
        equals({'key_overridden': 'value_overridden'}),
      );
      await hub.dispose();
    });

    test('global and provider interceptors run in order', () async {
      final order = <String>[];
      final recorder = <ResolvedEvent>[];
      final provider = TestProvider(
        identifier: const TestProviderKey(name: 'test'),
        recorder: recorder,
        interceptors: [
          _SpyInterceptor('provider', order),
        ],
      );
      final hub = AnalyticsHub(
        sessionDelegate: createSessionDelegate(),
        providers: [provider],
        interceptors: [
          _SpyInterceptor('global', order),
        ],
      );
      await hub.initialize();

      await hub.sendEvent(const TestLogEvent('test_event'));

      expect(
        order,
        equals([
          'global-before',
          'provider-before',
          'provider-after',
          'global-after',
        ]),
      );
      expect(recorder, hasLength(1));
      await hub.dispose();
    });

    test('interceptor can mutate event name and read typed context', () async {
      final recorder = <ResolvedEvent>[];
      final contextRecorder = <EventDispatchContext>[];
      final provider = TestProvider(
        identifier: const TestProviderKey(name: 'test'),
        recorder: recorder,
        contextRecorder: contextRecorder,
      );
      final hub = AnalyticsHub(
        sessionDelegate: createSessionDelegate(
          initialSession: const Session(id: 'user-123'),
        ),
        providers: [provider],
        interceptors: [
          _RenameWithContextInterceptor(),
        ],
      );
      await hub.initialize();

      await hub.sendEvent(
        TestLogEvent(
          'test_event',
          ctx: const EventContext().withEntry(
            const _SourceContextEntry('mobile'),
          ),
        ),
      );

      expect(recorder.single.name, equals('test_event_mobile'));
      expect(contextRecorder.single.correlationId, isNotEmpty);
      await hub.dispose();
    });

    test('interceptor can drop event before resolver', () async {
      final recorder = <ResolvedEvent>[];
      final provider = TestProvider(
        identifier: const TestProviderKey(name: 'test'),
        recorder: recorder,
      );
      final hub = AnalyticsHub(
        sessionDelegate: createSessionDelegate(),
        providers: [provider],
        interceptors: [
          _DropInterceptor(),
        ],
      );
      await hub.initialize();

      await hub.sendEvent(const TestLogEvent('test_event'));

      expect(recorder, isEmpty);
      await hub.dispose();
    });

    test('context contains event metadata', () async {
      final contextRecorder = <EventDispatchContext>[];
      final provider = TestProvider(
        identifier: const TestProviderKey(name: 'test'),
        contextRecorder: contextRecorder,
      );
      final hub = AnalyticsHub(
        sessionDelegate: createSessionDelegate(),
        providers: [provider],
      );
      await hub.initialize();

      await hub.sendEvent(
        TestLogEvent(
          'test_event',
          ctx: const EventContext().withEntry(
            const _SourceContextEntry('mobile'),
          ),
        ),
      );

      final context = contextRecorder.single;
      expect(
        context.entry<_SourceContextEntry>()?.source,
        equals('mobile'),
      );
      await hub.dispose();
    });

    test('context does not include provider metadata entries', () async {
      final contextRecorder = <EventDispatchContext>[];
      final provider = TestProvider(
        identifier: const TestProviderKey(name: 'test'),
        contextRecorder: contextRecorder,
      );
      final hub = AnalyticsHub(
        sessionDelegate: createSessionDelegate(),
        providers: [provider],
      );
      await hub.initialize();

      await hub.sendEvent(
        TestLogEvent(
          'test_event',
          ctx: const EventContext().withEntry(
            const _SourceContextEntry('mobile'),
          ),
        ),
      );

      final context = contextRecorder.single;
      expect(context.entry<_SourceContextEntry>()?.source, equals('mobile'));
      expect(context.entries, hasLength(1));
      await hub.dispose();
    });

    test('flush calls provider flush', () async {
      final provider = TestProvider(
        identifier: const TestProviderKey(name: 'test'),
      );
      final hub = AnalyticsHub(
        sessionDelegate: createSessionDelegate(),
        providers: [provider],
      );
      await hub.initialize();

      await hub.flush();

      expect(provider.flushed, isTrue);
      await hub.dispose();
    });

    test('sendEvent throws when provider not found', () async {
      const otherKey = TestProviderKey(name: 'other');
      final event = _UnknownProviderLogEvent('event', otherKey);
      final hub = AnalyticsHub(
        sessionDelegate: createSessionDelegate(),
        providers: [
          TestProvider(identifier: const TestProviderKey(name: 'test')),
        ],
      );
      await hub.initialize();

      expect(
        () => hub.sendEvent(event),
        throwsA(isA<AnalyticsProviderNotFoundException>()),
      );
      expect(
        () => hub.sendEvent(event),
        throwsA(
          predicate<AnalyticsProviderNotFoundException>(
            (e) => e.key.name == 'other',
          ),
        ),
      );
      await hub.dispose();
    });

    test('dispose cancels subscription and disposes providers', () async {
      final provider =
          TestProvider(identifier: const TestProviderKey(name: 'test'));
      final hub = AnalyticsHub(
        sessionDelegate: createSessionDelegate(),
        providers: [provider],
      );
      await hub.initialize();

      await hub.dispose();

      expect(provider.disposed, isTrue);
    });

    test('session stream changes trigger setSession on providers', () async {
      final provider =
          TestProvider(identifier: const TestProviderKey(name: 'test'));
      final hub = AnalyticsHub(
        sessionDelegate: createSessionDelegate(),
        providers: [provider],
      );
      await hub.initialize();

      const newSession = Session(id: 'user-456');
      sessionController.add(newSession);
      await Future<void>.delayed(Duration.zero);

      expect(provider.session, equals(newSession));
      await hub.dispose();
    });
  });

  group('AnalyticsProviderNotFoundException', () {
    test('toString contains key', () {
      const key = TestProviderKey(name: 'missing');
      const exception = AnalyticsProviderNotFoundException(key);
      expect(exception.toString(), contains('missing'));
      expect(exception.key, equals(key));
    });
  });
}

class _TestSessionDelegate implements HubSessionDelegate {
  _TestSessionDelegate(this._stream, {this.initialSession});

  final Stream<Session?> _stream;
  final Session? initialSession;

  @override
  Future<Session?> getSession() async => initialSession;

  @override
  Stream<Session?> get sessionStream => _stream;
}

class _UnknownProviderLogEvent extends Event {
  _UnknownProviderLogEvent(super.name, this.key);

  final TestProviderKey key;

  @override
  List<EventProvider> get providers => [
        EventProvider(key),
      ];
}

class _OverriddenProviderEvent extends Event {
  _OverriddenProviderEvent(super.name, this.key);

  final TestProviderKey key;

  @override
  Map<String, Object?>? get properties => const {'key': 'value'};

  @override
  List<EventProvider> get providers => [
        EventProvider(
          key,
          overrides: const EventOverrides(
            name: 'test_event_overridden',
            properties: {'key_overridden': 'value_overridden'},
          ),
        ),
      ];
}

class _SpyInterceptor implements EventInterceptor {
  _SpyInterceptor(this.name, this.order);

  final String name;
  final List<String> order;

  @override
  FutureOr<InterceptorResult> intercept({
    required ResolvedEvent event,
    required EventDispatchContext context,
    required NextEventInterceptor next,
  }) async {
    order.add('$name-before');
    final result = await next(event, context);
    order.add('$name-after');
    return result;
  }
}

class _DropInterceptor implements EventInterceptor {
  @override
  FutureOr<InterceptorResult> intercept({
    required ResolvedEvent event,
    required EventDispatchContext context,
    required NextEventInterceptor next,
  }) {
    return InterceptorResult.drop(event, context: context);
  }
}

class _RenameWithContextInterceptor implements EventInterceptor {
  @override
  FutureOr<InterceptorResult> intercept({
    required ResolvedEvent event,
    required EventDispatchContext context,
    required NextEventInterceptor next,
  }) {
    final source = event.context.entry<_SourceContextEntry>()?.source;
    final renamed =
        event.copyWith(name: '${event.name}_${source ?? 'unknown'}');
    return next(renamed, context);
  }
}

final class _SourceContextEntry extends ContextEntry {
  const _SourceContextEntry(this.source);

  final String source;
}
