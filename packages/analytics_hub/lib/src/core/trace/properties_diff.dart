/// One property whose value a stage changed.
final class PropertyChange {
  /// Creates a change from [from] to [to].
  const PropertyChange({required this.from, required this.to});

  /// Value before the stage.
  final Object? from;

  /// Value after the stage.
  final Object? to;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PropertyChange && other.from == from && other.to == to;

  @override
  int get hashCode => Object.hash(from, to);

  @override
  String toString() => '$from -> $to';
}

/// What one pipeline stage did to an event's properties.
final class PropertiesDiff {
  /// Creates a diff from its parts.
  const PropertiesDiff({
    this.added = const {},
    this.changed = const {},
    this.removed = const {},
  });

  /// Computes the diff from [before] to [after]; `null` counts as empty.
  factory PropertiesDiff.between(
    Map<String, Object?>? before,
    Map<String, Object?>? after,
  ) {
    final from = before ?? const <String, Object?>{};
    final to = after ?? const <String, Object?>{};
    final added = <String, Object?>{};
    final changed = <String, PropertyChange>{};
    final removed = <String, Object?>{};

    for (final MapEntry(:key, :value) in to.entries) {
      if (!from.containsKey(key)) {
        added[key] = value;
      } else if (from[key] != value) {
        changed[key] = PropertyChange(from: from[key], to: value);
      }
    }
    for (final MapEntry(:key, :value) in from.entries) {
      if (!to.containsKey(key)) removed[key] = value;
    }

    return PropertiesDiff(
      added: Map.unmodifiable(added),
      changed: Map.unmodifiable(changed),
      removed: Map.unmodifiable(removed),
    );
  }

  /// Keys the stage introduced, with their values.
  final Map<String, Object?> added;

  /// Keys whose value the stage replaced.
  final Map<String, PropertyChange> changed;

  /// Keys the stage removed, with the values they had.
  final Map<String, Object?> removed;

  /// Whether the stage left the properties untouched.
  bool get isEmpty => added.isEmpty && changed.isEmpty && removed.isEmpty;

  /// Whether the stage changed at least one key.
  bool get isNotEmpty => !isEmpty;

  @override
  String toString() =>
      'PropertiesDiff(added: $added, changed: $changed, removed: $removed)';
}
