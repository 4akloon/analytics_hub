part of '../events.dart';

/// Data payload for a "select item" e-commerce event.
///
/// Maps to GA4 e-commerce fields. All fields are optional.
class SelectItemECommerceEventData {
  /// Creates select-item event data.
  const SelectItemECommerceEventData({
    this.itemListId,
    this.itemListName,
    this.items,
    this.parameters,
  });

  /// ID of the list. e.g. related_products
  final String? itemListId;

  /// Name of the list. e.g. Related products
  final String? itemListName;

  /// Selected item(s).
  final List<ECommerceEventItem>? items;

  /// Additional custom parameters.
  final Map<String, Object>? parameters;

  @override
  String toString() => 'SelectItemECommerceEventData('
      'itemListId: $itemListId, itemListName: $itemListName, '
      'items: $items, parameters: $parameters)';
}
