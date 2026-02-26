import 'package:analytics_hub/analytics_hub.dart';

/// [ProviderIdentifier] for the Appsflyer analytics provider.
///
/// Use this identifier in [Event.providers] to route events to
/// [AppsflyerAnalyticsHubProvider].
class AppsflyerAnalyticsHubIdentifier extends ProviderIdentifier {
  /// Creates an identifier with optional [name] for debugging and equality.
  const AppsflyerAnalyticsHubIdentifier({super.name});
}
