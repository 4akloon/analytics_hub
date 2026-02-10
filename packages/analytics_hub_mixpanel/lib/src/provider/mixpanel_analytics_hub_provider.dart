import 'package:analytics_hub/analytics_hub.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

import '../resolver/mixpanel_event_resolver.dart';
import 'mixpanel_analytics_hub_provider_key.dart';

class MixpanelAnalyticsHubProvider
    extends AnalytycsProvider<MixpanelEventResolver> {
  MixpanelAnalyticsHubProvider({
    required Mixpanel mixpanel,
    String? name,
    String Function()? getAnonymousId,
  })  : _mixpanel = mixpanel,
        _getAnonymousId = getAnonymousId,
        super(key: MixpanelAnalyticsHubProviderKey(name: name));

  final Mixpanel _mixpanel;
  final String Function()? _getAnonymousId;

  @override
  MixpanelEventResolver get resolver => MixpanelEventResolver(_mixpanel);

  @override
  Future<void> setSession(Session? session) async {
    if (session != null) {
      await _mixpanel.identify(session.id);
    } else if (_getAnonymousId case final callback?) {
      await _mixpanel.identify(callback());
    } else {
      await _mixpanel.reset();
    }
  }
}
