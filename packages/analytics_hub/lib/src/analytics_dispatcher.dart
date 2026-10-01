import 'core/interception/context/event_context.dart';
import 'event/events/events.dart';

/// Capability to dispatch [Event]s through the analytics pipeline.
///
/// [AnalyticsHub] implements this interface, and so does every dispatcher
/// returned by [scoped]. Depend on [AnalyticsDispatcher] instead of the
/// concrete hub when code only needs to send events.
abstract interface class AnalyticsDispatcher {
  /// Sends [event] to every provider listed in [Event.providers].
  Future<void> sendEvent(Event event);

  /// Returns an immutable dispatcher that applies [context] to every event
  /// sent through it.
  ///
  /// Scopes can be nested: a child scope inherits the parent's context, and
  /// entries of the same type from the child override the parent's. The
  /// event's own [Event.context] overrides both. Creating a child never
  /// changes its parent.
  ///
  /// The returned dispatcher holds no state other than its context, so the
  /// application decides when a scope starts, where it is stored and when it
  /// is no longer used.
  AnalyticsDispatcher scoped({required EventContext context});
}
