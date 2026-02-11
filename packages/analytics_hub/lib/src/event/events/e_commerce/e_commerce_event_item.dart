part of '../events.dart';

/// Aligns with GA4/Firebase item params. Use in item-based e-commerce events.
/// See: https://developers.google.com/analytics/devguides/collection/ga4/reference/events
class ECommerceEventItem {
  /// Creates an e-commerce item with optional GA4 item parameters.
  const ECommerceEventItem({
    this.affiliation,
    this.currency,
    this.coupon,
    this.creativeName,
    this.creativeSlot,
    this.discount,
    this.index,
    this.itemBrand,
    this.itemCategory,
    this.itemCategory2,
    this.itemCategory3,
    this.itemCategory4,
    this.itemCategory5,
    this.itemId,
    this.itemListId,
    this.itemListName,
    this.itemName,
    this.itemVariant,
    this.locationId,
    this.price,
    this.promotionId,
    this.promotionName,
    this.quantity,
    this.parameters,
  });

  /// A product affiliation (e.g. store or brand). e.g. Google Store
  final String? affiliation;

  /// Currency in 3-letter ISO 4217 format. e.g. USD
  final String? currency;

  /// Coupon name/code. e.g. SUMMER_FUN
  final String? coupon;

  /// Name of the promotional creative.
  final String? creativeName;

  /// Name of the promotional creative slot.
  final String? creativeSlot;

  /// Monetary discount value. e.g. 2.22
  final num? discount;

  /// Index/position of the item in a list. e.g. 5
  final int? index;

  /// Brand of the item. e.g. Google
  final String? itemBrand;

  /// Item category (first level). e.g. Apparel
  final String? itemCategory;

  /// Second category or taxonomy. e.g. Adult
  final String? itemCategory2;

  /// Third category or taxonomy. e.g. Shirts
  final String? itemCategory3;

  /// Fourth category or taxonomy. e.g. Crew
  final String? itemCategory4;

  /// Fifth category or taxonomy. e.g. Short sleeve
  final String? itemCategory5;

  /// ID of the item. One of [itemId] or [itemName] is required. e.g. SKU_12345
  final String? itemId;

  /// ID of the list in which the item was presented. e.g. related_products
  final String? itemListId;

  /// Name of the list. e.g. Related products
  final String? itemListName;

  /// Name of the item. One of [itemId] or [itemName] is required. e.g. Stan and Friends Tee
  final String? itemName;

  /// Item variant or extra details. e.g. green
  final String? itemVariant;

  /// Location associated with the item (e.g. Google Place ID or custom). e.g. L_12345
  final String? locationId;

  /// Monetary price in the specified currency. e.g. 9.99
  final num? price;

  /// ID of the promotion. e.g. P_12345
  final String? promotionId;

  /// Name of the promotion. e.g. Summer Sale
  final String? promotionName;

  /// Item quantity. e.g. 1
  final int? quantity;

  /// Extra parameters (strings and numbers for GA4).
  final Map<String, Object>? parameters;

  @override
  String toString() => 'ECommerceEventItem('
      'affiliation: $affiliation, '
      'currency: $currency, '
      'coupon: $coupon, '
      'creativeName: $creativeName, '
      'creativeSlot: $creativeSlot, '
      'discount: $discount, '
      'index: $index, '
      'itemBrand: $itemBrand, '
      'itemCategory: $itemCategory, '
      'itemCategory2: $itemCategory2, '
      'itemCategory3: $itemCategory3, '
      'itemCategory4: $itemCategory4, '
      'itemCategory5: $itemCategory5, '
      'itemId: $itemId, '
      'itemListId: $itemListId, '
      'itemListName: $itemListName, '
      'itemName: $itemName, '
      'itemVariant: $itemVariant, '
      'locationId: $locationId, '
      'price: $price, '
      'promotionId: $promotionId, '
      'promotionName: $promotionName, '
      'quantity: $quantity, '
      'parameters: $parameters)';
}

