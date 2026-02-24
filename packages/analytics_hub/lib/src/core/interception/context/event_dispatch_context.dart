import 'package:analytics_hub/src/event/events/events.dart';
import 'package:analytics_hub/src/provider/analytics_provider.dart';
import 'package:analytics_hub/src/provider/provider_identifier.dart';

import 'context.dart';
import 'context_entry.dart';

/// Context passed into each interceptor and resolver call.
class EventDispatchContext implements Context {
  /// Creates dispatch context for a single event-provider pair.
  EventDispatchContext({
    required this.originalEvent,
    required this.eventProvider,
    required this.provider,
    required this.timestamp,
    required this.correlationId,
  }) : _entries = Map.unmodifiable(originalEvent.context.entriesMap);

  EventDispatchContext._(this._entries, EventDispatchContext context)
      : originalEvent = context.originalEvent,
        eventProvider = context.eventProvider,
        provider = context.provider,
        timestamp = context.timestamp,
        correlationId = context.correlationId;

  /// Original user event before any overrides/interceptors.
  final Event originalEvent;

  /// Event target configuration (including per-provider options).
  final EventProvider eventProvider;

  /// Resolved provider instance for this dispatch.
  final AnalytycsProvider provider;

  /// Creation timestamp of this dispatch context.
  final DateTime timestamp;

  /// Correlation identifier to tie logs/interceptor actions together.
  final String correlationId;

  final Map<Type, ContextEntry> _entries;

  /// Identifier of the provider receiving this dispatch.
  ProviderIdentifier get providerIdentifier => eventProvider.identifier;

  @override
  Iterable<ContextEntry> get entries => _entries.values;

  @override
  bool get isEmpty => _entries.isEmpty;

  @override
  bool get isNotEmpty => !isEmpty;

  @override
  Map<Type, ContextEntry> get entriesMap => Map.unmodifiable(_entries);

  @override
  T? entry<T extends ContextEntry>() => _entries[T] as T?;

  @override
  EventDispatchContext withEntry<T extends ContextEntry>(T entry) {
    final nextEntries = Map<Type, ContextEntry>.from(_entries);
    nextEntries[T] = entry;
    return EventDispatchContext._(
      Map<Type, ContextEntry>.unmodifiable(nextEntries),
      this,
    );
  }

  @override
  EventDispatchContext updateEntry<T extends ContextEntry>(
    T Function(T entry) updater, {
    T Function()? ifAbsent,
  }) {
    final currentEntry = entry<T>();
    if (currentEntry == null) {
      if (ifAbsent == null) {
        return this;
      }
      return withEntry<T>(ifAbsent());
    }
    return withEntry<T>(updater(currentEntry));
  }

  /// Returns merged context where entries from [other] override current ones.
  EventDispatchContext merge(Context other) {
    final nextEntries = Map<Type, ContextEntry>.from(_entries);
    for (final MapEntry(:key, :value) in other.entriesMap.entries) {
      nextEntries[key] = value;
    }
    return EventDispatchContext._(
      Map<Type, ContextEntry>.unmodifiable(nextEntries),
      this,
    );
  }
}
