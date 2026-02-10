import 'session.dart';

abstract interface class HubSessionDelegate {
  Future<Session?> getSession();

  Stream<Session?> get sessionStream;
}
