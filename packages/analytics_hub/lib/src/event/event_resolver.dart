import 'events/events.dart';

/// Base interface for resolving (handling) analytics events in a provider.
///
/// Each [AnalytycsProvider] exposes an [EventResolver] subtype. When [AnalyticsHub]
/// sends an [Event], it calls [Event.resolve] with the provider's resolver so
/// the provider can forward the event to its backend.
abstract interface class EventResolver {}

/// Resolver for [LogEvent] — simple name + optional properties.
abstract interface class LogEventResolver extends EventResolver {
  /// Handles a [LogEvent] (e.g. log to Firebase Analytics, Mixpanel, etc.).
  Future<void> resolveLogEvent(LogEvent event);
}

/// Resolver for [CustomLogEvent] with custom payload type [T].
abstract interface class CustomLogEventResolver<T> extends EventResolver {
  /// Handles a [CustomLogEvent] with provider-specific payload [T].
  Future<void> resolveCustomLogEvent(CustomLogEvent<T> event);
}

/// Resolver for [ECommerceEvent] and its subtypes.
abstract interface class ECommerceEventResolver extends EventResolver {
  /// Handles an e-commerce event (e.g. select promotion, purchase).
  Future<void> resolveECommerceEvent(ECommerceEvent event);
}
