import 'package:analytics_hub/analytics_hub.dart';
import '../resolver/mixpanel_event_resolver.dart';

/// [ProviderKey] for the Mixpanel analytics provider.
///
/// Use this key in [Event.providerKeys] to route events to
/// [MixpanelAnalyticsHubProvider].
class MixpanelAnalyticsHubProviderKey
    extends ProviderKey<MixpanelEventResolver> {
  /// Creates a key with optional [name] for debugging and equality.
  const MixpanelAnalyticsHubProviderKey({super.name});
}
