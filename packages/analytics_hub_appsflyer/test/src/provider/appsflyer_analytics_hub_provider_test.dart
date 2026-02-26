import 'package:analytics_hub/analytics_hub.dart';
import 'package:analytics_hub_appsflyer/analytics_hub_appsflyer.dart';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAppsflyerSdk extends Mock implements AppsflyerSdk {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockAppsflyerSdk mockSdk;

  setUpAll(() {
    registerFallbackValue(const _TestEvent('fallback', null));
  });

  setUp(() {
    mockSdk = _MockAppsflyerSdk();
  });

  group('AppsflyerAnalyticsHubProvider', () {
    test('creates with sdk and null name', () {
      final provider = AppsflyerAnalyticsHubProvider(
        appsFlyerSdk: mockSdk,
        getAnonymousId: () => 'anon-id',
      );
      expect(provider.identifier.name, isNull);
    });

    test('creates with sdk and custom name', () {
      final provider = AppsflyerAnalyticsHubProvider(
        appsFlyerSdk: mockSdk,
        name: 'custom',
        getAnonymousId: () => 'anon-id',
      );
      expect(provider.identifier.name, equals('custom'));
    });

    test('setSession with session calls setCustomerUserId', () async {
      when(() => mockSdk.setCustomerUserId(any())).thenReturn(null);

      final provider = AppsflyerAnalyticsHubProvider(
        appsFlyerSdk: mockSdk,
        getAnonymousId: () => 'anon-id',
      );
      const session = Session(id: 'user-123');
      await provider.setSession(session);

      verify(() => mockSdk.setCustomerUserId('user-123')).called(1);
    });

    test('setSession with null and getAnonymousId uses callback', () async {
      when(() => mockSdk.setCustomerUserId(any())).thenReturn(null);

      final provider = AppsflyerAnalyticsHubProvider(
        appsFlyerSdk: mockSdk,
        getAnonymousId: () => 'anon-id',
      );
      await provider.setSession(null);

      verify(() => mockSdk.setCustomerUserId('anon-id')).called(1);
    });

    test('flush is a no-op for appsflyer', () {
      final provider = AppsflyerAnalyticsHubProvider(
        appsFlyerSdk: mockSdk,
        getAnonymousId: () => 'anon-id',
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

class _TestEvent extends Event {
  const _TestEvent(super.name, this.props);

  final Map<String, Object>? props;

  @override
  Map<String, Object>? get properties => props;

  @override
  List<EventProvider> get providers => [
        const EventProvider(
          AppsflyerAnalyticsHubIdentifier(name: 'test'),
        ),
      ];
}
