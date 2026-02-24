library;

import 'package:analytics_hub/src/event/event_resolver.dart';
import 'package:analytics_hub/src/provider/provider_identifier.dart';

/// Base type for analytics events that can be sent through [AnalyticsHub].
///
/// [providers] defines which registered providers receive this event. [resolve]
/// is called by the hub with each provider's resolver to perform the send.
abstract class Event {
  /// Creates an event with the given [name].
  const Event(this.name);

  /// Event name (e.g. 'screen_view', 'button_clicked').
  final String name;

  /// Optional key-value properties sent with the event. Defaults to null.
  Map<String, Object?>? get properties => null;

  /// The map of providers with their options that should receive this event.
  ///
  /// [AnalyticsHub.sendEvent] sends the event only to providers whose [identifier]
  /// is in this map.
  List<EventProvider> get providers;

  /// Dispatches this event to the given [resolver] (e.g. a provider's resolver).
  Future<void> resolve(EventResolver resolver) => resolver.resolveEvent(this);

  @override
  String toString() => 'Event(name: $name, properties: $properties)';
}

/// Declares a target provider and optional provider-specific event [options].
class EventProvider {
  /// Creates an event target for [identifier] with optional [options].
  const EventProvider(this.identifier, {this.options});

  /// The provider that should receive the event.
  final ProviderIdentifier identifier;

  /// Optional provider-specific options for this event.
  final EventOptions? options;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventProvider &&
          other.identifier == identifier &&
          other.options == options;

  @override
  int get hashCode => identifier.hashCode ^ options.hashCode;

  @override
  String toString() =>
      'EventProvider(identifier: $identifier, options: $options)';
}

/// Per-provider options for an [Event].
///
/// [overrides] lets a provider override event [Event.name] and/or properties.
class EventOptions {
  /// Creates event options.
  const EventOptions({this.overrides});

  /// Optional provider-specific overrides for this event.
  final EventOverrides? overrides;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventOptions && other.overrides == overrides;

  @override
  int get hashCode => overrides.hashCode;

  @override
  String toString() => 'EventOptions(overrides: $overrides)';
}

/// Provider-specific overrides for an [Event].
class EventOverrides {
  /// Creates event override values.
  const EventOverrides({
    this.name,
    this.properties,
  });

  /// Override for event name.
  final String? name;

  /// Override for event properties.
  final Map<String, Object?>? properties;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventOverrides &&
          other.name == name &&
          other.properties == properties;

  @override
  int get hashCode => name.hashCode ^ properties.hashCode;

  @override
  String toString() => 'EventOverrides(name: $name, properties: $properties)';
}
