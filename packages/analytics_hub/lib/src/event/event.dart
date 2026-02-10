import '../provider/provider_key.dart';
import 'event_resolver.dart';

sealed class Event<R extends EventResolver> {
  const Event();

  Future<void> resolve(R resolver);

  Set<ProviderKey<R>> get providerKeys;
}

abstract class LogEvent extends Event<LogEventResolver> {
  const LogEvent(this.name);

  final String name;

  Map<String, Object>? get properties => null;

  @override
  Future<void> resolve(LogEventResolver resolver) =>
      resolver.resolveLogEvent(this);

  @override
  String toString() => 'LogEvent(name: $name, properties: $properties)';
}

abstract class CustomLogEvent<T> extends Event<CustomLogEventResolver<T>> {
  const CustomLogEvent();

  @override
  Future<void> resolve(CustomLogEventResolver<T> resolver) =>
      resolver.resolveCustomLogEvent(this);
}

sealed class ECommerceEvent extends Event<ECommerceEventResolver> {
  const ECommerceEvent();

  @override
  Future<void> resolve(ECommerceEventResolver resolver) =>
      resolver.resolveECommerceEvent(this);
}

class SelectPromotionECommerceEventData {
  const SelectPromotionECommerceEventData({
    this.creativeName,
    this.creativeSlot,
    this.locationId,
    this.promotionId,
    this.promotionName,
    this.parameters,
  });

  final String? creativeName;
  final String? creativeSlot;
  final String? locationId;
  final String? promotionId;
  final String? promotionName;
  final Map<String, Object>? parameters;
}

abstract class SelectPromotionECommerceEvent extends ECommerceEvent {
  const SelectPromotionECommerceEvent();

  SelectPromotionECommerceEventData get data;
}
