import 'package:analytics_hub/analytics_hub.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

/// Resolver that forwards [LogEvent]s to Mixpanel via [Mixpanel.track].
///
/// Used internally by [MixpanelAnalyticsHubProvider]. Event [name] and
/// [LogEvent.properties] are sent as the Mixpanel event name and properties.
class MixpanelEventResolver implements EventResolver, LogEventResolver {
  /// Creates a resolver that uses the given [Mixpanel] instance.
  MixpanelEventResolver(this._mixpanel);

  final Mixpanel _mixpanel;

  @override
  Future<void> resolveLogEvent(LogEvent event) =>
      _mixpanel.track(event.name, properties: event.properties);
}
