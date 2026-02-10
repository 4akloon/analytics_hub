import 'package:analytics_hub/analytics_hub.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

class MixpanelEventResolver implements EventResolver, LogEventResolver {
  MixpanelEventResolver(this._mixpanel);

  final Mixpanel _mixpanel;

  @override
  Future<void> resolveLogEvent(LogEvent event) =>
      _mixpanel.track(event.name, properties: event.properties);
}
