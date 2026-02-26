import 'package:analytics_hub/analytics_hub.dart';
import 'package:analytics_hub_mixpanel/analytics_hub_mixpanel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:mocktail/mocktail.dart';

class MockMixpanel extends Mock implements Mixpanel {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockMixpanel mockMixpanel;

  setUpAll(() {
    registerFallbackValue(const _TestEvent('fallback', null));
  });

  setUp(() {
    mockMixpanel = MockMixpanel();
  });

  group('MixpanelAnalyticsHubProvider', () {
    test('creates with mixpanel and null name', () {
      final provider = MixpanelAnalyticsHubProvider(mixpanel: mockMixpanel);
      expect(provider.identifier.name, isNull);
    });

    test('creates with mixpanel and custom name', () {
      final provider = MixpanelAnalyticsHubProvider(
        mixpanel: mockMixpanel,
        name: 'custom',
      );
      expect(provider.identifier.name, equals('custom'));
    });

    test('setSession with session calls identify', () async {
      when(() => mockMixpanel.identify(any())).thenAnswer((_) async {});

      final provider = MixpanelAnalyticsHubProvider(mixpanel: mockMixpanel);
      const session = Session(id: 'user-123');
      await provider.setSession(session);

      verify(() => mockMixpanel.identify('user-123')).called(1);
    });

    test('setSession with null and getAnonymousId calls identify with callback',
        () async {
      when(() => mockMixpanel.identify(any())).thenAnswer((_) async {});

      final provider = MixpanelAnalyticsHubProvider(
        mixpanel: mockMixpanel,
        getAnonymousId: () => 'anon-id',
      );
      await provider.setSession(null);

      verify(() => mockMixpanel.identify('anon-id')).called(1);
    });

    test('setSession with null and no getAnonymousId calls reset', () async {
      when(() => mockMixpanel.reset()).thenAnswer((_) async {});

      final provider = MixpanelAnalyticsHubProvider(mixpanel: mockMixpanel);
      await provider.setSession(null);

      verify(() => mockMixpanel.reset()).called(1);
    });

    test('flush delegates to mixpanel', () async {
      when(() => mockMixpanel.flush()).thenAnswer((_) async {});

      final provider = MixpanelAnalyticsHubProvider(mixpanel: mockMixpanel);
      await provider.flush();

      verify(() => mockMixpanel.flush()).called(1);
    });
  });

  group('MixpanelAnalyticsHubIdentifier', () {
    test('creates with null name', () {
      const key = MixpanelAnalyticsHubIdentifier();
      expect(key.name, isNull);
    });

    test('creates with custom name', () {
      const key = MixpanelAnalyticsHubIdentifier(name: 'custom');
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
          MixpanelAnalyticsHubIdentifier(name: 'test'),
        ),
      ];
}
