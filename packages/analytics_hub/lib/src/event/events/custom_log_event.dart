part of 'events.dart';

/// An event with a custom payload type [T], resolved by [CustomLogEventResolver].
///
/// Use when a provider needs a strongly-typed payload (e.g. a Mixpanel or Amplitude
/// event model) instead of a generic [LogEvent].
abstract class CustomLogEvent<T>
    extends Event<CustomLogEventResolver<T>, CustomLogEventOptions<T>> {
  /// Creates a custom log event.
  const CustomLogEvent();

  @override
  Future<void> resolve(CustomLogEventResolver<T> resolver) =>
      resolver.resolveCustomLogEvent(this);
}

/// Per-provider options for a [CustomLogEvent].
///
/// [overrides] contains provider-specific custom payload data.
class CustomLogEventOptions<T> implements EventOptions {
  /// Creates custom log event options.
  const CustomLogEventOptions({this.overrides});

  /// Optional provider-specific payload override.
  final T? overrides;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomLogEventOptions<T> && other.overrides == overrides;

  @override
  int get hashCode => overrides.hashCode;

  @override
  String toString() => 'CustomLogEventOptions(overrides: $overrides)';
}
