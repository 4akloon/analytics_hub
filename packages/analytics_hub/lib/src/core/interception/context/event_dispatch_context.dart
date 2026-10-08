import 'package:analytics_hub/src/event/events/events.dart';
import 'package:analytics_hub/src/provider/analytics_provider.dart';
import 'package:analytics_hub/src/provider/provider_identifier.dart';

import 'context_entry.dart';
import 'event_context.dart';

/// Context passed into each interceptor and resolver call.
///
/// One instance is built per event/provider pair. [context] is the effective
/// typed context of the dispatch: the scope chain's records followed by the
/// event's own.
class EventDispatchContext {
  /// Creates dispatch context for a single event-provider pair.
  const EventDispatchContext({
    required this.originalEvent,
    required this.eventProvider,
    required this.provider,
    required this.timestamp,
    required this.correlationId,
    required this.context,
  });

  /// Original user event before any overrides/interceptors.
  final Event originalEvent;

  /// Event target configuration (including per-provider options).
  final EventProvider eventProvider;

  /// Resolved provider instance for this dispatch.
  final AnalyticsProvider provider;

  /// Creation timestamp of this dispatch context.
  final DateTime timestamp;

  /// Correlation identifier shared by every provider dispatch of one
  /// `sendEvent` call; ties logs, traces and interceptor actions together.
  final String correlationId;

  /// Effective typed context of this dispatch.
  final EventContext context;

  /// Identifier of the provider receiving this dispatch.
  ProviderIdentifier get providerIdentifier => eventProvider.identifier;

  /// Shortcut for `context.entry<T>()`.
  T? entry<T extends ContextEntry>() => context.entry<T>();

  /// Returns a copy with [context] replaced.
  EventDispatchContext copyWith({EventContext? context}) =>
      EventDispatchContext(
        originalEvent: originalEvent,
        eventProvider: eventProvider,
        provider: provider,
        timestamp: timestamp,
        correlationId: correlationId,
        context: context ?? this.context,
      );
}
