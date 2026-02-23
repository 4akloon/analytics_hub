import 'package:analytics_hub/analytics_hub.dart';
import 'package:firebase_core/firebase_core.dart';

import '../resolver/firebase_analytics_event_resolver.dart';

/// [ProviderIdentifier] for the Firebase Analytics provider.
///
/// Use this key in [Event.providerKeys] to route events to
/// [FirebaseAnalyticsHubProvider]. [name] defaults to [defaultFirebaseAppName].
class FirebaseAnalyticsHubProviderKey
    extends ProviderIdentifier<FirebaseAnalyticsEventResolver> {
  /// Creates a key with optional [name]; defaults to [defaultFirebaseAppName].
  const FirebaseAnalyticsHubProviderKey({super.name = defaultFirebaseAppName});
}
