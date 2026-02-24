import 'context.dart';
import 'context_entry.dart';

/// Immutable typed metadata container similar to gql_exec `Context`.
///
/// Only one entry is stored per type. Adding another entry of the same type
/// replaces the previous one.
class EventContext implements Context {
  /// Creates an empty context.
  const EventContext() : _entries = const {};

  /// Creates a context from raw [entries] map.
  const EventContext._(this._entries);

  /// Internal storage keyed by entry runtime type.
  final Map<Type, ContextEntry> _entries;

  @override
  bool get isEmpty => _entries.isEmpty;

  @override
  bool get isNotEmpty => !isEmpty;

  @override
  Iterable<ContextEntry> get entries => _entries.values;

  @override
  Map<Type, ContextEntry> get entriesMap => Map.unmodifiable(_entries);

  @override
  T? entry<T extends ContextEntry>() => _entries[T] as T?;

  @override
  EventContext withEntry<T extends ContextEntry>(T entry) {
    final nextEntries = Map<Type, ContextEntry>.from(_entries);
    nextEntries[T] = entry;
    return EventContext._(
      Map<Type, ContextEntry>.unmodifiable(nextEntries),
    );
  }

  @override
  EventContext updateEntry<T extends ContextEntry>(
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
  EventContext merge(Context other) {
    var merged = this;
    for (final entry in other.entries) {
      merged = merged._withEntryByRuntimeType(entry);
    }
    return merged;
  }

  EventContext _withEntryByRuntimeType(ContextEntry entry) {
    final nextEntries = Map<Type, ContextEntry>.from(_entries);
    nextEntries[entry.runtimeType] = entry;
    return EventContext._(Map<Type, ContextEntry>.unmodifiable(nextEntries));
  }
}
