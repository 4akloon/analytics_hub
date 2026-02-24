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
}
