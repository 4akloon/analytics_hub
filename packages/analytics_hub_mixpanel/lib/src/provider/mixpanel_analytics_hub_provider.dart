import 'package:analytics_hub/analytics_hub.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

import '../resolver/mixpanel_event_resolver.dart';
import 'mixpanel_analytics_hub_provider_key.dart';

/// [AnalytycsProvider] that sends [LogEvent]s to Mixpanel via [Mixpanel.track].
///
/// On [setSession]: if [Session] is non-null, calls [Mixpanel.identify] with
/// [Session.id]; if null and [getAnonymousId] is provided, identifies with that
/// ID; otherwise calls [Mixpanel.reset].
class MixpanelAnalyticsHubProvider
    extends AnalytycsProvider<MixpanelEventResolver> {
  /// Creates a provider that uses the given [mixpanel] instance.
  ///
  /// [name] is used for the provider key (e.g. for event routing). [getAnonymousId]
  /// is called when session becomes null to set an anonymous ID instead of
  /// resetting; if null, [Mixpanel.reset] is used on logout.
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
