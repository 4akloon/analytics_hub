import 'package:analytics_hub/analytics_hub.dart';
import 'package:analytics_hub_mixpanel/analytics_hub_mixpanel.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

class ExampleEvent extends Event {
  const ExampleEvent({required this.exampleProperty})
      : super('example_log_event');

  final String exampleProperty;

  @override
  Map<String, Object>? get properties => {'example_property': exampleProperty};

  @override
  List<EventProvider> get providers => [
        const EventProvider(MixpanelAnalyticsHubIdentifier()),
      ];
}

Future<void> main() async {
  final mixpanel = await Mixpanel.init(
    'YOUR_MIXPANEL_TOKEN',
    trackAutomaticEvents: false,
  );

  final hub = AnalyticsHub(
    providers: [
      MixpanelAnalyticsHubProvider(mixpanel: mixpanel),
    ],
  );

  await hub.sendEvent(
    const ExampleEvent(exampleProperty: 'example_property'),
  );

}
