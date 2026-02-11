/// Mixpanel implementation for [AnalyticsHub].
///
/// This library provides [MixpanelAnalyticsHubProvider] and
/// [MixpanelAnalyticsHubProviderKey] to send [LogEvent]s from [AnalyticsHub]
/// to Mixpanel via [Mixpanel.track]. Session updates set the Mixpanel identity
/// via [Mixpanel.identify] or [Mixpanel.reset].
///
/// Example:
/// ```dart
/// final provider = MixpanelAnalyticsHubProvider(mixpanel: await Mixpanel.init(...));
/// final hub = AnalyticsHub(
///   providers: [provider],
///   sessionDelegate: mySessionDelegate,
/// );
/// await hub.initialize();
/// ```
library;

export 'src/provider/mixpanel_analytics_hub_provider.dart';
export 'src/provider/mixpanel_analytics_hub_provider_key.dart';
