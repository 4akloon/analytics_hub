import 'package:analytics_hub/analytics_hub.dart';
import 'package:analytics_hub_firebase/analytics_hub_firebase.dart';

class EmptySessionDelegate implements HubSessionDelegate {
  @override
  Stream<Session?> get sessionStream => Stream.value(null);

  @override
  Future<Session?> getSession() async => null;
}

class ExampleSelectPromotionECommerceEvent
    extends SelectPromotionECommerceEvent {
  const ExampleSelectPromotionECommerceEvent({required this.creativeName});

  final String creativeName;

  @override
  SelectPromotionECommerceEventData get data =>
      SelectPromotionECommerceEventData(
        creativeName: creativeName,
      );

  @override
  Set<ProviderKey<ECommerceEventResolver>> get providerKeys => {
        const FirebaseAnalyticsHubProviderKey(),
      };
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
    const ExampleSelectPromotionECommerceEvent(creativeName: 'creative_name'),
  );

  await hub.dispose();
}
