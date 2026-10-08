import 'context_entry.dart';

/// One entry of an [EventContext] together with the name of whoever added it.
///
/// [source] is `'event'` for entries declared on the event itself,
/// `'scope:<name>'` for entries contributed by an analytics scope, and
/// `'interceptor:<name>'` for entries an interceptor appended.
final class ContextRecord {
  /// Creates a record of [entry] attributed to [source].
  const ContextRecord({required this.entry, required this.source});

  /// The typed metadata.
  final ContextEntry entry;

  /// Who added [entry].
  final String source;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContextRecord && other.entry == entry && other.source == source;

  @override
  int get hashCode => Object.hash(entry, source);

  @override
  String toString() => '$source: $entry';
}
