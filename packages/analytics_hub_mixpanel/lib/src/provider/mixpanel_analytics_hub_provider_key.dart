import 'package:analytics_hub/analytics_hub.dart';
import '../resolver/mixpanel_event_resolver.dart';

class MixpanelAnalyticsHubProviderKey
    extends ProviderKey<MixpanelEventResolver> {
  const MixpanelAnalyticsHubProviderKey({super.name});
}
