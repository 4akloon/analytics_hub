import 'package:analytics_hub/src/event/events/events.dart';

import '../context/event_context.dart';

/// What an [Event] looked like when `sendEvent` was called.
///
/// Taken synchronously before the first `await`, so later mutation of the
/// event's property map or a change in what its getters return cannot leak
/// into the dispatch.
final class EventSnapshot {
  EventSnapshot._({
    required this.event,
    required this.name,
    required this.properties,
    required this.context,
    required this.providers,
  });

  /// Reads [event]'s name, properties, context and providers now.
  factory EventSnapshot.of(Event event) => EventSnapshot._(
        event: event,
        name: event.name,
        properties: switch (event.properties) {
          null => null,
          final properties => Map<String, Object?>.unmodifiable(properties),
        },
        context: event.context,
        providers: List<EventProvider>.unmodifiable(event.providers),
      );

  /// The event instance, kept for `EventDispatchContext.originalEvent`.
  final Event event;

  /// [Event.name] at snapshot time.
  final String name;

  /// A frozen copy of [Event.properties], or `null`.
  final Map<String, Object?>? properties;

  /// [Event.context] at snapshot time.
  final EventContext context;

  /// [Event.providers] at snapshot time.
  final List<EventProvider> providers;
}
