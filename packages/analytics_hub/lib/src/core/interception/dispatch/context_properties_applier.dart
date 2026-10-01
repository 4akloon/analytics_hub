import 'package:logging/logging.dart';

import '../context/event_dispatch_context.dart';
import '../context/event_properties_contributor.dart';
import '../context/resolved_event.dart';

/// Merges properties of [EventPropertiesContributor] context entries into
/// the event properties.
class EventContextPropertiesApplier {
  /// Creates context properties applier.
  const EventContextPropertiesApplier();

  static final _logger = Logger('AnalyticsHub');

  /// Applies contributed properties from [context] to [event].
  ///
  /// Returns [event] unchanged when no entry contributes properties.
  /// Contributed values override event properties with the same key.
  ResolvedEvent apply(ResolvedEvent event, EventDispatchContext context) {
    final contributed = <String, Object?>{
      for (final entry in context.entries)
        if (entry is EventPropertiesContributor)
          ...(entry as EventPropertiesContributor).toEventProperties(),
    };
    if (contributed.isEmpty) return event;

    final properties = event.properties;
    if (properties != null) {
      for (final MapEntry(:key, :value) in contributed.entries) {
        if (properties.containsKey(key) && properties[key] != value) {
          _logger.warning(
            'Context property "$key" overrides event property of '
            '${event.name}: ${properties[key]} -> $value',
          );
        }
      }
    }

    return event.copyWith(properties: {...?properties, ...contributed});
  }
}
