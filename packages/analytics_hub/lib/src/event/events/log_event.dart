part of 'events.dart';

/// A simple log event with a [name] and optional [properties].
///
/// Use for generic analytics events (e.g. screen view, button click). Resolved
/// by [LogEventResolver]. Override [properties] in subclasses to attach data.
abstract class LogEvent extends Event<LogEventResolver, LogEventOptions> {
  /// Creates a log event with the given [name].
  const LogEvent(this.name);

  /// Event name (e.g. 'screen_view', 'button_clicked').
  final String name;

  /// Optional key-value properties sent with the event. Defaults to null.
  Map<String, Object?>? get properties => null;

  @override
  Future<void> resolve(LogEventResolver resolver) =>
      resolver.resolveLogEvent(this);

  @override
  String toString() => 'LogEvent(name: $name, properties: $properties)';
}

/// Per-provider options for a [LogEvent].
///
/// [overrides] lets a provider override event [LogEvent.name] and/or properties.
class LogEventOptions implements EventOptions {
  /// Creates log event options.
  const LogEventOptions({this.overrides});

  /// Optional provider-specific overrides for this event.
  final LogEventOverrides? overrides;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LogEventOptions && other.overrides == overrides;

  @override
  int get hashCode => overrides.hashCode;

  @override
  String toString() => 'LogEventOptions(overrides: $overrides)';
}

/// Provider-specific overrides for a [LogEvent].
class LogEventOverrides {
  /// Creates log event override values.
  const LogEventOverrides({
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
      other is LogEventOverrides &&
          other.name == name &&
          other.properties == properties;

  @override
  int get hashCode => name.hashCode ^ properties.hashCode;

  @override
  String toString() =>
      'LogEventOverrides(name: $name, properties: $properties)';
}
