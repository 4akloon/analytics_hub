/// Represents the current user/session for analytics identification.
///
/// [AnalyticsHub] passes [Session] to [AnalytycsProvider.setSession] so providers
/// can identify the user (e.g. set user ID in Firebase, Mixpanel). Create from
/// your auth layer and emit via [HubSessionDelegate.sessionStream] when the
/// user logs in or out.
class Session {
  /// Creates a session with the given [id] (e.g. user ID, anonymous ID).
  const Session({required this.id});

  /// Unique identifier for this session/user (e.g. Firebase UID, Mixpanel distinct_id).
  final String id;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Session && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Session(id: $id)';
}
