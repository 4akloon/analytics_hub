import 'package:analytics_hub/analytics_hub.dart';
import 'package:analytics_hub_appsflyer/analytics_hub_appsflyer.dart';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAppsflyerSdk extends Mock implements AppsflyerSdk {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockAppsflyerSdk mockSdk;

  setUp(() {
    mockSdk = _MockAppsflyerSdk();
  });

  group('AppsflyerEventResolver', () {
    test('resolve calls logEvent with name and properties', () async {
      when(() => mockSdk.logEvent(any(), any())).thenAnswer(
        (_) async => true,
      );

      final provider = AppsflyerAnalyticsHubProvider(
        appsFlyerSdk: mockSdk,
        getAnonymousId: () => 'anon-id',
      );
      const event = _TestEvent('test_event', {'key': 'value', 'nullKey': null});

      final context = EventDispatchContext(
        originalEvent: event,
        eventProvider: EventProvider(provider.identifier),
        provider: provider,
        timestamp: DateTime.now(),
        correlationId: 'test-correlation-id',
      );

      await provider.resolver.resolve(
        ResolvedEvent(
          name: event.name,
          properties: event.properties,
          context: event.context,
        ),
        context: context,
      );

      verify(
        () => mockSdk.logEvent(
          'test_event',
          {'key': 'value'},
        ),
      ).called(1);
    });

    test('resolve with null properties passes null to logEvent', () async {
      when(() => mockSdk.logEvent(any(), any())).thenAnswer(
        (_) async => true,
      );

      final provider = AppsflyerAnalyticsHubProvider(
        appsFlyerSdk: mockSdk,
        getAnonymousId: () => 'anon-id',
      );
      const event = _TestEvent('test_event', null);

      final context = EventDispatchContext(
        originalEvent: event,
        eventProvider: EventProvider(provider.identifier),
        provider: provider,
        timestamp: DateTime.now(),
        correlationId: 'test-correlation-id',
      );

      await provider.resolver.resolve(
        ResolvedEvent(
          name: event.name,
          properties: event.properties,
          context: event.context,
        ),
        context: context,
      );

      verify(
        () => mockSdk.logEvent(
          'test_event',
          null,
        ),
      ).called(1);
    });
  });
}

class _TestEvent extends Event {
  const _TestEvent(super.name, this.props);

  final Map<String, Object?>? props;

  @override
  Map<String, Object?>? get properties => props;

  @override
  List<EventProvider> get providers => [
        const EventProvider(
          AppsflyerAnalyticsHubIdentifier(name: 'test'),
        ),
      ];
}
