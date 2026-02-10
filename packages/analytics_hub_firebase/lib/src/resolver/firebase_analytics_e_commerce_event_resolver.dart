import 'package:analytics_hub/analytics_hub.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class FirebaseAnalyticsECommerceEventResolver implements EventResolver {
  const FirebaseAnalyticsECommerceEventResolver(this._analytics);

  final FirebaseAnalytics _analytics;

  Future<void> resolve(
    ECommerceEvent event,
  ) =>
      switch (event) {
        final SelectPromotionECommerceEvent event =>
          _resolveSelectPromotionEvent(event),
      };

  Future<void> _resolveSelectPromotionEvent(
    SelectPromotionECommerceEvent event,
  ) =>
      _analytics.logSelectPromotion(
        creativeName: event.data.creativeName,
        creativeSlot: event.data.creativeSlot,
        locationId: event.data.locationId,
        promotionId: event.data.promotionId,
        promotionName: event.data.promotionName,
        parameters: event.data.parameters,
      );
}
