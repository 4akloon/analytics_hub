import 'package:analytics_hub/analytics_hub.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:logging/logging.dart';

import '../resolver/firebase_analytics_event_resolver.dart';
import 'firebase_analytics_hub_provider_identifier.dart';

/// [AnalytycsProvider] that sends [Event] to Firebase Analytics via
/// [FirebaseAnalytics].
///
/// Create with [FirebaseAnalyticsHubProvider] (custom instance) or
/// [FirebaseAnalyticsHubProvider.fromInstance] (default app). On [initialize],
/// enables analytics collection; on [setSession], sets the Firebase user ID.
class FirebaseAnalyticsHubProvider extends AnalytycsProvider {
  /// Creates a provider that uses the given [analytics] instance.
  ///
  /// The provider key name is set to [FirebaseAnalytics.app]'s name.
  FirebaseAnalyticsHubProvider({required FirebaseAnalytics analytics})
      : _analytics = analytics,
        super(
          identifier: FirebaseAnalyticsHubProviderIdentifier(
            name: analytics.app.name,
          ),
          interceptors: const [],
        );

  /// Creates a provider using [FirebaseAnalytics.instance] (default app).
  FirebaseAnalyticsHubProvider.fromInstance()
      : this(analytics: FirebaseAnalytics.instance);

  static final _logger = Logger('FirebaseAnalyticsHubProvider');

  final FirebaseAnalytics _analytics;

  @override
  FirebaseAnalyticsEventResolver get resolver =>
      FirebaseAnalyticsEventResolver(_analytics);

  @override
  Future<void> initialize() => _analytics.setAnalyticsCollectionEnabled(true);

  @override
  Future<void> setSession(Session? session) =>
      _analytics.setUserId(id: session?.id);

  @override
  void flush() {
    _logger.info('Flush is not supported for Firebase Analytics');
  }
}
