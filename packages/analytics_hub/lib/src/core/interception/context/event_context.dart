import 'context_entry.dart';
import 'context_record.dart';

/// Immutable, append-only typed metadata attached to an event.
///
/// Records are kept in insertion order, root → leaf. A later record of the
/// same type is "nearer" and wins [entry], but earlier records stay, so a
/// reader can see every entry and who added it ([ContextRecord.source]).
/// Nothing is ever merged or replaced.
final class EventContext {
  /// Creates an empty context.
  const EventContext() : _records = const [];

  EventContext._(this._records);

  /// The source recorded for entries added without an explicit one.
  static const String eventSource = 'event';

  final List<ContextRecord> _records;

  /// Records in insertion order, root → leaf.
  List<ContextRecord> get records => List.unmodifiable(_records);

  /// Every entry in insertion order, without its source.
  Iterable<ContextEntry> get all => _records.map((record) => record.entry);

  /// Whether no record has been added.
  bool get isEmpty => _records.isEmpty;

  /// Whether at least one record has been added.
  bool get isNotEmpty => _records.isNotEmpty;

  /// The nearest entry of type [T] (the last one added), or `null`.
  ///
  /// Matches with `is`, so a sealed base type finds its subtypes.
  T? entry<T extends ContextEntry>() {
    for (var i = _records.length - 1; i >= 0; i--) {
      final entry = _records[i].entry;
      if (entry is T) return entry;
    }
    return null;
  }

  /// Every entry of type [T], root → leaf.
  Iterable<T> entries<T extends ContextEntry>() => all.whereType<T>();

  /// Returns a context with [entry] appended, attributed to [source].
  EventContext withEntry(
    ContextEntry entry, {
    String source = eventSource,
  }) =>
      EventContext._([
        ..._records,
        ContextRecord(entry: entry, source: source),
      ]);

  /// Returns a context with every entry of [entries] appended in order,
  /// all attributed to [source].
  EventContext withEntries(
    Iterable<ContextEntry> entries, {
    String source = eventSource,
  }) =>
      EventContext._([
        ..._records,
        for (final entry in entries)
          ContextRecord(entry: entry, source: source),
      ]);

  /// Returns a context with [other]'s records appended after this one's.
  ///
  /// Entries of [other] become the nearer ones. Returns `this` when [other]
  /// is empty.
  EventContext append(EventContext other) {
    if (other.isEmpty) return this;
    return EventContext._([..._records, ...other._records]);
  }

  /// Returns a copy with every record attributed to [source].
  EventContext attributedTo(String source) => EventContext._([
        for (final record in _records)
          ContextRecord(entry: record.entry, source: source),
      ]);
}
