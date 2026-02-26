import 'package:analytics_hub/analytics_hub.dart';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:logging/logging.dart';

import '../resolver/appsflyer_event_resolver.dart';
import 'appsflyer_analytics_hub_provider_identifier.dart';

/// [AnalytycsProvider] that sends [Event]s to Appsflyer via [AppsflyerSdk].
///
/// The provider delegates event resolution to [AppsflyerEventResolver] and
/// synchronizes [Session.id] with Appsflyer using
/// [AppsflyerSdk.setCustomerUserId]. When the session becomes null,
/// [getAnonymousId] is used to set an anonymous customer user ID.
class AppsflyerAnalyticsHubProvider extends AnalytycsProvider {
  /// Creates a provider that uses the given [appsFlyerSdk] instance.
  ///
  /// [name] is used for the provider identifier (e.g. for event routing).
  /// [getAnonymousId] is called when session becomes null to set an anonymous
  /// ID instead of clearing.
  AppsflyerAnalyticsHubProvider({
    required AppsflyerSdk appsFlyerSdk,
    String? name,
    required String Function() getAnonymousId,
  })  : _appsFlyerSdk = appsFlyerSdk,
        _getAnonymousId = getAnonymousId,
        super(
          identifier: AppsflyerAnalyticsHubIdentifier(name: name),
          interceptors: const [],
        );

  final AppsflyerSdk _appsFlyerSdk;
  final String Function() _getAnonymousId;

  static final _logger = Logger('AppsflyerAnalyticsHubProvider');

  @override
  AppsflyerEventResolver get resolver => AppsflyerEventResolver(_appsFlyerSdk);

  @override
  Future<void> setSession(Session? session) async {
    if (session != null) {
      _appsFlyerSdk.setCustomerUserId(session.id);
    } else {
      final anonymousId = _getAnonymousId();
      _logger.fine('Identifying with anonymous ID: $anonymousId');
      _appsFlyerSdk.setCustomerUserId(anonymousId);
    }
  }

  @override
  void flush() {
    _logger.info('Flush is not supported for Appsflyer');
  }
}
