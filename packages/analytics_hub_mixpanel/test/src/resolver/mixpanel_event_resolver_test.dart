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
    registerFallbackValue(const _TestLogEvent('fallback', null));
  });

  setUp(() {
    mockMixpanel = MockMixpanel();
  });

  group('MixpanelEventResolver', () {
    test('resolveLogEvent calls track with name and properties', () async {
      when(
        () => mockMixpanel.track(
          any(),
          properties: any(named: 'properties'),
        ),
      ).thenAnswer((_) async {});

      final provider = MixpanelAnalyticsHubProvider(mixpanel: mockMixpanel);
      const event = _TestLogEvent('test_event', {'key': 'value'});
      await provider.resolver.resolveLogEvent(event);

      verify(
        () => mockMixpanel.track(
          'test_event',
          properties: {'key': 'value'},
        ),
      ).called(1);
    });

    test('resolveLogEvent with null properties', () async {
      when(
        () => mockMixpanel.track(
          any(),
          properties: any(named: 'properties'),
        ),
      ).thenAnswer((_) async {});

      final provider = MixpanelAnalyticsHubProvider(mixpanel: mockMixpanel);
      const event = _TestLogEvent('test_event', null);
      await provider.resolver.resolveLogEvent(event);

      verify(() => mockMixpanel.track('test_event', properties: null))
          .called(1);
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
        const EventProvider(
          MixpanelAnalyticsHubProviderIdentifier(name: 'test'),
        ),
      ];
}
