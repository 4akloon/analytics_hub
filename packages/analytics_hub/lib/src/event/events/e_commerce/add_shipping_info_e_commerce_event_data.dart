part of '../events.dart';

/// Data payload for an "add shipping info" e-commerce event.
///
/// Maps to GA4/Marketing e-commerce fields. All fields are optional.
class AddShippingInfoECommerceEventData {
  /// Creates add-shipping-info event data with optional [coupon], [currency],
  /// [value], [shippingTier], [items], and [parameters].
  const AddShippingInfoECommerceEventData({
    this.coupon,
    this.currency,
    this.value,
    this.shippingTier,
    this.items,
    this.parameters,
  });

  /// Coupon code associated with the shipping. e.g. FREE_SHIP
  final String? coupon;

  /// Currency in 3-letter ISO 4217 format. e.g. USD
  final String? currency;

  /// Monetary value of the shipment. e.g. 100.00
  final double? value;

  /// Shipping tier. e.g. ground, air, express
  final String? shippingTier;

  /// Items associated with this shipment.
  final List<ECommerceEventItem>? items;

  /// Additional custom parameters.
  final Map<String, Object>? parameters;

  @override
  String toString() => 'AddShippingInfoECommerceEventData('
      'coupon: $coupon, '
      'currency: $currency, '
      'value: $value, '
      'shippingTier: $shippingTier, '
      'items: $items, '
      'parameters: $parameters)';
}
