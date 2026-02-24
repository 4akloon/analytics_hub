import 'package:analytics_hub/analytics_hub.dart';
import 'package:analytics_hub_firebase/analytics_hub_firebase.dart';

class EmptySessionDelegate implements HubSessionDelegate {
  @override
  Stream<Session?> get sessionStream => Stream.value(null);

  @override
  Future<Session?> getSession() async => null;
}

class ExampleEvent extends Event {
  const ExampleEvent({required this.creativeName}) : super('select_promotion');

  final String creativeName;

  @override
  Map<String, Object?> get properties => {'creative_name': creativeName};

  @override
  List<EventProvider> get providers => [
        const EventProvider(FirebaseAnalyticsHubProviderIdentifier()),
      ];
}

Future<void> main() async {
  final hub = AnalyticsHub(
    sessionDelegate: EmptySessionDelegate(),
    providers: [
      FirebaseAnalyticsHubProvider.fromInstance(),
    ],
  );

  await hub.initialize();

  await hub.sendEvent(
    const ExampleEvent(creativeName: 'creative_name'),
  );

  await hub.dispose();
}
