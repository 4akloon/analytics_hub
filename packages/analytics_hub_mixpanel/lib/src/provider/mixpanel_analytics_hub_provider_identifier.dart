import 'package:analytics_hub/analytics_hub.dart';
import '../resolver/mixpanel_event_resolver.dart';

/// [ProviderIdentifier] for the Mixpanel analytics provider.
///
/// Use this identifier in [Event.providers] to route events to
/// [MixpanelAnalyticsHubProvider].
class MixpanelAnalyticsHubProviderIdentifier
    extends ProviderIdentifier<MixpanelEventResolver> {
  /// Creates an identifier with optional [name] for debugging and equality.
  const MixpanelAnalyticsHubProviderIdentifier({super.name});
}
