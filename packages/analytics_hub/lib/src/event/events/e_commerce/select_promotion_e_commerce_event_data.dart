part of '../events.dart';

/// Data payload for a "select promotion" e-commerce event.
///
/// Maps to GA4/Marketing e-commerce fields. All fields are optional.
class SelectPromotionECommerceEventData {
  /// Creates promotion event data with optional [creativeName], [creativeSlot],
  /// [locationId], [promotionId], [promotionName], and [parameters].
  const SelectPromotionECommerceEventData({
    this.creativeName,
    this.creativeSlot,
    this.locationId,
    this.items,
    this.promotionId,
    this.promotionName,
    this.parameters,
  });

  /// Name of the creative (e.g. banner, video).
  final String? creativeName;

  /// Slot or position of the promotion.
  final String? creativeSlot;

  /// Items associated with the promotion.
  final List<ECommerceEventItem>? items;

  /// Location identifier (e.g. 'home', 'cart').
  final String? locationId;

  /// Promotion identifier.
  final String? promotionId;

  /// Human-readable promotion name.
  final String? promotionName;

  /// Additional custom parameters.
  final Map<String, Object>? parameters;

  @override
  String toString() => 'SelectPromotionECommerceEventData('
      'creativeName: $creativeName, '
      'creativeSlot: $creativeSlot, '
      'items: $items, '
      'locationId: $locationId, '
      'promotionId: $promotionId, '
      'promotionName: $promotionName, '
      'parameters: $parameters)';
}
