import '../provider/provider_key.dart';
import 'event_resolver.dart';

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

/// A simple log event with a [name] and optional [properties].
///
/// Use for generic analytics events (e.g. screen view, button click). Resolved
/// by [LogEventResolver]. Override [properties] in subclasses to attach data.
abstract class LogEvent extends Event<LogEventResolver> {
  /// Creates a log event with the given [name].
  const LogEvent(this.name);

  /// Event name (e.g. 'screen_view', 'button_clicked').
  final String name;

  /// Optional key-value properties sent with the event. Defaults to null.
  Map<String, Object>? get properties => null;

  @override
  Future<void> resolve(LogEventResolver resolver) =>
      resolver.resolveLogEvent(this);

  @override
  String toString() => 'LogEvent(name: $name, properties: $properties)';
}

/// An event with a custom payload type [T], resolved by [CustomLogEventResolver].
///
/// Use when a provider needs a strongly-typed payload (e.g. a Mixpanel or Amplitude
/// event model) instead of a generic [LogEvent].
abstract class CustomLogEvent<T> extends Event<CustomLogEventResolver<T>> {
  /// Creates a custom log event.
  const CustomLogEvent();

  @override
  Future<void> resolve(CustomLogEventResolver<T> resolver) =>
      resolver.resolveCustomLogEvent(this);
}

/// Base type for e-commerce events (promotions, purchases, etc.).
///
/// Resolved by [ECommerceEventResolver]. Subclasses define specific e-commerce
/// payloads (e.g. [SelectPromotionECommerceEvent]).
sealed class ECommerceEvent extends Event<ECommerceEventResolver> {
  const ECommerceEvent();

  @override
  Future<void> resolve(ECommerceEventResolver resolver) =>
      resolver.resolveECommerceEvent(this);
}

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
    this.promotionId,
    this.promotionName,
    this.parameters,
  });

  /// Name of the creative (e.g. banner, video).
  final String? creativeName;

  /// Slot or position of the promotion.
  final String? creativeSlot;

  /// Location identifier (e.g. 'home', 'cart').
  final String? locationId;

  /// Promotion identifier.
  final String? promotionId;

  /// Human-readable promotion name.
  final String? promotionName;

  /// Additional custom parameters.
  final Map<String, Object>? parameters;
}

/// E-commerce event for when a user selects a promotion.
///
/// Carries [data] with promotion details. Resolved by [ECommerceEventResolver].
abstract class SelectPromotionECommerceEvent extends ECommerceEvent {
  /// Creates a select-promotion e-commerce event.
  const SelectPromotionECommerceEvent();

  /// Promotion data for this event.
  SelectPromotionECommerceEventData get data;
}
