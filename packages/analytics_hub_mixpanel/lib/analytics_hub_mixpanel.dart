/// Mixpanel implementation for [AnalyticsHub].
///
/// This library provides [MixpanelAnalyticsHubProvider] and
/// [MixpanelAnalyticsHubIdentifier] to send [Event]s from
/// [AnalyticsHub]
/// to Mixpanel via [Mixpanel.track].
///
/// Example:
/// ```dart
/// final provider = MixpanelAnalyticsHubProvider(mixpanel: await Mixpanel.init(...));
/// final hub = AnalyticsHub(
///   providers: [provider],
/// );
/// await hub.initialize();
/// ```
library;

export 'src/provider/mixpanel_analytics_hub_provider.dart';
export 'src/provider/mixpanel_analytics_hub_provider_identifier.dart';
