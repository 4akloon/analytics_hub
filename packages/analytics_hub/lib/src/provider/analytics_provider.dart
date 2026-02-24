import 'dart:async';

import '../core/interception/context/context.dart';
import '../core/interception/context/event_context.dart';
import '../core/interception/interceptor/event_interceptor.dart';
import '../event/event_resolver.dart';
import '../event/events/events.dart';
import '../session/session.dart';
import 'provider_identifier.dart';

/// Base class for an analytics backend (e.g. Firebase, Mixpanel) that can
/// receive events and session updates from [AnalyticsHub].
///
/// The hub uses [resolver] to dispatch [Event]s that target [identifier].
/// Override [initialize], [setSession], and [dispose] as needed.
abstract class AnalytycsProvider {
  /// Creates a provider with the given [identifier].
  ///
  /// The [identifier] must be unique among providers registered with the same
  /// [AnalyticsHub]; it is used to route events via [Event.providers].
  AnalytycsProvider({required this.identifier});

  /// Unique identifier identifying this provider for event routing.
  final ProviderIdentifier identifier;

  /// The resolver used by [AnalyticsHub] to send events to this provider.
  EventResolver get resolver;

  /// Optional provider-level interceptors executed after hub interceptors.
  List<EventInterceptor> get interceptors => const [];

  /// Additional typed context available in [EventDispatchContext.metadata].
  Context get interceptorContext => const EventContext();

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
