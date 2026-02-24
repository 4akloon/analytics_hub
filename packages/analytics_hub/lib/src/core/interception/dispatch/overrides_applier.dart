import 'package:analytics_hub/src/event/events/events.dart';
import '../context/resolved_event.dart';

/// Applies provider-level event overrides from [EventOptions].
class EventOverridesApplier {
  /// Creates overrides applier.
  const EventOverridesApplier();

  /// Applies [options] overrides to [event] and returns effective payload.
  ResolvedEvent apply(ResolvedEvent event, EventOptions? options) {
    final overrides = options?.overrides;
    if (overrides == null) return event;

    return event.copyWith(
      name: overrides.name ?? event.name,
      properties: overrides.properties ?? event.properties,
    );
  }
}
