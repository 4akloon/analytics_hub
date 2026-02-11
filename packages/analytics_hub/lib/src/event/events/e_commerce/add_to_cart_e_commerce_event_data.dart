part of '../events.dart';

/// Data payload for an "add to cart" e-commerce event.
///
/// Maps to GA4/Marketing e-commerce fields. All fields are optional.
class AddToCartECommerceEventData {
  /// Creates add-to-cart event data with optional [items], [value],
  /// [currency], and [parameters].
  const AddToCartECommerceEventData({
    this.items,
    this.value,
    this.currency,
    this.parameters,
  });

  /// Items added to the cart.
  final List<ECommerceEventItem>? items;

  /// Monetary value of the added items. e.g. 100.00
  final double? value;

  /// Currency in 3-letter ISO 4217 format. e.g. USD
  final String? currency;

  /// Additional custom parameters.
  final Map<String, Object>? parameters;

  @override
  String toString() => 'AddToCartECommerceEventData('
      'items: $items, '
      'value: $value, '
      'currency: $currency, '
      'parameters: $parameters)';
}
