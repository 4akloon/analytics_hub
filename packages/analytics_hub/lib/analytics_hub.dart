/// Analytics Hub — a unified analytics abstraction for Dart/Flutter apps.
///
/// This library lets you send events to multiple analytics backends (e.g. Firebase,
/// Mixpanel) through a single API. You register [AnalyticsProvider]s, then send
/// [Event]s; each event declares which providers should receive it via [Event.providers].
///
/// Example:
/// ```dart
/// final hub = AnalyticsHub(
///   providers: [firebaseProvider, mixpanelProvider],
/// );
/// await hub.sendEvent(MyLogEvent('button_clicked'));
/// ```
library;

export 'src/analytics_hub.dart';
export 'src/core/interception/context/context.dart';
export 'src/core/interception/context/context_entry.dart';
export 'src/core/interception/context/event_context.dart';
export 'src/core/interception/context/event_dispatch_context.dart';
export 'src/core/interception/context/resolved_event.dart';
export 'src/core/interception/interceptor/event_interceptor.dart';
export 'src/core/interception/interceptor/interceptor_result.dart';
export 'src/event/event_resolver.dart';
export 'src/event/events/events.dart';
export 'src/provider/analytics_provider.dart';
export 'src/provider/provider_identifier.dart';
