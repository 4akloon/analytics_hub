import 'package:analytics_hub/src/event/events/events.dart';

import '../context/event_context.dart';
import '../context/event_dispatch_context.dart';
import 'dispatch_target.dart';

/// Builds [EventDispatchContext] for each provider dispatch.
class EventDispatchContextBuilder {
  /// Creates a builder.
  const EventDispatchContextBuilder();

  /// Builds dispatch context for [originalEvent] and [target].
  ///
  /// [context] is the effective context of the dispatch and [correlationId]
  /// the id shared by every provider dispatch of one `sendEvent` call.
  EventDispatchContext build({
    required Event originalEvent,
    required DispatchTarget target,
    required EventContext context,
    required String correlationId,
  }) =>
      EventDispatchContext(
        originalEvent: originalEvent,
        eventProvider: target.eventProvider,
        provider: target.provider,
        timestamp: DateTime.now(),
        correlationId: correlationId,
        context: context,
      );
}
