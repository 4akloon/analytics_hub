import 'package:logging/logging.dart';

import 'core/interception/dispatch/context_builder.dart';
import 'core/interception/dispatch/correlation_id_generator.dart';
import 'core/interception/dispatch/dispatch_target.dart';
import 'core/interception/dispatch/event_dispatcher.dart';
import 'core/interception/interceptor/event_interceptor.dart';
import 'event/events/events.dart';
import 'provider/analytics_provider.dart';
import 'provider/provider_identifier.dart';

/// Central hub that routes [Event]s to registered [AnalyticsProvider]s.
///
/// Create an [AnalyticsHub] with a list of [providers].
/// After [initialize], use [sendEvent] to send events to the providers specified
/// by each event's [Event.providers].
///
/// When done, call [dispose] to dispose all providers.
class AnalyticsHub {
  /// Creates an [AnalyticsHub] with the given [providers].
  ///
  /// Each provider must have a unique [AnalyticsProvider.identifier]. Duplicate keys
  /// will overwrite earlier providers in the list.
  AnalyticsHub({
    required List<AnalyticsProvider> providers,
    List<EventInterceptor> interceptors = const [],
  })  : _providers = {
          for (final provider in providers) provider.identifier: provider,
        },
        _dispatcher = EventDispatcher(
          hubInterceptors: interceptors,
          contextBuilder: const EventDispatchContextBuilder(
            correlationIdGenerator: TimestampCorrelationIdGenerator(),
          ),
        );

  final Map<ProviderIdentifier, AnalyticsProvider> _providers;
  final EventDispatcher _dispatcher;

  static final _logger = Logger('AnalyticsHub');

  /// Initializes the hub and all registered providers.
  ///
  /// Calls [AnalyticsProvider.initialize] on each provider sequentially.
  /// Call this once after creating the hub (e.g. at app startup).
  Future<void> initialize() async {
    _logger.info('Initializing...');
    await Future.forEach(
      _providers.values,
      (provider) async => provider.initialize(),
    );
    _logger.info('Initialized!');
  }

  /// Sends [event] to every provider whose key is in [Event.providers].
  ///
  /// Throws [AnalyticsProviderNotFoundException] if the event references a
  /// provider key that was not registered with this hub. Returns a [Future]
  /// that completes when all targeted providers have finished handling the event.
  Future<void> sendEvent(Event event) {
    _logger.fine('Sending event: $event');
    return Future.wait(
      event.providers.map((eventProvider) async {
        final provider = _providers[eventProvider.identifier];
        if (provider == null) {
          throw AnalyticsProviderNotFoundException(eventProvider.identifier);
        }

        final result = await _dispatcher.dispatch(
          event: event,
          target: DispatchTarget(
            eventProvider: eventProvider,
            provider: provider,
          ),
        );

        if (result.isDropped) {
          _logger.fine(
            'Event dropped by interceptors: ${event.name} for ${provider.identifier}',
          );
        }
      }),
    );
  }

  /// Flushes all providers.
  ///
  /// This is useful to ensure that all events are sent to the providers before the app is closed.
  Future<void> flush() async {
    for (final provider in _providers.values) {
      await provider.flush();
    }
  }

  /// Disposes all providers.
  ///
  /// Call this when the hub is no longer needed (e.g. app shutdown or scope exit).
  Future<void> dispose() async {
    _logger.info('Disposing...');
    for (final provider in _providers.values) {
      await provider.dispose();
    }
    _logger.info('Disposed!');
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
