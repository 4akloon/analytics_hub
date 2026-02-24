/// Firebase Analytics implementation for [AnalyticsHub].
///
/// This library provides [FirebaseAnalyticsHubProvider] and
/// [FirebaseAnalyticsHubProviderIdentifier] to send [Event]s from [AnalyticsHub]
/// to Firebase Analytics.
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
export 'src/provider/firebase_analytics_hub_provider_identifier.dart';
