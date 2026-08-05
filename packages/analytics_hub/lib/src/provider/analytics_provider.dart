import 'dart:async';

import '../core/interception/interceptor/event_interceptor.dart';
import '../event/event_resolver.dart';
import '../event/events/events.dart';
import 'provider_identifier.dart';

/// Base class for an analytics backend (e.g. Firebase, Mixpanel) that can
/// receive events from [AnalyticsHub].
///
/// The hub uses [resolver] to dispatch [Event]s that target [identifier].
/// Override [initialize], [flush], and [dispose] as needed.
abstract class AnalytycsProvider {
  /// Creates a provider with the given [identifier].
  ///
  /// The [identifier] must be unique among providers registered with the same
  /// [AnalyticsHub]; it is used to route events via [Event.providers].
  const AnalytycsProvider({
    required this.identifier,
    required this.interceptors,
  });

  /// Unique identifier identifying this provider for event routing.
  final ProviderIdentifier identifier;

  /// Optional provider-level interceptors executed after hub interceptors.
  final List<EventInterceptor> interceptors;

  /// The resolver used by [AnalyticsHub] to send events to this provider.
  EventResolver get resolver;

  /// Called once by [AnalyticsHub.initialize]. Override to set up the backend
  /// (e.g. SDK init). Default implementation does nothing.
  FutureOr<void> initialize() async {}

  /// Called by [AnalyticsHub.flush]. Override to flush any pending events.
  /// Default implementation does nothing.
  FutureOr<void> flush() {}

  /// Called by [AnalyticsHub.dispose]. Override to clean up (e.g. close SDK).
  /// Default implementation does nothing.
  FutureOr<void> dispose() {}
}
