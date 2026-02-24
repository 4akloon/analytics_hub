import 'events/events.dart';

/// Interface for resolving (handling) analytics events in a provider.
abstract interface class EventResolver {
  /// Handles an [Event] (e.g. forward to Firebase, Mixpanel, etc.).
  Future<void> resolveEvent(Event event);
}
