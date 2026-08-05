import 'package:analytics_hub/analytics_hub.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import '../resolver/firebase_analytics_event_resolver.dart';
import 'firebase_analytics_hub_provider_identifier.dart';

/// [AnalyticsProvider] that sends [Event] to Firebase Analytics via
/// [FirebaseAnalytics].
///
/// Create with [FirebaseAnalyticsHubProvider] (custom instance) or
/// [FirebaseAnalyticsHubProvider.fromInstance] (default app). Enable
/// collection on the [FirebaseAnalytics] instance in the app if needed.
class FirebaseAnalyticsHubProvider extends AnalyticsProvider {
  /// Creates a provider that uses the given [analytics] instance.
  ///
  /// The provider key name is set to [FirebaseAnalytics.app]'s name.
  /// [interceptors] are provider-level interceptors executed after hub
  /// interceptors.
  FirebaseAnalyticsHubProvider({
    required FirebaseAnalytics analytics,
    super.interceptors = const [],
  })  : _analytics = analytics,
        super(
          identifier: FirebaseAnalyticsHubIdentifier(
            name: analytics.app.name,
          ),
        );

  /// Creates a provider using [FirebaseAnalytics.instance] (default app).
  FirebaseAnalyticsHubProvider.fromInstance()
      : this(analytics: FirebaseAnalytics.instance);

  final FirebaseAnalytics _analytics;

  @override
  FirebaseAnalyticsEventResolver get resolver =>
      FirebaseAnalyticsEventResolver(_analytics);
}
