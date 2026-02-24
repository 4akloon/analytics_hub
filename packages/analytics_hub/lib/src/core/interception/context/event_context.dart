/// Marker base class for typed metadata entries stored in [EventContext].
abstract base class EventContextEntry {
  /// Creates a typed context entry marker.
  const EventContextEntry();
}

/// Immutable typed metadata container similar to gql_exec `Context`.
///
/// Only one entry is stored per type. Adding another entry of the same type
/// replaces the previous one.
class EventContext {
  /// Creates an empty context.
  const EventContext() : _entries = const {};

  /// Creates a context from raw [entries] map.
  const EventContext._(this._entries);

  /// Internal storage keyed by entry runtime type.
  final Map<Type, EventContextEntry> _entries;

  /// Returns entry by type or null if it is not present.
  T? entry<T extends EventContextEntry>() => _entries[T] as T?;

  /// Returns a new context containing [entry].
  ///
  /// If an entry with the same type already exists, it is replaced.
  EventContext withEntry<T extends EventContextEntry>(T entry) {
    final nextEntries = Map<Type, EventContextEntry>.from(_entries);
    nextEntries[T] = entry;
    return EventContext._(
      Map<Type, EventContextEntry>.unmodifiable(nextEntries),
    );
  }

  /// Returns a new context with updated entry of type [T].
  ///
  /// If there is no current entry and [ifAbsent] is null, returns this context.
  EventContext updateEntry<T extends EventContextEntry>(
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

  /// Entries currently stored in the context.
  Iterable<EventContextEntry> get entries => _entries.values;

  /// Whether context has no entries.
  bool get isEmpty => _entries.isEmpty;

  /// Whether context contains at least one entry.
  bool get isNotEmpty => !isEmpty;
}
