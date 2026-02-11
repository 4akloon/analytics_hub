part of '../events.dart';

/// Data payload for a "remove from cart" e-commerce event.
///
/// Maps to GA4 e-commerce fields. All fields are optional.
class RemoveFromCartECommerceEventData {
  /// Creates remove-from-cart event data.
  const RemoveFromCartECommerceEventData({
    this.currency,
    this.value,
    this.items,
    this.parameters,
  });

  /// Currency in 3-letter ISO 4217 format. e.g. USD
  final String? currency;

  /// Monetary value of removed items. e.g. 50.00
  final double? value;

  /// Items removed from the cart.
  final List<ECommerceEventItem>? items;

  /// Additional custom parameters.
  final Map<String, Object>? parameters;

  @override
  String toString() => 'RemoveFromCartECommerceEventData('
      'currency: $currency, value: $value, items: $items, parameters: $parameters)';
}
