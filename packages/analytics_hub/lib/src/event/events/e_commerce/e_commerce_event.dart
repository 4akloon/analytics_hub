part of '../events.dart';

/// Base type for e-commerce events (promotions, purchases, etc.).
///
/// Resolved by [ECommerceEventResolver]. Subclasses define specific e-commerce
/// payloads (e.g. [SelectPromotionECommerceEvent]).
sealed class ECommerceEvent<T>
    extends Event<ECommerceEventResolver, ECommerceEventOptions<T>> {
  const ECommerceEvent();

  @override
  Future<void> resolve(ECommerceEventResolver resolver) =>
      resolver.resolveECommerceEvent(this);
}

/// Per-provider options for an [ECommerceEvent].
///
/// [overrides] contains provider-specific e-commerce payload data.
class ECommerceEventOptions<T> implements EventOptions {
  /// Creates e-commerce event options.
  const ECommerceEventOptions({this.overrides});

  /// Optional provider-specific payload override.
  final T? overrides;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ECommerceEventOptions<T> && other.overrides == overrides;

  @override
  int get hashCode => overrides.hashCode;

  @override
  String toString() => 'ECommerceEventOptions(overrides: $overrides)';
}

/// E-commerce event for when a user selects a promotion.
///
/// Carries [data] with promotion details. Resolved by [ECommerceEventResolver].
abstract class SelectPromotionECommerceEvent
    extends ECommerceEvent<SelectPromotionECommerceEventData> {
  /// Creates a select-promotion e-commerce event.
  const SelectPromotionECommerceEvent();

  /// Promotion data for this event.
  SelectPromotionECommerceEventData get data;
}

/// E-commerce event for when a user adds item(s) to the cart.
///
/// Carries [data] with cart add details. Resolved by [ECommerceEventResolver].
abstract class AddToCartECommerceEvent
    extends ECommerceEvent<AddToCartECommerceEventData> {
  /// Creates an add-to-cart e-commerce event.
  const AddToCartECommerceEvent();

  /// Add-to-cart data for this event.
  AddToCartECommerceEventData get data;
}

/// E-commerce event for when a user adds item(s) to a wishlist.
///
/// Carries [data] with wishlist add details. Resolved by [ECommerceEventResolver].
abstract class AddToWishlistECommerceEvent
    extends ECommerceEvent<AddToWishlistECommerceEventData> {
  /// Creates an add-to-wishlist e-commerce event.
  const AddToWishlistECommerceEvent();

  /// Add-to-wishlist data for this event.
  AddToWishlistECommerceEventData get data;
}

/// E-commerce event for when a user views their cart.
///
/// Carries [data] with cart details. Resolved by [ECommerceEventResolver].
abstract class ViewCartECommerceEvent
    extends ECommerceEvent<ViewCartECommerceEventData> {
  /// Creates a view-cart e-commerce event.
  const ViewCartECommerceEvent();

  /// Cart data for this event.
  ViewCartECommerceEventData get data;
}

/// E-commerce event for when a user adds payment info.
///
/// Carries [data] with payment info details. Resolved by [ECommerceEventResolver].
abstract class AddPaymentInfoECommerceEvent
    extends ECommerceEvent<AddPaymentInfoECommerceEventData> {
  /// Creates a add-payment-info e-commerce event.
  const AddPaymentInfoECommerceEvent();

  /// Payment info data for this event.
  AddPaymentInfoECommerceEventData get data;
}

/// E-commerce event for when a user submits shipping information.
///
/// Carries [data] with shipping details. Resolved by [ECommerceEventResolver].
abstract class AddShippingInfoECommerceEvent
    extends ECommerceEvent<AddShippingInfoECommerceEventData> {
  /// Creates an add-shipping-info e-commerce event.
  const AddShippingInfoECommerceEvent();

  /// Shipping info data for this event.
  AddShippingInfoECommerceEventData get data;
}

/// E-commerce event for when a user begins checkout.
///
/// Carries [data] with checkout details. Resolved by [ECommerceEventResolver].
abstract class BeginCheckoutECommerceEvent
    extends ECommerceEvent<BeginCheckoutECommerceEventData> {
  /// Creates a begin-checkout e-commerce event.
  const BeginCheckoutECommerceEvent();

  /// Checkout data for this event.
  BeginCheckoutECommerceEventData get data;
}

/// E-commerce event for when a user completes a purchase.
///
/// Carries [data] with purchase details. Resolved by [ECommerceEventResolver].
abstract class PurchaseECommerceEvent
    extends ECommerceEvent<PurchaseECommerceEventData> {
  /// Creates a purchase e-commerce event.
  const PurchaseECommerceEvent();

  /// Purchase data for this event.
  PurchaseECommerceEventData get data;
}

/// E-commerce event for when a user removes item(s) from the cart.
///
/// Carries [data] with removed items. Resolved by [ECommerceEventResolver].
abstract class RemoveFromCartECommerceEvent
    extends ECommerceEvent<RemoveFromCartECommerceEventData> {
  /// Creates a remove-from-cart e-commerce event.
  const RemoveFromCartECommerceEvent();

  /// Remove-from-cart data for this event.
  RemoveFromCartECommerceEventData get data;
}

/// E-commerce event for when a user selects an item from a list.
///
/// Carries [data] with list and item details. Resolved by [ECommerceEventResolver].
abstract class SelectItemECommerceEvent
    extends ECommerceEvent<SelectItemECommerceEventData> {
  /// Creates a select-item e-commerce event.
  const SelectItemECommerceEvent();

  /// Select-item data for this event.
  SelectItemECommerceEventData get data;
}

/// E-commerce event for when a user views an item (product/content).
///
/// Carries [data] with item details. Resolved by [ECommerceEventResolver].
abstract class ViewItemECommerceEvent
    extends ECommerceEvent<ViewItemECommerceEventData> {
  /// Creates a view-item e-commerce event.
  const ViewItemECommerceEvent();

  /// View-item data for this event.
  ViewItemECommerceEventData get data;
}

/// E-commerce event for when a user is presented with a list of items.
///
/// Carries [data] with list and items. Resolved by [ECommerceEventResolver].
abstract class ViewItemListECommerceEvent
    extends ECommerceEvent<ViewItemListECommerceEventData>
    implements EventOptions {
  /// Creates a view-item-list e-commerce event.
  const ViewItemListECommerceEvent();

  /// View-item-list data for this event.
  ViewItemListECommerceEventData get data;
}

/// E-commerce event for when a promotion is shown to a user.
///
/// Carries [data] with promotion details. Resolved by [ECommerceEventResolver].
abstract class ViewPromotionECommerceEvent
    extends ECommerceEvent<ViewPromotionECommerceEventData> {
  /// Creates a view-promotion e-commerce event.
  const ViewPromotionECommerceEvent();

  /// View-promotion data for this event.
  ViewPromotionECommerceEventData get data;
}

/// E-commerce event for when a refund is issued.
///
/// Carries [data] with refund details. Resolved by [ECommerceEventResolver].
abstract class RefundECommerceEvent
    extends ECommerceEvent<RefundECommerceEventData> {
  /// Creates a refund e-commerce event.
  const RefundECommerceEvent();

  /// Refund data for this event.
  RefundECommerceEventData get data;
}
