import 'package:analytics_hub/analytics_hub.dart';
import 'package:analytics_hub_appsflyer/analytics_hub_appsflyer.dart';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';

class EmptySessionDelegate implements HubSessionDelegate {
  @override
  Stream<Session?> get sessionStream => Stream.value(null);

  @override
  Future<Session?> getSession() async => null;
}

class ExampleEvent extends Event {
  const ExampleEvent({required this.exampleProperty})
      : super('example_log_event');

  final String exampleProperty;

  @override
  Map<String, Object?> get properties => {'example_property': exampleProperty};

  @override
  List<EventProvider> get providers => [
        const EventProvider(
          AppsflyerAnalyticsHubIdentifier(),
        ),
      ];
}

Future<void> main() async {
  // Initialize AppsFlyerSdk with your configuration. Replace placeholders
  // with your actual dev key and app id. Keep secrets out of source control.
  final appsFlyerOptions = AppsFlyerOptions(
    afDevKey: 'YOUR_DEV_KEY',
    appId: 'YOUR_APP_ID',
    showDebug: true,
  );

  final appsFlyerSdk = AppsflyerSdk(appsFlyerOptions);

  await appsFlyerSdk.initSdk(
    registerConversionDataCallback: false,
    registerOnAppOpenAttributionCallback: false,
    registerOnDeepLinkingCallback: false,
  );

  final hub = AnalyticsHub(
    sessionDelegate: EmptySessionDelegate(),
    providers: [
      AppsflyerAnalyticsHubProvider(
        appsFlyerSdk: appsFlyerSdk,
        getAnonymousId: () => 'anonymous-user-id',
      ),
    ],
  );

  await hub.initialize();

  await hub.sendEvent(
    const ExampleEvent(exampleProperty: 'example_property'),
  );

  await hub.dispose();
}
