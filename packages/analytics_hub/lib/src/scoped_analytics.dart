import 'analytics_hub.dart';
import 'analytics_sink.dart';
import 'core/interception/context/event_context.dart';
import 'core/interception/interceptor/event_interceptor.dart';
import 'event/events/events.dart';
import 'scope/analytics_scope.dart';

/// An [AnalyticsSink] that sends every event through [scope].
///
/// Holds nothing but the hub and the scope; the application decides where a
/// scope starts, who keeps it and when it is no longer used.
final class ScopedAnalytics implements AnalyticsSink {
  /// Creates a sink that dispatches through [hub] with [scope].
  const ScopedAnalytics(this._hub, this.scope);

  final AnalyticsHub _hub;

  /// The scope applied to every event sent through this sink.
  final AnalyticsScope scope;

  @override
  Future<void> sendEvent(Event event) => _hub.sendEvent(event, scope: scope);

  /// Returns a sink whose scope is nested in [scope].
  ScopedAnalytics child({
    required String name,
    EventContext context = const EventContext(),
    List<EventInterceptor> interceptors = const [],
  }) =>
      ScopedAnalytics(
        _hub,
        scope.child(name: name, context: context, interceptors: interceptors),
      );
}
