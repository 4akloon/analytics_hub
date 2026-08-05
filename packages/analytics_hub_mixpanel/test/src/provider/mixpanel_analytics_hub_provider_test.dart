import 'package:analytics_hub_mixpanel/analytics_hub_mixpanel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:mocktail/mocktail.dart';

class MockMixpanel extends Mock implements Mixpanel {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockMixpanel mockMixpanel;

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
