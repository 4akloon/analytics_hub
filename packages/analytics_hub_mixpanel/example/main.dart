import 'package:analytics_hub/analytics_hub.dart';
import 'package:analytics_hub_mixpanel/analytics_hub_mixpanel.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

class EmptySessionDelegate implements HubSessionDelegate {
  @override
  Stream<Session?> get sessionStream => Stream.value(null);

  @override
  Future<Session?> getSession() async => null;
}

class ExampleLogEvent extends LogEvent {
  const ExampleLogEvent({required this.exampleProperty})
      : super('example_log_event');

  final String exampleProperty;

  @override
  Map<String, Object>? get properties => {'example_property': exampleProperty};

  @override
  List<EventProvider<LogEventResolver, LogEventOptions>> get providers => [
        const EventProvider(MixpanelAnalyticsHubProviderKey()),
      ];
}

Future<void> main() async {
  final mixpanel = await Mixpanel.init(
    'YOUR_MIXPANEL_TOKEN',
    trackAutomaticEvents: false,
  );

  final hub = AnalyticsHub(
    sessionDelegate: EmptySessionDelegate(),
    providers: [
      MixpanelAnalyticsHubProvider(mixpanel: mixpanel),
    ],
  );

  await hub.initialize();

  await hub.sendEvent(
    const ExampleLogEvent(exampleProperty: 'example_property'),
  );

  await hub.dispose();
}
