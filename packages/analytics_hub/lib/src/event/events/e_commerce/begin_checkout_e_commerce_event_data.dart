part of '../events.dart';

/// Data payload for a "begin checkout" e-commerce event.
///
/// Maps to GA4 e-commerce fields. All fields are optional.
class BeginCheckoutECommerceEventData {
  /// Creates begin-checkout event data.
  const BeginCheckoutECommerceEventData({
    this.value,
    this.currency,
    this.items,
    this.coupon,
    this.parameters,
  });

  /// Monetary value. e.g. 100.00
  final double? value;

  /// Currency in 3-letter ISO 4217 format. e.g. USD
  final String? currency;

  /// Items in the checkout.
  final List<ECommerceEventItem>? items;

  /// Coupon code. e.g. SUMMER_FUN
  final String? coupon;

  /// Additional custom parameters.
  final Map<String, Object>? parameters;

  @override
  String toString() => 'BeginCheckoutECommerceEventData('
      'value: $value, currency: $currency, items: $items, '
      'coupon: $coupon, parameters: $parameters)';
}
