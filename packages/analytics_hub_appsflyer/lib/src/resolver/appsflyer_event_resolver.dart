import 'package:analytics_hub/analytics_hub.dart';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';

/// Resolver that forwards [Event]s to Appsflyer via [AppsflyerSdk.logEvent].
///
/// Used internally by [AppsflyerAnalyticsHubProvider]. Event [name] and
/// [Event.properties] are sent as the Appsflyer event name and values.
class AppsflyerEventResolver implements EventResolver {
  /// Creates a resolver that uses the given [AppsflyerSdk] instance.
  AppsflyerEventResolver(this._appsFlyerSdk);

  final AppsflyerSdk _appsFlyerSdk;

  @override
  Future<void> resolve(
    ResolvedEvent event, {
    required EventDispatchContext context,
  }) async {
    final values = switch (event.properties) {
      null => null,
      final properties => Map<String, dynamic>.fromEntries(
          properties.entries.where((entry) => entry.value != null).map(
                (entry) => MapEntry(entry.key, entry.value as Object),
              ),
        ),
    };

    await _appsFlyerSdk.logEvent(
      event.name,
      values,
    );
  }
}
