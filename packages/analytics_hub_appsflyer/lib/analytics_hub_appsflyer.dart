/// Appsflyer implementation for [AnalyticsHub].
///
/// This library provides [AppsflyerAnalyticsHubProvider] and
/// [AppsflyerAnalyticsHubIdentifier] to send [Event]s from
/// [AnalyticsHub] to Appsflyer via [AppsflyerSdk.logEvent]. Session updates
/// set the Appsflyer customer user ID via [AppsflyerSdk.setCustomerUserId].
///
/// Example:
/// ```dart
/// final provider = AppsflyerAnalyticsHubProvider(appsFlyerSdk: appsFlyer);
/// final hub = AnalyticsHub(
///   providers: [provider],
///   sessionDelegate: mySessionDelegate,
/// );
/// await hub.initialize();
/// ```
library;

export 'src/provider/appsflyer_analytics_hub_provider.dart';
export 'src/provider/appsflyer_analytics_hub_provider_identifier.dart';
