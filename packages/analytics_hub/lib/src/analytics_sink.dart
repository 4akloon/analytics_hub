import 'event/events/events.dart';

/// Anything that can send an [Event] through the analytics pipeline.
///
/// `AnalyticsHub` implements it directly; `ScopedAnalytics` implements it
/// with a scope attached. Depend on this interface wherever code only needs
/// to send events, so a test can pass a recording fake with no hub.
abstract interface class AnalyticsSink {
  /// Sends [event] to every provider listed in [Event.providers].
  Future<void> sendEvent(Event event);
}
