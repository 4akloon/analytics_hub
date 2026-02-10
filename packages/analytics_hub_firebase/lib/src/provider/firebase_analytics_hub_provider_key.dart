import 'package:analytics_hub/analytics_hub.dart';
import 'package:firebase_core/firebase_core.dart';

import '../resolver/firebase_analytics_event_resolver.dart';

class FirebaseAnalyticsHubProviderKey
    extends ProviderKey<FirebaseAnalyticsEventResolver> {
  const FirebaseAnalyticsHubProviderKey({super.name = defaultFirebaseAppName});
}
