import 'package:analytics_hub/analytics_hub.dart';
import 'package:analytics_hub_firebase/analytics_hub_firebase.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAnalytics extends Mock implements FirebaseAnalytics {}

class MockFirebaseApp extends Mock implements FirebaseApp {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockFirebaseAnalytics mockAnalytics;
  late MockFirebaseApp mockApp;

  setUpAll(() {
    registerFallbackValue(const _TestLogEvent('fallback', null));
  });

  setUp(() {
    mockAnalytics = MockFirebaseAnalytics();
    mockApp = MockFirebaseApp();
    when(() => mockAnalytics.app).thenReturn(mockApp);
    when(() => mockApp.name).thenReturn('test_app');
  });

  group('FirebaseAnalyticsHubProvider', () {
    test('creates with analytics and uses app name as key', () {
      final provider = FirebaseAnalyticsHubProvider(analytics: mockAnalytics);
      expect(provider.identifier.name, equals('test_app'));
    });

    test('initialize calls setAnalyticsCollectionEnabled', () async {
      when(() => mockAnalytics.setAnalyticsCollectionEnabled(any()))
          .thenAnswer((_) async {});

      final provider = FirebaseAnalyticsHubProvider(analytics: mockAnalytics);
      await provider.initialize();

      verify(() => mockAnalytics.setAnalyticsCollectionEnabled(true)).called(1);
    });

    test('setSession with session calls setUserId', () async {
      when(() => mockAnalytics.setUserId(id: any(named: 'id')))
          .thenAnswer((_) async {});

      final provider = FirebaseAnalyticsHubProvider(analytics: mockAnalytics);
      const session = Session(id: 'user-123');
      await provider.setSession(session);

      verify(() => mockAnalytics.setUserId(id: 'user-123')).called(1);
    });

    test('setSession with null clears userId', () async {
      when(() => mockAnalytics.setUserId(id: any(named: 'id')))
          .thenAnswer((_) async {});

      final provider = FirebaseAnalyticsHubProvider(analytics: mockAnalytics);
      await provider.setSession(null);

      verify(() => mockAnalytics.setUserId(id: null)).called(1);
    });
  });

  group('FirebaseAnalyticsHubProviderKey', () {
    test('creates with default name', () {
      const key = FirebaseAnalyticsHubProviderKey();
      expect(key.name, equals('[DEFAULT]'));
    });

    test('creates with custom name', () {
      const key = FirebaseAnalyticsHubProviderKey(name: 'custom');
      expect(key.name, equals('custom'));
    });
  });
}

class _TestLogEvent extends LogEvent {
  const _TestLogEvent(super.name, this.props);

  final Map<String, Object>? props;

  @override
  Map<String, Object>? get properties => props;

  @override
  List<EventProvider<LogEventResolver, LogEventOptions>> get providers => [
        const EventProvider(FirebaseAnalyticsHubProviderKey(name: 'test')),
      ];
}
