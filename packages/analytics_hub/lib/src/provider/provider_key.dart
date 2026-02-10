import '../event/event_resolver.dart';

abstract class ProviderKey<R extends EventResolver> {
  const ProviderKey({this.name});

  final String? name;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProviderKey<R> && other.name == name;
  }

  @override
  int get hashCode => name?.hashCode ?? 0;

  @override
  String toString() => 'ProviderKey<$R>(name: $name)';
}
