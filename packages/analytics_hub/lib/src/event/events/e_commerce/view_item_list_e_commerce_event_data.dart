part of '../events.dart';

/// Data payload for a "view item list" e-commerce event.
///
/// Maps to GA4 e-commerce fields. All fields are optional.
class ViewItemListECommerceEventData {
  /// Creates view-item-list event data.
  const ViewItemListECommerceEventData({
    this.items,
    this.itemListId,
    this.itemListName,
    this.parameters,
  });

  /// Items in the list.
  final List<ECommerceEventItem>? items;

  /// ID of the list. e.g. search_results
  final String? itemListId;

  /// Name of the list. e.g. Search results
  final String? itemListName;

  /// Additional custom parameters.
  final Map<String, Object>? parameters;

  @override
  String toString() => 'ViewItemListECommerceEventData('
      'items: $items, itemListId: $itemListId, itemListName: $itemListName, '
      'parameters: $parameters)';
}
