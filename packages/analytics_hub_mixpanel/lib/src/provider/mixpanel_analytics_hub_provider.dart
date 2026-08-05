import 'package:analytics_hub/analytics_hub.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

import '../resolver/mixpanel_event_resolver.dart';
import 'mixpanel_analytics_hub_provider_identifier.dart';

/// [AnalyticsProvider] that sends [Event]s to Mixpanel via [Mixpanel.track].
///
/// User identification (identify/reset) is managed by the app directly on the
/// [Mixpanel] instance.
class MixpanelAnalyticsHubProvider extends AnalyticsProvider {
  /// Creates a provider that uses the given [mixpanel] instance.
  ///
  /// [name] is used for the provider key (e.g. for event routing).
  /// [interceptors] are provider-level interceptors executed after hub
  /// interceptors.
  MixpanelAnalyticsHubProvider({
    required Mixpanel mixpanel,
    String? name,
    super.interceptors = const [],
  })  : _mixpanel = mixpanel,
        super(
          identifier: MixpanelAnalyticsHubIdentifier(name: name),
        );

  final Mixpanel _mixpanel;

  @override
  MixpanelEventResolver get resolver => MixpanelEventResolver(_mixpanel);

  @override
  Future<void> flush() => _mixpanel.flush();
}
