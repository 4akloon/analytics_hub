part of '../events.dart';

/// Data payload for a "purchase" e-commerce event.
///
/// Maps to GA4 e-commerce fields. All fields are optional.
class PurchaseECommerceEventData {
  /// Creates purchase event data.
  const PurchaseECommerceEventData({
    this.currency,
    this.coupon,
    this.value,
    this.items,
    this.tax,
    this.shipping,
    this.transactionId,
    this.affiliation,
    this.parameters,
  });

  /// Currency in 3-letter ISO 4217 format. e.g. USD
  final String? currency;

  /// Coupon code. e.g. SUMMER_FUN
  final String? coupon;

  /// Total value. e.g. 100.00
  final double? value;

  /// Purchased items.
  final List<ECommerceEventItem>? items;

  /// Tax amount. e.g. 10.00
  final double? tax;

  /// Shipping cost. e.g. 5.00
  final double? shipping;

  /// Transaction ID. e.g. T_12345
  final String? transactionId;

  /// Store or affiliation. e.g. Google Store
  final String? affiliation;

  /// Additional custom parameters.
  final Map<String, Object>? parameters;

  @override
  String toString() => 'PurchaseECommerceEventData('
      'currency: $currency, coupon: $coupon, value: $value, items: $items, '
      'tax: $tax, shipping: $shipping, transactionId: $transactionId, '
      'affiliation: $affiliation, parameters: $parameters)';
}
