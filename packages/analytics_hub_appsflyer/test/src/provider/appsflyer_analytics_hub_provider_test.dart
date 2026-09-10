import 'package:analytics_hub_appsflyer/analytics_hub_appsflyer.dart';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAppsFlyerSdk extends Mock implements AppsFlyerSdk {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockAppsFlyerSdk mockSdk;

  setUp(() {
    mockSdk = _MockAppsFlyerSdk();
  });

  group('AppsflyerAnalyticsHubProvider', () {
    test('creates with sdk and null name', () {
      final provider = AppsflyerAnalyticsHubProvider(
        appsFlyerSdk: mockSdk,
      );
      expect(provider.identifier.name, isNull);
    });

    test('creates with sdk and custom name', () {
      final provider = AppsflyerAnalyticsHubProvider(
        appsFlyerSdk: mockSdk,
        name: 'custom',
      );
      expect(provider.identifier.name, equals('custom'));
    });

    test('flush is a no-op for appsflyer', () {
      final provider = AppsflyerAnalyticsHubProvider(
        appsFlyerSdk: mockSdk,
      );

      expect(() => provider.flush(), returnsNormally);
    });
  });

  group('AppsflyerAnalyticsHubIdentifier', () {
    test('creates with null name', () {
      const key = AppsflyerAnalyticsHubIdentifier();
      expect(key.name, isNull);
    });

    test('creates with custom name', () {
      const key = AppsflyerAnalyticsHubIdentifier(name: 'custom');
      expect(key.name, equals('custom'));
    });
  });
}
