import 'package:analytics_hub/src/event/events/events.dart';
import 'package:logging/logging.dart';
import '../context/resolved_event.dart';

/// Applies provider-level event overrides from [EventOptions].
class EventOverridesApplier {
  /// Creates overrides applier.
  const EventOverridesApplier();

  static final _logger = Logger('AnalyticsHub.EventOverridesApplier');

  /// Applies [options] overrides to [event] and returns effective payload.
  ResolvedEvent apply(ResolvedEvent event, EventOverrides? overrides) {
    if (overrides == null) return event;

    _logger.fine('Applying overrides: $overrides to event: $event');
    return event.copyWith(
      name: overrides.name ?? event.name,
      properties: overrides.properties ?? event.properties,
    );
  }
}
