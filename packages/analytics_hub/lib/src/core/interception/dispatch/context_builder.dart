import 'package:analytics_hub/src/event/events/events.dart';

import '../context/event_dispatch_context.dart';
import 'correlation_id_generator.dart';
import 'dispatch_target.dart';

/// Builds [EventDispatchContext] for each provider dispatch.
class EventDispatchContextBuilder {
  /// Creates a builder with correlation strategy and hub metadata.
  EventDispatchContextBuilder({
    required CorrelationIdGenerator correlationIdGenerator,
  }) : _correlationIdGenerator = correlationIdGenerator;

  final CorrelationIdGenerator _correlationIdGenerator;

  /// Builds dispatch context for [originalEvent] and [target].
  EventDispatchContext build({
    required Event originalEvent,
    required DispatchTarget target,
  }) =>
      EventDispatchContext(
        originalEvent: originalEvent,
        eventProvider: target.eventProvider,
        provider: target.provider,
        timestamp: DateTime.now(),
        correlationId: _correlationIdGenerator.nextCorrelationId(),
      ).merge(target.provider.interceptorContext);
}
