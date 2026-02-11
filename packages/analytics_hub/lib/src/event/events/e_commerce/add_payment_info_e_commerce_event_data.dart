part of '../events.dart';

/// Data payload for a "add payment info" e-commerce event.
///
/// Maps to GA4/Marketing e-commerce fields. All fields are optional.
class AddPaymentInfoECommerceEventData {
  /// Creates add-payment-info event data with optional [currency], [value], [items], and [parameters].
  const AddPaymentInfoECommerceEventData({
    this.coupon,
    this.currency,
    this.paymentType,
    this.value,
    this.items,
    this.parameters,
  });

  /// Currency in 3-letter ISO 4217 format. e.g. USD
  final String? coupon;

  /// Currency in 3-letter ISO 4217 format. e.g. USD
  final String? currency;

  /// Payment type. e.g. credit_card
  final String? paymentType;

  /// Monetary value of the payment info. e.g. 100.00
  final double? value;

  /// Defines the required attributes of an e-commerce item.
  /// Items in the payment info.
  final List<ECommerceEventItem>? items;

  /// Additional custom parameters.
  final Map<String, Object>? parameters;

  @override
  String toString() => 'AddPaymentInfoECommerceEventData('
      'coupon: $coupon, '
      'currency: $currency, '
      'paymentType: $paymentType, '
      'value: $value, '
      'items: $items, '
      'parameters: $parameters)';
}

