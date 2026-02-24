import 'context_entry.dart';

/// Generic typed context contract.
abstract interface class Context {
  /// Returns entry by type or null if it is not present.
  T? entry<T extends ContextEntry>();

  /// Returns a new context containing [entry].
  Context withEntry<T extends ContextEntry>(T entry);

  /// Returns a new context with updated entry of type [T].
  Context updateEntry<T extends ContextEntry>(
    T Function(T entry) updater, {
    T Function()? ifAbsent,
  });

  /// Entries currently stored in the context.
  Iterable<ContextEntry> get entries;

  /// Entries currently stored in the context as a map.
  Map<Type, ContextEntry> get entriesMap;

  /// Whether context has no entries.
  bool get isEmpty;

  /// Whether context contains at least one entry.
  bool get isNotEmpty;
}
