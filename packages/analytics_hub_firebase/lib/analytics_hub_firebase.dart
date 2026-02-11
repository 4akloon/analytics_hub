/// Firebase Analytics implementation for [AnalyticsHub].
///
/// This library provides [FirebaseAnalyticsHubProvider] and
/// [FirebaseAnalyticsHubProviderKey] to send [Event]s from [AnalyticsHub]
/// to Firebase Analytics. Supports [LogEvent] and [ECommerceEvent] (e.g.
/// [SelectPromotionECommerceEvent]).
///
/// Example:
/// ```dart
/// final provider = FirebaseAnalyticsHubProvider.fromInstance();
/// final hub = AnalyticsHub(
///   providers: [provider],
///   sessionDelegate: mySessionDelegate,
/// );
/// await hub.initialize();
/// ```
library;

export 'src/provider/firebase_analytics_hub_provider.dart';
export 'src/provider/firebase_analytics_hub_provider_key.dart';
