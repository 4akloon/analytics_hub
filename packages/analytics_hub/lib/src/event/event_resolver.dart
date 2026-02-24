import '../core/interception/context/event_dispatch_context.dart';
import '../core/interception/context/resolved_event.dart';

/// Interface for resolving (handling) analytics events in a provider.
abstract interface class EventResolver {
  /// Handles a transformed [event] with its [context].
  Future<void> resolve(
    ResolvedEvent event, {
    required EventDispatchContext context,
  });
}
