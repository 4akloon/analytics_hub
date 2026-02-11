part of '../events.dart';

/// Data payload for a "view cart" e-commerce event.
///
/// Maps to GA4/Marketing e-commerce fields. All fields are optional.
class ViewCartECommerceEventData {
  /// Creates view-cart event data with optional [currency], [value], [items], and [parameters].
  const ViewCartECommerceEventData({
    this.currency,
    this.value,
    this.items,
    this.parameters,
  });

  /// Currency in 3-letter ISO 4217 format. e.g. USD
  final String? currency;

  /// Monetary value of the cart. e.g. 100.00
  final double? value;

  /// Items in the cart.
  final List<ECommerceEventItem>? items;

  /// Additional custom parameters.
  final Map<String, Object>? parameters;

  @override
  String toString() => 'ViewCartECommerceEventData('
      'currency: $currency, '
      'value: $value, '
      'items: $items, '
      'parameters: $parameters)';
}

