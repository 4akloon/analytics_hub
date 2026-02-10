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

  group('FirebaseAnalyticsEventResolver', () {
    test('resolveLogEvent calls logEvent via provider resolver', () async {
      when(() => mockAnalytics.logEvent(
            name: any(named: 'name'),
            parameters: any(named: 'parameters'),
          ),).thenAnswer((_) async {});

      final provider = FirebaseAnalyticsHubProvider(analytics: mockAnalytics);
      const event = _TestLogEvent('test_event', {'key': 'value'});
      await provider.resolver.resolveLogEvent(event);

      verify(() => mockAnalytics.logEvent(
            name: 'test_event',
            parameters: {'key': 'value'},
          ),).called(1);
    });

    test('resolveECommerceEvent SelectPromotion calls logSelectPromotion',
        () async {
      when(() => mockAnalytics.logSelectPromotion(
            creativeName: any(named: 'creativeName'),
            creativeSlot: any(named: 'creativeSlot'),
            locationId: any(named: 'locationId'),
            promotionId: any(named: 'promotionId'),
            promotionName: any(named: 'promotionName'),
            parameters: any(named: 'parameters'),
          ),).thenAnswer((_) async {});

      final provider = FirebaseAnalyticsHubProvider(analytics: mockAnalytics);
      const event = _TestSelectPromotionEvent(
        SelectPromotionECommerceEventData(
          creativeName: 'name',
          creativeSlot: 'slot',
          promotionId: 'promo',
        ),
      );
      await provider.resolver.resolveECommerceEvent(event);

      verify(() => mockAnalytics.logSelectPromotion(
            creativeName: 'name',
            creativeSlot: 'slot',
            locationId: null,
            promotionId: 'promo',
            promotionName: null,
            parameters: null,
          ),).called(1);
    });
  });
}

class _TestSelectPromotionEvent extends SelectPromotionECommerceEvent {
  const _TestSelectPromotionEvent(this.data);

  @override
  final SelectPromotionECommerceEventData data;

  @override
  Set<ProviderKey<ECommerceEventResolver>> get providerKeys =>
      {const _TestECommerceKey(name: 'test')};
}

class _TestECommerceKey extends ProviderKey<ECommerceEventResolver> {
  const _TestECommerceKey({super.name});
}

class _TestLogEvent extends LogEvent {
  const _TestLogEvent(super.name, this.props);

  final Map<String, Object>? props;

  @override
  Map<String, Object>? get properties => props;

  @override
  Set<ProviderKey<LogEventResolver>> get providerKeys =>
      {const _TestProviderKey(name: 'test')};
}

class _TestProviderKey extends ProviderKey<LogEventResolver> {
  const _TestProviderKey({super.name});
}
