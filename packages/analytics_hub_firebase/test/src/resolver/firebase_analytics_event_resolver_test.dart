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
    registerFallbackValue(const _TestEvent('fallback', null));
  });

  setUp(() {
    mockAnalytics = MockFirebaseAnalytics();
    mockApp = MockFirebaseApp();
    when(() => mockAnalytics.app).thenReturn(mockApp);
    when(() => mockApp.name).thenReturn('test_app');
  });

  group('FirebaseAnalyticsEventResolver', () {
    test('resolveEvent calls logEvent via provider resolver', () async {
      when(
        () => mockAnalytics.logEvent(
          name: any(named: 'name'),
          parameters: any(named: 'parameters'),
        ),
      ).thenAnswer((_) async {});

      final provider = FirebaseAnalyticsHubProvider(analytics: mockAnalytics);
      const event = _TestEvent('test_event', {'key': 'value'});
      await provider.resolver.resolveEvent(event);

      verify(
        () => mockAnalytics.logEvent(
          name: 'test_event',
          parameters: {'key': 'value'},
        ),
      ).called(1);
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
          FirebaseAnalyticsHubProviderIdentifier(name: 'test'),
        ),
      ];
}
