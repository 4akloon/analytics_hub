part of 'events.dart';

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
