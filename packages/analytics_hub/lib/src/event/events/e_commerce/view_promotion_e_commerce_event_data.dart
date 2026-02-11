part of '../events.dart';

/// Data payload for a "view promotion" e-commerce event.
///
/// Maps to GA4 e-commerce fields. All fields are optional.
class ViewPromotionECommerceEventData {
  /// Creates view-promotion event data.
  const ViewPromotionECommerceEventData({
    this.creativeName,
    this.creativeSlot,
    this.items,
    this.locationId,
    this.promotionId,
    this.promotionName,
    this.parameters,
  });

  /// Name of the creative. e.g. banner, video
  final String? creativeName;

  /// Creative slot. e.g. home_banner
  final String? creativeSlot;

  /// Items associated with the promotion.
  final List<ECommerceEventItem>? items;

  /// Location ID. e.g. home, cart
  final String? locationId;

  /// Promotion ID. e.g. P_12345
  final String? promotionId;

  /// Promotion name. e.g. Summer Sale
  final String? promotionName;

  /// Additional custom parameters.
  final Map<String, Object>? parameters;

  @override
  String toString() => 'ViewPromotionECommerceEventData('
      'creativeName: $creativeName, creativeSlot: $creativeSlot, items: $items, '
      'locationId: $locationId, promotionId: $promotionId, '
      'promotionName: $promotionName, parameters: $parameters)';
}
