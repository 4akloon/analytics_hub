import '../event/event_resolver.dart';

/// Identifies an [AnalytycsProvider] for registration and event routing.
///
/// [R] is the [EventResolver] type of the provider. Each provider should use
/// a distinct [ProviderIdentifier] subclass or instance (e.g. [FirebaseAnalyticsHubProviderKey]).
/// Events declare which providers receive them by including the corresponding
/// identifiers in [Event.providers].
///
/// Equality and [hashCode] are based on [name] so keys with the same name
/// are considered the same provider.
abstract class ProviderIdentifier<R extends EventResolver> {
  /// Creates a key with an optional [name] for debugging and equality.
  const ProviderIdentifier({this.name});

  /// Optional name (e.g. 'firebase', 'mixpanel'). Used for [==] and [hashCode].
  final String? name;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProviderIdentifier<R> && other.name == name;
  }

  @override
  int get hashCode => name?.hashCode ?? 0;

  @override
  String toString() => 'ProviderIdentifier<$R>(name: $name)';
}
