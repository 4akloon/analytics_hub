import 'package:analytics_hub/analytics_hub.dart';
import 'package:analytics_hub_firebase/analytics_hub_firebase.dart';

class ExampleEvent extends Event {
  const ExampleEvent({required this.creativeName}) : super('select_promotion');

  final String creativeName;

  @override
  Map<String, Object?> get properties => {'creative_name': creativeName};

  @override
  List<EventProvider> get providers => [
        const EventProvider(FirebaseAnalyticsHubIdentifier()),
      ];
}

Future<void> main() async {
  final hub = AnalyticsHub(
    providers: [
      FirebaseAnalyticsHubProvider.fromInstance(),
    ],
  );

  await hub.sendEvent(
    const ExampleEvent(creativeName: 'creative_name'),
  );

}
