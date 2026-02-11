import 'dart:async';

import '../event/event_resolver.dart';
import '../session/session.dart';
import 'provider_key.dart';

/// Base class for an analytics backend (e.g. Firebase, Mixpanel) that can
/// receive events and session updates from [AnalyticsHub].
///
/// [R] is the [EventResolver] type this provider implements. The hub uses
/// [resolver] to dispatch [Event]s that target [key]. Override [initialize],
/// [setSession], and [dispose] as needed.
abstract class AnalytycsProvider<R extends EventResolver> {
  /// Creates a provider with the given [key].
  ///
  /// The [key] must be unique among providers registered with the same
  /// [AnalyticsHub]; it is used to route events via [Event.providerKeys].
  AnalytycsProvider({required this.key});

  /// Unique key identifying this provider for event routing.
  final ProviderKey<R> key;

  /// The resolver used by [AnalyticsHub] to send events to this provider.
  R get resolver;

  /// Called once by [AnalyticsHub.initialize]. Override to set up the backend
  /// (e.g. SDK init). Default implementation does nothing.
  FutureOr<void> initialize() async {}

  /// Called when the current session changes (e.g. login/logout).
  ///
  /// [AnalyticsHub] calls this on every provider when [HubSessionDelegate.sessionStream]
  /// emits a new [Session?]. Use it to identify the user in your backend.
  Future<void> setSession(Session? session);

  /// Called by [AnalyticsHub.dispose]. Override to clean up (e.g. close SDK).
  /// Default implementation does nothing.
  FutureOr<void> dispose() {}
}
