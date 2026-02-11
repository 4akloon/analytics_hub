library;

import 'package:analytics_hub/src/event/event_resolver.dart';
import 'package:analytics_hub/src/provider/provider_key.dart';

part 'e_commerce/e_commerce_event.dart';
part 'e_commerce/select_promotion_e_commerce_event_data.dart';
part 'e_commerce/add_to_cart_e_commerce_event_data.dart';
part 'e_commerce/add_to_wishlist_e_commerce_event_data.dart';
part 'e_commerce/view_cart_e_commerce_event_data.dart';
part 'e_commerce/add_payment_info_e_commerce_event_data.dart';
part 'e_commerce/add_shipping_info_e_commerce_event_data.dart';
part 'e_commerce/begin_checkout_e_commerce_event_data.dart';
part 'e_commerce/purchase_e_commerce_event_data.dart';
part 'e_commerce/remove_from_cart_e_commerce_event_data.dart';
part 'e_commerce/select_item_e_commerce_event_data.dart';
part 'e_commerce/view_item_e_commerce_event_data.dart';
part 'e_commerce/view_item_list_e_commerce_event_data.dart';
part 'e_commerce/view_promotion_e_commerce_event_data.dart';
part 'e_commerce/refund_e_commerce_event_data.dart';
part 'e_commerce/e_commerce_event_item.dart';
part 'log_event.dart';

/// Base type for analytics events that can be sent through [AnalyticsHub].
///
/// [R] is the [EventResolver] type that knows how to handle this event in each
/// provider. [providerKeys] defines which registered providers receive this event.
/// [resolve] is called by the hub with each provider's resolver to perform the send.
sealed class Event<R extends EventResolver> {
  const Event();

  /// Dispatches this event to the given [resolver] (e.g. a provider's resolver).
  Future<void> resolve(R resolver);

  /// The set of provider keys that should receive this event.
  ///
  /// [AnalyticsHub.sendEvent] sends the event only to providers whose [key]
  /// is in this set.
  Set<ProviderKey<R>> get providerKeys;
}
