part of '../events.dart';

/// Data payload for a "refund" e-commerce event.
///
/// Maps to GA4 e-commerce fields. All fields are optional.
class RefundECommerceEventData {
  /// Creates refund event data.
  const RefundECommerceEventData({
    this.currency,
    this.coupon,
    this.value,
    this.tax,
    this.shipping,
    this.transactionId,
    this.affiliation,
    this.items,
    this.parameters,
  });

  /// Currency in 3-letter ISO 4217 format. e.g. USD
  final String? currency;

  /// Coupon code. e.g. SUMMER_FUN
  final String? coupon;

  /// Refund value. e.g. 100.00
  final double? value;

  /// Tax refunded. e.g. 10.00
  final double? tax;

  /// Shipping refunded. e.g. 5.00
  final double? shipping;

  /// Transaction ID. e.g. T_12345
  final String? transactionId;

  /// Store or affiliation. e.g. Google Store
  final String? affiliation;

  /// Refunded items.
  final List<ECommerceEventItem>? items;

  /// Additional custom parameters.
  final Map<String, Object>? parameters;

  @override
  String toString() => 'RefundECommerceEventData('
      'currency: $currency, coupon: $coupon, value: $value, tax: $tax, '
      'shipping: $shipping, transactionId: $transactionId, '
      'affiliation: $affiliation, items: $items, parameters: $parameters)';
}
