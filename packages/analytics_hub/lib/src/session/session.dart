class Session {
  const Session({required this.id});

  final String id;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Session && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Session(id: $id)';
}
