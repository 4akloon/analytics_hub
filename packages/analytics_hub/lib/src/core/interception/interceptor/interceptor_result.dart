import '../context/event_dispatch_context.dart';
import '../context/resolved_event.dart';

/// Result of interceptor processing.
class InterceptorResult {
  const InterceptorResult._({
    required this.event,
    required this.context,
    required this.isDropped,
  });

  /// Continue pipeline with [event] and [context].
  const InterceptorResult.continueWith(
    ResolvedEvent event, {
    required EventDispatchContext context,
  }) : this._(event: event, context: context, isDropped: false);

  /// Stop pipeline and drop event.
  const InterceptorResult.drop(
    ResolvedEvent event, {
    required EventDispatchContext context,
  }) : this._(event: event, context: context, isDropped: true);

  /// Effective payload after interceptor processing.
  final ResolvedEvent event;

  /// Effective dispatch context after interceptor processing.
  final EventDispatchContext context;

  /// Whether dispatch should be stopped and dropped.
  final bool isDropped;
}
