import 'dart:async';

import 'package:analytics_hub/analytics_hub.dart';
import 'package:test/test.dart';

// Test provider and resolver
class TestProviderKey extends ProviderIdentifier<LogEventResolver> {
  const TestProviderKey({super.name});
}

class TestEventResolver implements LogEventResolver {
  TestEventResolver(this.recorder);

  final List<LogEvent> recorder;

  @override
  Future<void> resolveLogEvent(LogEvent event) async {
    recorder.add(event);
  }
}

class TestProvider extends AnalytycsProvider<LogEventResolver> {
  TestProvider({required super.identifier, List<LogEvent>? recorder})
      : _resolver = TestEventResolver(recorder ?? []);

  final TestEventResolver _resolver;

  @override
  LogEventResolver get resolver => _resolver;

  var _initialized = false;
  Session? _session;
  var _disposed = false;

  bool get initialized => _initialized;
  Session? get session => _session;
  bool get disposed => _disposed;

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
}

class TestLogEvent extends LogEvent {
  const TestLogEvent(super.name, {this.props});

  final Map<String, Object>? props;

  @override
  Map<String, Object>? get properties => props;

  @override
  List<EventProvider<LogEventResolver, LogEventOptions>> get providers => [
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
      final recorder = <LogEvent>[];
      final provider = TestProvider(
        identifier: const TestProviderKey(name: 'test'),
        recorder: recorder,
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

    test('sendEvent resolves event with correct provider', () async {
      final recorder = <LogEvent>[];
      final provider = TestProvider(
        identifier: const TestProviderKey(name: 'test'),
        recorder: recorder,
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

class _UnknownProviderLogEvent extends LogEvent {
  _UnknownProviderLogEvent(super.name, this.key);

  final TestProviderKey key;

  @override
  List<EventProvider<LogEventResolver, LogEventOptions>> get providers => [
        EventProvider(key),
      ];
}
