import 'package:analytics_hub/analytics_hub.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import '../resolver/firebase_analytics_event_resolver.dart';
import 'firebase_analytics_hub_provider_key.dart';

class FirebaseAnalyticsHubProvider
    extends AnalytycsProvider<FirebaseAnalyticsEventResolver> {
  FirebaseAnalyticsHubProvider({required FirebaseAnalytics analytics})
      : _analytics = analytics,
        super(key: FirebaseAnalyticsHubProviderKey(name: analytics.app.name));

  FirebaseAnalyticsHubProvider.fromInstance()
      : this(analytics: FirebaseAnalytics.instance);

  final FirebaseAnalytics _analytics;

  @override
  FirebaseAnalyticsEventResolver get resolver =>
      FirebaseAnalyticsEventResolver(_analytics);

  @override
  Future<void> initialize() async {
    await _analytics.setAnalyticsCollectionEnabled(true);
  }

  @override
  Future<void> setSession(Session? session) async {
    await _analytics.setUserId(id: session?.id);
  }
}
