/// Firebase Analytics implementation for [AnalyticsHub].
///
/// This library provides [FirebaseAnalyticsHubProvider] and
/// [FirebaseAnalyticsHubIdentifier] to send [Event]s from [AnalyticsHub]
/// to Firebase Analytics.
///
/// Example:
/// ```dart
/// final provider = FirebaseAnalyticsHubProvider.fromInstance();
/// final hub = AnalyticsHub(
///   providers: [provider],
/// );
/// await hub.initialize();
/// ```
library;

export 'src/provider/firebase_analytics_hub_provider.dart';
export 'src/provider/firebase_analytics_hub_provider_identifier.dart';
