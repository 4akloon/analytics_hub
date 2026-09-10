import 'package:analytics_hub/analytics_hub.dart';
import 'package:analytics_hub_appsflyer/analytics_hub_appsflyer.dart';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';

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
  // AppsFlyer SDK 7 exposes a shared singleton instead of a constructor.
  // Replace the placeholders with your actual dev key and app id, and keep
  // secrets out of source control.
  final appsFlyerSdk = AppsFlyerSdk.instance;

  await appsFlyerSdk.init(devKey: 'YOUR_DEV_KEY', appId: 'YOUR_APP_ID');

  // Initialization no longer sends a session: start once per readiness event.
  await appsFlyerSdk.registerSessionReadyListener(appsFlyerSdk.start);

  final hub = AnalyticsHub(
    providers: [
      AppsflyerAnalyticsHubProvider(
        appsFlyerSdk: appsFlyerSdk,
      ),
    ],
  );

  await hub.sendEvent(
    const ExampleEvent(exampleProperty: 'example_property'),
  );
}
