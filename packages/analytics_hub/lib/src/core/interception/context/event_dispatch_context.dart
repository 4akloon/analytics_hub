import 'package:analytics_hub/src/event/events/events.dart';
import 'package:analytics_hub/src/provider/analytics_provider.dart';
import 'package:analytics_hub/src/provider/provider_identifier.dart';

/// Context passed into each interceptor and resolver call.
class EventDispatchContext {
  /// Creates dispatch context for a single event-provider pair.
  const EventDispatchContext({
    required this.originalEvent,
    required this.providerIdentifier,
    required this.eventProvider,
    required this.provider,
    required this.timestamp,
    required this.correlationId,
    this.hubMetadata = const {},
    this.providerMetadata = const {},
  });

  /// Original user event before any overrides/interceptors.
  final Event originalEvent;

  /// Identifier of the provider receiving this dispatch.
  final ProviderIdentifier providerIdentifier;

  /// Event target configuration (including per-provider options).
  final EventProvider eventProvider;

  /// Resolved provider instance for this dispatch.
  final AnalytycsProvider provider;

  /// Creation timestamp of this dispatch context.
  final DateTime timestamp;

  /// Correlation identifier to tie logs/interceptor actions together.
  final String correlationId;

  /// Hub-level metadata configured in [AnalyticsHub].
  final Map<String, Object?> hubMetadata;

  /// Provider-level metadata configured in [AnalytycsProvider].
  final Map<String, Object?> providerMetadata;

  /// Creates a copy of this context with optional metadata replacements.
  EventDispatchContext copyWith({
    Map<String, Object?>? hubMetadata,
    Map<String, Object?>? providerMetadata,
  }) {
    return EventDispatchContext(
      originalEvent: originalEvent,
      providerIdentifier: providerIdentifier,
      eventProvider: eventProvider,
      provider: provider,
      timestamp: timestamp,
      correlationId: correlationId,
      hubMetadata: hubMetadata ?? this.hubMetadata,
      providerMetadata: providerMetadata ?? this.providerMetadata,
    );
  }
}
