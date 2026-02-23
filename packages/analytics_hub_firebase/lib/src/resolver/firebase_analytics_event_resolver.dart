import 'package:analytics_hub/analytics_hub.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import 'firebase_analytics_e_commerce_event_resolver.dart';

/// Resolver that forwards [LogEvent] and [ECommerceEvent] to Firebase Analytics.
///
/// Used internally by [FirebaseAnalyticsHubProvider]. [LogEvent] is sent via
/// [FirebaseAnalytics.logEvent]; e-commerce events are delegated to
/// [FirebaseAnalyticsECommerceEventResolver].
class FirebaseAnalyticsEventResolver
    implements EventResolver, LogEventResolver, ECommerceEventResolver {
  /// Creates a resolver that uses the given [FirebaseAnalytics] instance.
  FirebaseAnalyticsEventResolver(this._analytics)
      : _eCommerceEventResolver =
            FirebaseAnalyticsECommerceEventResolver(_analytics);

  final FirebaseAnalytics _analytics;
  final FirebaseAnalyticsECommerceEventResolver _eCommerceEventResolver;

  @override
  Future<void> resolveLogEvent(LogEvent event) {
    final parameters = switch (event.properties) {
      null => null,
      final properties => Map<String, Object>.fromEntries(
          properties.entries
              .where((entry) => entry.value != null)
              .map((entry) => MapEntry(entry.key, entry.value as Object)),
        ),
    };

    return _analytics.logEvent(
      name: event.name,
      parameters: parameters,
    );
  }

  @override
  Future<void> resolveECommerceEvent(ECommerceEvent event) =>
      _eCommerceEventResolver.resolve(event);
}
