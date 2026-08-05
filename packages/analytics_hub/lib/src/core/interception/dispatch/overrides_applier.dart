import 'package:analytics_hub/src/event/events/events.dart';

import '../context/resolved_event.dart';

/// Applies provider-level event overrides from [EventProvider.overrides].
class EventOverridesApplier {
  /// Creates overrides applier.
  const EventOverridesApplier();

  /// Applies [overrides] to [event] and returns effective payload.
  ResolvedEvent apply(ResolvedEvent event, EventOverrides? overrides) {
    if (overrides == null) return event;

    return event.copyWith(
      name: overrides.name ?? event.name,
      properties: overrides.properties ?? event.properties,
    );
  }
}
