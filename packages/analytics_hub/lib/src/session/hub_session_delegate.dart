import 'session.dart';

/// Supplies the current analytics [Session] and notifies when it changes.
///
/// [AnalyticsHub] uses this to get the initial session on [AnalyticsHub.initialize]
/// and to push session updates to all providers when [sessionStream] emits.
/// Implement with your app's auth/session logic (e.g. stream from a login service).
abstract interface class HubSessionDelegate {
  /// Returns the current session, or null if there is no active user/session.
  Future<Session?> getSession();

  /// Stream of session updates. Emit a new [Session?] on login/logout so
  /// [AnalyticsHub] can call [AnalytycsProvider.setSession] on all providers.
  Stream<Session?> get sessionStream;
}
