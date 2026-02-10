import 'package:analytics_hub/analytics_hub.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import 'firebase_analytics_e_commerce_event_resolver.dart';

class FirebaseAnalyticsEventResolver
    implements EventResolver, LogEventResolver, ECommerceEventResolver {
  FirebaseAnalyticsEventResolver(this._analytics)
      : _eCommerceEventResolver =
            FirebaseAnalyticsECommerceEventResolver(_analytics);

  final FirebaseAnalytics _analytics;
  final FirebaseAnalyticsECommerceEventResolver _eCommerceEventResolver;

  @override
  Future<void> resolveLogEvent(LogEvent event) => _analytics.logEvent(
        name: event.name,
        parameters: event.properties,
      );

  @override
  Future<void> resolveECommerceEvent(ECommerceEvent event) =>
      _eCommerceEventResolver.resolve(event);
}
