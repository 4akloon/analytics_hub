part of '../events.dart';

/// Data payload for a "view item" e-commerce event.
///
/// Maps to GA4 e-commerce fields. All fields are optional.
class ViewItemECommerceEventData {
  /// Creates view-item event data.
  const ViewItemECommerceEventData({
    this.currency,
    this.value,
    this.items,
    this.parameters,
  });

  /// Currency in 3-letter ISO 4217 format. e.g. USD
  final String? currency;

  /// Item value. e.g. 99.99
  final double? value;

  /// Item(s) viewed.
  final List<ECommerceEventItem>? items;

  /// Additional custom parameters.
  final Map<String, Object>? parameters;

  @override
  String toString() => 'ViewItemECommerceEventData('
      'currency: $currency, value: $value, items: $items, parameters: $parameters)';
}
