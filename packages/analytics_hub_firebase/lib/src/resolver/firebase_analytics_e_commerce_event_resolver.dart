import 'package:analytics_hub/analytics_hub.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

/// Resolves [ECommerceEvent] subtypes to Firebase Analytics e-commerce APIs.
///
/// Handles [SelectPromotionECommerceEvent] via [FirebaseAnalytics.logSelectPromotion].
/// Used internally by [FirebaseAnalyticsEventResolver].
class FirebaseAnalyticsECommerceEventResolver implements EventResolver {
  /// Creates a resolver that uses the given [FirebaseAnalytics] instance.
  const FirebaseAnalyticsECommerceEventResolver(this._analytics);

  final FirebaseAnalytics _analytics;

  /// Dispatches [event] to the appropriate Firebase e-commerce method.
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
