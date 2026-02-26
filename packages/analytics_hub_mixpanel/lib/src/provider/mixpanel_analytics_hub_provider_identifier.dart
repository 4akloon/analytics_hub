import 'package:analytics_hub/analytics_hub.dart';

/// [ProviderIdentifier] for the Mixpanel analytics provider.
///
/// Use this identifier in [Event.providers] to route events to
/// [MixpanelAnalyticsHubProvider].
class MixpanelAnalyticsHubIdentifier extends ProviderIdentifier {
  /// Creates an identifier with optional [name] for debugging and equality.
  const MixpanelAnalyticsHubIdentifier({super.name});
}
