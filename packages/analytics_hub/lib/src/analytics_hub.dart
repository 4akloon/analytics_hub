import 'dart:async';

import 'package:logging/logging.dart';

import 'event/event.dart';
import 'provider/analytics_provider.dart';
import 'provider/provider_key.dart';
import 'session/hub_session_delegate.dart';
import 'session/session.dart';

class AnalyticsHub {
  AnalyticsHub({
    required List<AnalytycsProvider> providers,
    required HubSessionDelegate sessionDelegate,
  })  : _providers = {for (final provider in providers) provider.key: provider},
        _logger = Logger('AnalyticsHub'),
        _sessionDelegate = sessionDelegate {
    _sessionSubscription = _sessionDelegate.sessionStream.listen(
      _onSessionChanged,
    );
  }

  final Map<ProviderKey, AnalytycsProvider> _providers;
  final HubSessionDelegate _sessionDelegate;
  final Logger _logger;

  late final StreamSubscription<Session?> _sessionSubscription;

  Future<void> initialize() async {
    _logger.info('Initializing...');
    final session = await _sessionDelegate.getSession();
    _logger.fine('Session: $session');
    await Future.wait(
      _providers.values.map((provider) async {
        await provider.initialize();
        await provider.setSession(session);
      }),
    );
    _logger.info('Initialized!');
  }

  Future<void> sendEvent(Event event) {
    _logger.info('Sending event: $event');
    return Future.wait(
      event.providerKeys.map((key) {
        final provider = _providers[key];
        if (provider == null) {
          throw AnalyticsProviderNotFoundException(key);
        }

        return event.resolve(provider.resolver);
      }),
    );
  }

  Future<void> dispose() async {
    _logger.info('Disposing...');
    await _sessionSubscription.cancel();
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

class AnalyticsProviderNotFoundException implements Exception {
  const AnalyticsProviderNotFoundException(this.key);

  final ProviderKey key;

  @override
  String toString() => 'AnalyticsProviderNotFoundException(key: $key)';
}
