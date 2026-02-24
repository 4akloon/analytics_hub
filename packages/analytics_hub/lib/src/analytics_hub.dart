import 'dart:async';

import 'package:logging/logging.dart';

import 'core/interception/dispatch/context_builder.dart';
import 'core/interception/dispatch/correlation_id_generator.dart';
import 'core/interception/dispatch/dispatch_target.dart';
import 'core/interception/dispatch/event_dispatcher.dart';
import 'core/interception/interceptor/event_interceptor.dart';
import 'event/events/events.dart';
import 'provider/analytics_provider.dart';
import 'provider/provider_identifier.dart';
import 'session/hub_session_delegate.dart';
import 'session/session.dart';

/// Central hub that routes [Event]s to registered [AnalytycsProvider]s.
///
/// Create an [AnalyticsHub] with a list of [providers].
/// Optionally provide [sessionDelegate] to enable session propagation.
/// After [initialize], use [sendEvent] to send events to the providers specified
/// by each event's [Event.providers]. Session updates from [sessionDelegate]
/// are propagated to all providers automatically.
///
/// When done, call [dispose] to cancel session subscriptions and dispose
/// all providers.
class AnalyticsHub {
  /// Creates an [AnalyticsHub] with the given [providers] and optional [sessionDelegate].
  ///
  /// Each provider must have a unique [AnalytycsProvider.identifier]. Duplicate keys
  /// will overwrite earlier providers in the list.
  AnalyticsHub({
    required List<AnalytycsProvider> providers,
    HubSessionDelegate? sessionDelegate,
    List<EventInterceptor> interceptors = const [],
  })  : _providers = {
          for (final provider in providers) provider.identifier: provider,
        },
        _dispatcher = EventDispatcher(
          hubInterceptors: interceptors,
          contextBuilder: const EventDispatchContextBuilder(
            correlationIdGenerator: TimestampCorrelationIdGenerator(),
          ),
        ),
        _sessionDelegate = sessionDelegate {
    _sessionSubscription = _sessionDelegate?.sessionStream.listen(
      _onSessionChanged,
    );
  }

  final Map<ProviderIdentifier, AnalytycsProvider> _providers;
  final HubSessionDelegate? _sessionDelegate;
  final EventDispatcher _dispatcher;

  static final _logger = Logger('AnalyticsHub');

  StreamSubscription<Session?>? _sessionSubscription;

  /// Initializes the hub and all registered providers.
  ///
  /// Fetches the current session from [HubSessionDelegate.getSession], then
  /// calls [AnalytycsProvider.initialize] and [AnalytycsProvider.setSession]
  /// on each provider. Call this once after creating the hub (e.g. at app startup).
  Future<void> initialize() async {
    _logger.info('Initializing...');
    final session = await _sessionDelegate?.getSession();
    _logger.fine('Session: $session');
    await Future.wait(
      _providers.values.map((provider) async {
        await provider.initialize();
        if (_sessionDelegate != null) {
          await provider.setSession(session);
        }
      }),
    );
    _logger.info('Initialized!');
  }

  /// Sends [event] to every provider whose key is in [Event.providers].
  ///
  /// Throws [AnalyticsProviderNotFoundException] if the event references a
  /// provider key that was not registered with this hub. Returns a [Future]
  /// that completes when all targeted providers have finished handling the event.
  Future<void> sendEvent(Event event) {
    _logger.info('Sending event: $event');
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

  /// Cancels the session stream subscription and disposes all providers.
  ///
  /// Call this when the hub is no longer needed (e.g. app shutdown or scope exit).
  Future<void> dispose() async {
    _logger.info('Disposing...');
    await _sessionSubscription?.cancel();
    for (final provider in _providers.values) {
      await provider.dispose();
    }
    _logger.info('Disposed!');
  }

  Future<void> _onSessionChanged(Session? session) async {
    _logger.fine('Session changed: $session');
    await Future.wait(
      _providers.values.map((provider) => provider.setSession(session)),
    );
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
