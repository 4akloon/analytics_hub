import 'package:logging/logging.dart';

import 'analytics_sink.dart';
import 'core/interception/dispatch/context_builder.dart';
import 'core/interception/dispatch/correlation_id_generator.dart';
import 'core/interception/dispatch/dispatch_target.dart';
import 'core/interception/dispatch/event_dispatcher.dart';
import 'core/interception/dispatch/event_snapshot.dart';
import 'core/interception/interceptor/event_interceptor.dart';
import 'event/events/events.dart';
import 'provider/analytics_provider.dart';
import 'provider/provider_identifier.dart';
import 'scope/analytics_scope.dart';

/// Central hub that routes [Event]s to registered [AnalyticsProvider]s.
///
/// Create an [AnalyticsHub] with a list of [providers], then use [sendEvent]
/// to send events to the providers specified by each event's [Event.providers].
/// Pass a [AnalyticsScope] to [sendEvent], or wrap the hub in
/// `ScopedAnalytics`, to apply scoped context and interceptors.
///
/// Call [flush] before app shutdown if any provider buffers events.
class AnalyticsHub implements AnalyticsSink {
  /// Creates an [AnalyticsHub] with the given [providers].
  ///
  /// Each provider must have a unique [AnalyticsProvider.identifier]. Duplicate keys
  /// will overwrite earlier providers in the list.
  AnalyticsHub({
    required List<AnalyticsProvider> providers,
    List<EventInterceptor> interceptors = const [],
    CorrelationIdGenerator correlationIdGenerator =
        const TimestampCorrelationIdGenerator(),
  })  : _providers = {
          for (final provider in providers) provider.identifier: provider,
        },
        _correlationIdGenerator = correlationIdGenerator,
        _dispatcher = EventDispatcher(
          hubInterceptors: interceptors,
          contextBuilder: const EventDispatchContextBuilder(),
        );

  final Map<ProviderIdentifier, AnalyticsProvider> _providers;
  final CorrelationIdGenerator _correlationIdGenerator;
  final EventDispatcher _dispatcher;

  static final _logger = Logger('AnalyticsHub');

  /// Sends [event] to every provider whose key is in [Event.providers].
  ///
  /// The event's name, properties, context and providers are read
  /// synchronously before anything asynchronous starts. With [scope], the
  /// scope chain's context precedes the event's and the chain's interceptors
  /// run before the hub's.
  ///
  /// Throws [AnalyticsProviderNotFoundException] if the event references a
  /// provider key that was not registered with this hub. Returns a [Future]
  /// that completes when all targeted providers have finished handling the event.
  @override
  Future<void> sendEvent(Event event, {AnalyticsScope? scope}) {
    _logger.fine('Sending event: $event');
    final snapshot = EventSnapshot.of(event);
    final scopes = scope?.chain ?? const <AnalyticsScope>[];
    final correlationId = _correlationIdGenerator.nextCorrelationId();

    return Future.wait(
      snapshot.providers.map((eventProvider) async {
        final provider = _providers[eventProvider.identifier];
        if (provider == null) {
          throw AnalyticsProviderNotFoundException(eventProvider.identifier);
        }

        final result = await _dispatcher.dispatch(
          snapshot: snapshot,
          target: DispatchTarget(
            eventProvider: eventProvider,
            provider: provider,
          ),
          correlationId: correlationId,
          scopes: scopes,
        );

        if (result.isDropped) {
          _logger.fine(
            'Event dropped by interceptors: ${snapshot.name} for ${provider.identifier}',
          );
        }
      }),
    );
  }

  /// Flushes all providers.
  ///
  /// Useful before app shutdown to ensure buffered events are sent.
  Future<void> flush() async {
    for (final provider in _providers.values) {
      await provider.flush();
    }
  }
}

/// Thrown when [AnalyticsHub.sendEvent] is called with an event that targets
/// a [ProviderIdentifier] not registered with the hub.
class AnalyticsProviderNotFoundException implements Exception {
  /// Creates an exception for the missing [key].
  const AnalyticsProviderNotFoundException(this.key);

  /// The provider key that was requested but not found.
  final ProviderIdentifier key;

  @override
  String toString() => 'AnalyticsProviderNotFoundException(key: $key)';
}
