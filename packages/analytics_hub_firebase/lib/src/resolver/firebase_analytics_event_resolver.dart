import 'package:analytics_hub/analytics_hub.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

/// Resolver that forwards [Event] to Firebase Analytics.
///
/// Used internally by [FirebaseAnalyticsHubProvider]. [Event] is sent via
/// [FirebaseAnalytics.logEvent].
class FirebaseAnalyticsEventResolver implements EventResolver {
  /// Creates a resolver that uses the given [FirebaseAnalytics] instance.
  FirebaseAnalyticsEventResolver(this._analytics);

  final FirebaseAnalytics _analytics;

  @override
  Future<void> resolve(
    ResolvedEvent event, {
    required EventDispatchContext context,
  }) {
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
}
