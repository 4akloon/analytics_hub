/// Identifies an [AnalytycsProvider] for registration and event routing.
///
/// Each provider should use a distinct [ProviderIdentifier] subclass or
/// instance.
/// Events declare which providers receive them by including the corresponding
/// identifiers in [Event.providers].
///
/// Equality and [hashCode] are based on the runtime type and [name], so
/// identifiers of different subclasses never collide even when they share
/// the same name.
abstract class ProviderIdentifier {
  /// Creates a key with an optional [name] for debugging and equality.
  const ProviderIdentifier({this.name});

  /// Optional name (e.g. 'firebase', 'mixpanel'). Used for [==] and [hashCode].
  final String? name;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProviderIdentifier &&
        other.runtimeType == runtimeType &&
        other.name == name;
  }

  @override
  int get hashCode => Object.hash(runtimeType, name);

  @override
  String toString() => '$runtimeType(name: $name)';
}
