import 'dart:async';

import '../core/interception/interceptor/event_interceptor.dart';
import '../event/event_resolver.dart';
import '../event/events/events.dart';
import 'provider_identifier.dart';

/// Base class for an analytics backend (e.g. Firebase, Mixpanel) that can
/// receive events from [AnalyticsHub].
///
/// The hub uses [resolver] to dispatch [Event]s that target [identifier].
/// Override [flush] if the backend buffers events. SDK lifecycle belongs in
/// the app — pass an already-initialized backend instance into the constructor.
abstract class AnalyticsProvider {
  /// Creates a provider with the given [identifier].
  ///
  /// The [identifier] must be unique among providers registered with the same
  /// [AnalyticsHub]; it is used to route events via [Event.providers].
  const AnalyticsProvider({
    required this.identifier,
    required this.interceptors,
  });

  /// Unique identifier identifying this provider for event routing.
  final ProviderIdentifier identifier;

  /// Optional provider-level interceptors executed after hub interceptors.
  final List<EventInterceptor> interceptors;

  /// The resolver used by [AnalyticsHub] to send events to this provider.
  EventResolver get resolver;

  /// Called by [AnalyticsHub.flush]. Override to flush any pending events.
  /// Default implementation does nothing.
  FutureOr<void> flush() {}
}
