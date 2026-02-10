## Analytics Hub

This repository contains the **analytics_hub** family of packages – a small,
strongly‑typed abstraction over multiple analytics SDKs (Firebase, Mixpanel, and
custom providers).

- **Single event model** – describe events once in Dart and send them to
  multiple analytics backends.
- **Provider abstraction** – plug in/out specific SDKs without touching
  business logic.
- **Centralized session handling** – manage a `Session` once, propagate it
  to all providers.

Per‑package documentation:

- `packages/analytics_hub` – core types and hub:
  - [English](packages/analytics_hub/README.md)
  - [Українська](packages/analytics_hub/README.ua.md)
- `packages/analytics_hub_firebase` – Firebase Analytics provider:
  - [English](packages/analytics_hub_firebase/README.md)
  - [Українська](packages/analytics_hub_firebase/README.ua.md)
- `packages/analytics_hub_mixpanel` – Mixpanel provider:
  - [English](packages/analytics_hub_mixpanel/README.md)
  - [Українська](packages/analytics_hub_mixpanel/README.ua.md)

## Packages overview

- **`analytics_hub`**
  - Core abstractions:
    - `AnalyticsHub`, `Event`, `LogEvent`, `CustomLogEvent<T>`,
      `ECommerceEvent`, `Session`, `HubSessionDelegate`.
    - `AnalytycsProvider<R extends EventResolver>`,
      `ProviderKey<R>`, resolver interfaces.
  - No direct SDK dependencies – pure Dart.

- **`analytics_hub_firebase`**
  - Binds `analytics_hub` to `firebase_analytics`.
  - Supports:
    - `LogEvent` → `FirebaseAnalytics.logEvent`.
    - `SelectPromotionECommerceEvent` → `FirebaseAnalytics.logSelectPromotion`.

- **`analytics_hub_mixpanel`**
  - Binds `analytics_hub` to `mixpanel_flutter`.
  - Supports:
    - `LogEvent` → `Mixpanel.track`.

## Quick start (app level)

Add dependencies in your app:

```yaml
dependencies:
  analytics_hub: ^0.0.1
  analytics_hub_firebase: ^0.0.1
  analytics_hub_mixpanel: ^0.0.1

  firebase_core: ^2.0.0
  firebase_analytics: ^10.0.0
  mixpanel_flutter: ^2.0.0
```

Basic setup with Firebase + Mixpanel:

```dart
import 'package:analytics_hub/analytics_hub.dart';
import 'package:analytics_hub_firebase/analytics_hub_firebase.dart';
import 'package:analytics_hub_mixpanel/analytics_hub_mixpanel.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

class AppSessionDelegate implements HubSessionDelegate {
  AppSessionDelegate(this._sessionStream);

  final Stream<Session?> _sessionStream;

  @override
  Stream<Session?> get sessionStream => _sessionStream;

  @override
  Future<Session?> getSession() async => _sessionStream.first;
}

class ExampleLogEvent extends LogEvent {
  const ExampleLogEvent({required this.value}) : super('example_log_event');

  final String value;

  @override
  Map<String, Object>? get properties => {'value': value};

  @override
  Set<ProviderKey<LogEventResolver>> get providerKeys => {
        const FirebaseAnalyticsHubProviderKey(),
        const MixpanelAnalyticsHubProviderKey(),
      };
}

Future<AnalyticsHub> createAnalyticsHub(
  Stream<Session?> sessionStream,
) async {
  await Firebase.initializeApp();

  final mixpanel = await Mixpanel.init(
    'YOUR_MIXPANEL_TOKEN',
    trackAutomaticEvents: false,
  );

  final hub = AnalyticsHub(
    sessionDelegate: AppSessionDelegate(sessionStream),
    providers: [
      FirebaseAnalyticsHubProvider.fromInstance(),
      MixpanelAnalyticsHubProvider(mixpanel: mixpanel),
    ],
  );

  await hub.initialize();
  return hub;
}
```

Sending an event:

```dart
final hub = await createAnalyticsHub(sessionStream);
await hub.sendEvent(const ExampleLogEvent(value: 'clicked_button'));
```

This will fan‑out the same typed event to both Firebase and Mixpanel.

## Implementing your own provider

If you want to add another analytics backend (or internal pipeline):

- implement a `ProviderKey<R>` for your resolver type;
- implement a resolver (`EventResolver` + the interfaces you need:
  `LogEventResolver`, `CustomLogEventResolver<T>`, `ECommerceEventResolver`);
- implement an `AnalytycsProvider<R>` that:
  - exposes the resolver,
  - wires session handling (`setSession`),
  - initializes / disposes the underlying SDK.

See the core package docs for a full step‑by‑step guide:

- [`packages/analytics_hub/README.md`](/packages/analytics_hub/README.md
)
