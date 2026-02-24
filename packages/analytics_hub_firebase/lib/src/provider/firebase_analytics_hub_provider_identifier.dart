import 'package:analytics_hub/analytics_hub.dart';
import 'package:firebase_core/firebase_core.dart';

/// [ProviderIdentifier] for the Firebase Analytics provider.
///
/// Use this identifier in [Event.providers] to route events to
/// [FirebaseAnalyticsHubProvider]. [name] defaults to [defaultFirebaseAppName].
class FirebaseAnalyticsHubProviderIdentifier extends ProviderIdentifier {
  /// Creates an identifier with optional [name]; defaults to [defaultFirebaseAppName].
  const FirebaseAnalyticsHubProviderIdentifier({
    super.name = defaultFirebaseAppName,
  });
}
