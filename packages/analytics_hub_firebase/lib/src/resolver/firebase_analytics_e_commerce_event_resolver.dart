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
  Future<void> resolve(ECommerceEvent event) => switch (event) {
        final SelectPromotionECommerceEvent event =>
          _resolveSelectPromotionEvent(event),
        final AddToCartECommerceEvent event => _resolveAddToCartEvent(event),
        final AddToWishlistECommerceEvent event =>
          _resolveAddToWishlistEvent(event),
        final ViewCartECommerceEvent event => _resolveViewCartEvent(event),
        final AddPaymentInfoECommerceEvent event =>
          _resolveAddPaymentInfoEvent(event),
        final AddShippingInfoECommerceEvent event =>
          _resolveAddShippingInfoEvent(event),
        final BeginCheckoutECommerceEvent event =>
          _resolveBeginCheckoutEvent(event),
        final PurchaseECommerceEvent event => _resolvePurchaseEvent(event),
        final RemoveFromCartECommerceEvent event =>
          _resolveRemoveFromCartEvent(event),
        final SelectItemECommerceEvent event =>
          _resolveSelectItemEvent(event),
        final ViewItemECommerceEvent event => _resolveViewItemEvent(event),
        final ViewItemListECommerceEvent event =>
          _resolveViewItemListEvent(event),
        final ViewPromotionECommerceEvent event =>
          _resolveViewPromotionEvent(event),
        final RefundECommerceEvent event => _resolveRefundEvent(event),
      };

  Future<void> _resolveSelectPromotionEvent(
    SelectPromotionECommerceEvent event,
  ) =>
      _analytics.logSelectPromotion(
        creativeName: event.data.creativeName,
        creativeSlot: event.data.creativeSlot,
        items: event.data.items?.map((item) => item.toFirebase()).toList(),
        locationId: event.data.locationId,
        promotionId: event.data.promotionId,
        promotionName: event.data.promotionName,
        parameters: event.data.parameters,
      );

  Future<void> _resolveAddToCartEvent(
    AddToCartECommerceEvent event,
  ) =>
      _analytics.logAddToCart(
        items: event.data.items?.map((item) => item.toFirebase()).toList(),
        value: event.data.value,
        currency: event.data.currency,
        parameters: event.data.parameters,
      );

  Future<void> _resolveAddToWishlistEvent(
    AddToWishlistECommerceEvent event,
  ) =>
      _analytics.logAddToWishlist(
        items: event.data.items?.map((item) => item.toFirebase()).toList(),
        value: event.data.value,
        currency: event.data.currency,
        parameters: event.data.parameters,
      );

  Future<void> _resolveViewCartEvent(
    ViewCartECommerceEvent event,
  ) =>
      _analytics.logViewCart(
        currency: event.data.currency,
        value: event.data.value,
        items: event.data.items?.map((item) => item.toFirebase()).toList(),
        parameters: event.data.parameters,
      );
  Future<void> _resolveAddPaymentInfoEvent(
    AddPaymentInfoECommerceEvent event,
  ) =>
      _analytics.logAddPaymentInfo(
        coupon: event.data.coupon,
        currency: event.data.currency,
        paymentType: event.data.paymentType,
        value: event.data.value,
        items: event.data.items?.map((item) => item.toFirebase()).toList(),
        parameters: event.data.parameters,
      );

  Future<void> _resolveAddShippingInfoEvent(
    AddShippingInfoECommerceEvent event,
  ) =>
      _analytics.logAddShippingInfo(
        coupon: event.data.coupon,
        currency: event.data.currency,
        value: event.data.value,
        shippingTier: event.data.shippingTier,
        items: event.data.items?.map((item) => item.toFirebase()).toList(),
        parameters: event.data.parameters,
      );

  Future<void> _resolveBeginCheckoutEvent(
    BeginCheckoutECommerceEvent event,
  ) =>
      _analytics.logBeginCheckout(
        value: event.data.value,
        currency: event.data.currency,
        items: event.data.items?.map((item) => item.toFirebase()).toList(),
        coupon: event.data.coupon,
        parameters: event.data.parameters,
      );

  Future<void> _resolvePurchaseEvent(PurchaseECommerceEvent event) =>
      _analytics.logPurchase(
        currency: event.data.currency,
        coupon: event.data.coupon,
        value: event.data.value,
        items: event.data.items?.map((item) => item.toFirebase()).toList(),
        tax: event.data.tax,
        shipping: event.data.shipping,
        transactionId: event.data.transactionId,
        affiliation: event.data.affiliation,
        parameters: event.data.parameters,
      );

  Future<void> _resolveRemoveFromCartEvent(
    RemoveFromCartECommerceEvent event,
  ) =>
      _analytics.logRemoveFromCart(
        currency: event.data.currency,
        value: event.data.value,
        items: event.data.items?.map((item) => item.toFirebase()).toList(),
        parameters: event.data.parameters,
      );

  Future<void> _resolveSelectItemEvent(SelectItemECommerceEvent event) =>
      _analytics.logSelectItem(
        itemListId: event.data.itemListId,
        itemListName: event.data.itemListName,
        items: event.data.items?.map((item) => item.toFirebase()).toList(),
        parameters: event.data.parameters,
      );

  Future<void> _resolveViewItemEvent(ViewItemECommerceEvent event) =>
      _analytics.logViewItem(
        currency: event.data.currency,
        value: event.data.value,
        items: event.data.items?.map((item) => item.toFirebase()).toList(),
        parameters: event.data.parameters,
      );

  Future<void> _resolveViewItemListEvent(
    ViewItemListECommerceEvent event,
  ) =>
      _analytics.logViewItemList(
        items: event.data.items?.map((item) => item.toFirebase()).toList(),
        itemListId: event.data.itemListId,
        itemListName: event.data.itemListName,
        parameters: event.data.parameters,
      );

  Future<void> _resolveViewPromotionEvent(
    ViewPromotionECommerceEvent event,
  ) =>
      _analytics.logViewPromotion(
        creativeName: event.data.creativeName,
        creativeSlot: event.data.creativeSlot,
        items: event.data.items?.map((item) => item.toFirebase()).toList(),
        locationId: event.data.locationId,
        promotionId: event.data.promotionId,
        promotionName: event.data.promotionName,
        parameters: event.data.parameters,
      );

  Future<void> _resolveRefundEvent(RefundECommerceEvent event) =>
      _analytics.logRefund(
        currency: event.data.currency,
        coupon: event.data.coupon,
        value: event.data.value,
        tax: event.data.tax,
        shipping: event.data.shipping,
        transactionId: event.data.transactionId,
        affiliation: event.data.affiliation,
        items: event.data.items?.map((item) => item.toFirebase()).toList(),
        parameters: event.data.parameters,
      );
}

extension on ECommerceEventItem {
  AnalyticsEventItem toFirebase() => AnalyticsEventItem(
        affiliation: affiliation,
        currency: currency,
        coupon: coupon,
        creativeName: creativeName,
        creativeSlot: creativeSlot,
        discount: discount,
        index: index,
        itemBrand: itemBrand,
        itemCategory: itemCategory,
        itemCategory2: itemCategory2,
        itemCategory3: itemCategory3,
        itemCategory4: itemCategory4,
        itemCategory5: itemCategory5,
        itemId: itemId,
        itemListId: itemListId,
        itemListName: itemListName,
        itemName: itemName,
        itemVariant: itemVariant,
        locationId: locationId,
        price: price,
        promotionId: promotionId,
        promotionName: promotionName,
        quantity: quantity,
        parameters: parameters,
      );
}
