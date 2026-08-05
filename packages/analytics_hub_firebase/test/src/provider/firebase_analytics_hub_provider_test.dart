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

    test('flush is a no-op for firebase analytics', () {
      final provider = FirebaseAnalyticsHubProvider(analytics: mockAnalytics);

      expect(() => provider.flush(), returnsNormally);
    });
  });

  group('FirebaseAnalyticsHubIdentifier', () {
    test('creates with default name', () {
      const key = FirebaseAnalyticsHubIdentifier();
      expect(key.name, equals('[DEFAULT]'));
    });

    test('creates with custom name', () {
      const key = FirebaseAnalyticsHubIdentifier(name: 'custom');
      expect(key.name, equals('custom'));
    });
  });
}
