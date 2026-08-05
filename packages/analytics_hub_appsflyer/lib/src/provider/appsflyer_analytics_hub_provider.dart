import 'package:analytics_hub/analytics_hub.dart';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';

import '../resolver/appsflyer_event_resolver.dart';
import 'appsflyer_analytics_hub_provider_identifier.dart';

/// [AnalyticsProvider] that sends [Event]s to Appsflyer via [AppsflyerSdk].
///
/// The provider delegates event resolution to [AppsflyerEventResolver].
/// Customer user ID management ([AppsflyerSdk.setCustomerUserId]) is handled
/// by the app directly on the [AppsflyerSdk] instance.
class AppsflyerAnalyticsHubProvider extends AnalyticsProvider {
  /// Creates a provider that uses the given [appsFlyerSdk] instance.
  ///
  /// [name] is used for the provider identifier (e.g. for event routing).
  /// [interceptors] are provider-level interceptors executed after hub
  /// interceptors.
  AppsflyerAnalyticsHubProvider({
    required AppsflyerSdk appsFlyerSdk,
    String? name,
    super.interceptors = const [],
  })  : _appsFlyerSdk = appsFlyerSdk,
        super(
          identifier: AppsflyerAnalyticsHubIdentifier(name: name),
        );

  final AppsflyerSdk _appsFlyerSdk;

  @override
  AppsflyerEventResolver get resolver => AppsflyerEventResolver(_appsFlyerSdk);
}
