import 'event_context.dart';

/// Event payload that is progressively transformed by interceptors.
class ResolvedEvent {
  /// Creates resolved event payload used by interceptors/resolvers.
  const ResolvedEvent({
    required this.name,
    this.properties,
    required this.context,
  });

  /// Effective event name for provider dispatch.
  final String name;

  /// Effective event properties for provider dispatch.
  final Map<String, Object?>? properties;

  /// Typed metadata context attached to this event.
  final EventContext context;

  /// Creates a copy with selected fields replaced.
  ResolvedEvent copyWith({
    String? name,
    Map<String, Object?>? properties,
    EventContext? context,
  }) {
    return ResolvedEvent(
      name: name ?? this.name,
      properties: properties ?? this.properties,
      context: context ?? this.context,
    );
  }

  /// Returns a copy whose properties gain every key of [defaults] that is
  /// absent or `null` here. Explicit values always win. A `null` default is
  /// ignored, so `withDefaults({'k': maybeNull})` never adds `k: null`.
  ResolvedEvent withDefaults(Map<String, Object?> defaults) {
    if (defaults.isEmpty) return this;
    final merged = Map<String, Object?>.from(properties ?? const {});
    for (final MapEntry(:key, :value) in defaults.entries) {
      if (value == null) continue;
      merged[key] ??= value;
    }
    return copyWith(properties: merged);
  }
}
