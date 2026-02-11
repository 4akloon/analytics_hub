/// Analytics Hub — a unified analytics abstraction for Dart/Flutter apps.
///
/// This library lets you send events to multiple analytics backends (e.g. Firebase,
/// Mixpanel) through a single API. You register [AnalytycsProvider]s, then send
/// [Event]s; each event declares which providers should receive it via [Event.providerKeys].
///
/// Session handling is delegated to [HubSessionDelegate], so user identity can be
/// updated when the session changes (e.g. login/logout).
///
/// Example:
/// ```dart
/// final hub = AnalyticsHub(
///   providers: [firebaseProvider, mixpanelProvider],
///   sessionDelegate: mySessionDelegate,
/// );
/// await hub.initialize();
/// await hub.sendEvent(MyLogEvent('button_clicked'));
/// ```
library;

export 'src/analytics_hub.dart';
export 'src/event/event.dart';
export 'src/event/event_resolver.dart';
export 'src/provider/analytics_provider.dart';
export 'src/provider/provider_key.dart';
export 'src/session/hub_session_delegate.dart';
export 'src/session/session.dart';
