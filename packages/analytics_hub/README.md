## Analytics Hub

[![Pub Version](https://img.shields.io/pub/v/analytics_hub.svg)](https://pub.dev/packages/analytics_hub)
[![Pub Likes](https://img.shields.io/pub/likes/analytics_hub.svg)](https://pub.dev/packages/analytics_hub)
[![Pub Points](https://img.shields.io/pub/points/analytics_hub.svg)](https://pub.dev/packages/analytics_hub)
[![Platform](https://img.shields.io/badge/platform-dart%20%7C%20flutter-blue.svg)](https://dart.dev)

> This documentation is also available in [Ukrainian](README.ua.md).

**analytics_hub** is a small aggregation layer on top of analytics SDKs
such as Firebase, Mixpanel, and your own providers.

### Essence of the solution

In one sentence: **you describe analytics as strongly‑typed Dart events once,
and `analytics_hub` fan‑outs them to any number of providers (Firebase, Mixpanel, in‑house) via a single API**.

### Features

- **Unified event model** (log, custom, e‑commerce) shared across providers.
- **Single entry point** (`AnalyticsHub`) instead of talking to each SDK directly.
- **Centralized session management** that propagates a `Session` to all providers.
- Easy to **add or remove providers** without touching business logic.

### When you might want it

- You send the **same logical event** to multiple analytics SDKs.
- You want to **decouple domain/UI code** from concrete analytics dependencies.
- You need **centralized session and configuration management** for analytics.
- You want to be able to toggle providers on/off per environment or product.

Current providers (each has its own README with integration steps):

- **Firebase:** [analytics_hub_firebase](https://pub.dev/packages/analytics_hub_firebase) — log events + e‑commerce (`SelectPromotion`, etc.)
- **Mixpanel:** [analytics_hub_mixpanel](https://pub.dev/packages/analytics_hub_mixpanel) — log events

## Installation

In your app `pubspec.yaml`:

```yaml
dependencies:
  analytics_hub: ^0.0.1
  # and then any concrete providers you need, e.g.:
  # analytics_hub_firebase: ^0.0.1
  # analytics_hub_mixpanel: ^0.0.1
```

## Core concepts

- **`AnalyticsHub`** – the facade you use to send events.
- **`Event`** – base sealed class for all events.
- **`LogEvent`** – simple `name + properties` event.
- **`CustomLogEvent<T>`** – strongly typed custom events for a specific resolver.
- **`ECommerceEvent`** – e‑commerce events (currently `SelectPromotionECommerceEvent`).
- **`AnalytycsProvider<R extends EventResolver>`** – abstraction of an analytics provider.
- **`EventResolver` / `LogEventResolver` / `CustomLogEventResolver<T>` / `ECommerceEventResolver`** –
  interfaces used to map events into concrete SDK calls.
- **`ProviderKey<R>`** – identifies a provider; events list keys of the providers they should go to.
- **`Session` / `HubSessionDelegate`** – session model plus a delegate that supplies the current
  session and a stream of session changes.

## Event types defined by analytics_hub

The `analytics_hub` package defines the **types** of events. Each provider decides which
types it actually supports.

### Log events (`LogEvent`)

- Defined by `name` and optional `properties` (`Map<String, Object>`).
- Supported by any provider that implements `LogEventResolver`, e.g.:
  - Firebase (`analytics_hub_firebase`)
  - Mixpanel (`analytics_hub_mixpanel`)
  - your custom providers

### Custom log events (`CustomLogEvent<T>`)

- Allow **strongly typed** event hierarchies understood by a custom resolver.
- Used together with `CustomLogEventResolver<T>`.
- See `example/analytics_core_example.dart` for a complete example.

### E‑commerce events (`ECommerceEvent`)

Base sealed class for e‑commerce events. Currently core provides:

- **`SelectPromotionECommerceEvent`**
  - wraps `SelectPromotionECommerceEventData` with:
    - `creativeName`
    - `creativeSlot`
    - `locationId`
    - `promotionId`
    - `promotionName`
    - `parameters` (`Map<String, Object>?`)

Provider support:

- **Firebase** (`analytics_hub_firebase`):
  - `SelectPromotionECommerceEvent` → `FirebaseAnalytics.logSelectPromotion`.
- **Mixpanel** (`analytics_hub_mixpanel`):
  - currently **does not support** `ECommerceEvent`, only `LogEvent`.

**Planned e‑commerce extension:**

- New `ECommerceEvent` subtypes for common GA4 scenarios:
  - `view_item`, `view_item_list`, `select_item`,
  - `add_to_cart`, `add_to_wishlist`,
  - `begin_checkout`, `add_payment_info`, `add_shipping_info`,
  - `purchase`, `refund`, etc.
- Matching mappings in Firebase / Mixpanel providers.

## Quick start

Example with a custom provider (simplified from `example/analytics_core_example.dart`):

```dart
import 'package:analytics_hub/analytics_hub.dart';

class AuthSessionDelegate implements HubSessionDelegate {
  AuthSessionDelegate(this._auth);

  final AuthManager _auth;

  @override
  Stream<Session?> get sessionStream =>
      _auth.authStateStream.map((user) => user != null ? Session(id: user.id) : null);

  @override
  Future<Session?> getSession() async {
    final user = await _auth.currentUser;
    return user != null ? Session(id: user.id) : null;
  }
}

void main() async {
  final auth = yourAuthManager; // e.g. from DI or app state

  final hub = AnalyticsHub(
    sessionDelegate: AuthSessionDelegate(auth),
    providers: [
      BackendAnalyticsProvider(),
    ],
  );

  await hub.initialize();

  await hub.sendEvent(
    ScreenViewEvent(
      screenName: 'home',
      screenClass: HomeScreen,
    ),
  );

  await hub.dispose();
}
```

## Defining events

### Log event (`LogEvent`)

```dart
class ScreenViewEvent extends LogEvent {
  const ScreenViewEvent({
    required this.screenName,
    required this.screenClass,
  }) : super('screen_view');

  final String screenName;
  final Type screenClass;

  @override
  Map<String, Object>? get properties => {
        'screen_name': screenName,
        'screen_class': screenClass.toString(),
      };

  @override
  Set<ProviderKey<LogEventResolver>> get providerKeys => {
        const BackendAnalyticsProviderKey(),
        // or FirebaseAnalyticsHubProviderKey(), MixpanelAnalyticsHubProviderKey(), etc.
      };
}
```

Key points:

- **`name`** – technical event name (e.g. for dashboards).
- **`properties`** – payload that will be passed to providers.
- **`providerKeys`** – which providers should receive this event.

### Custom log events (`CustomLogEvent<T>`)

```dart
sealed class OnboardingAnalyticsEvent
    extends CustomLogEvent<OnboardingAnalyticsEvent> {
  const OnboardingAnalyticsEvent();
}

class OnboardingStepCompletedEvent extends OnboardingAnalyticsEvent {
  const OnboardingStepCompletedEvent({
    required this.stepId,
    this.durationMs,
  });

  final String stepId;
  final int? durationMs;

  @override
  Set<ProviderKey<CustomLogEventResolver<OnboardingAnalyticsEvent>>>
      get providerKeys => {const BackendAnalyticsProviderKey()};
}
```

The idea:

- you design your own event hierarchy;
- the resolver (`CustomLogEventResolver<OnboardingAnalyticsEvent>`) decides how to handle each subtype (e.g. map to your backend schema).

### E‑commerce `SelectPromotionECommerceEvent`

```dart
class PromoBannerClickEvent extends SelectPromotionECommerceEvent {
  const PromoBannerClickEvent({
    required this.bannerId,
    required this.creativeName,
    this.placement,
  });

  final String bannerId;
  final String creativeName;
  final String? placement;

  @override
  SelectPromotionECommerceEventData get data =>
      SelectPromotionECommerceEventData(
        creativeName: creativeName,
        locationId: placement,
        promotionId: bannerId,
      );

  @override
  Set<ProviderKey<ECommerceEventResolver>> get providerKeys => {
        const FirebaseAnalyticsHubProviderKey(), // from analytics_hub_firebase
      };
}
```

## Implementing your own provider (step‑by‑step)

A custom provider (e.g. sending events to your backend) consists of:

1. **Provider key** (`ProviderKey<R>`).
2. **Event resolver(s)** (`EventResolver` + required interfaces).
3. **Provider class** (`AnalytycsProvider<R>`) registered in `AnalyticsHub`.

### 1. Provider key (`ProviderKey`)

```dart
import 'package:analytics_hub/analytics_hub.dart';

class BackendAnalyticsProviderKey extends ProviderKey<BackendEventResolver> {
  const BackendAnalyticsProviderKey({super.name});
}
```

- `R` in `ProviderKey<R>` is the type of your main resolver.
- `name` can be used to distinguish multiple instances
  (e.g. multiple Firebase projects or Mixpanel workspaces).

### 2. Event resolver (`EventResolver` + interfaces)

```dart
import 'package:analytics_hub/analytics_hub.dart';

class BackendEventResolver
    implements
        EventResolver,
        LogEventResolver,
        CustomLogEventResolver<OnboardingAnalyticsEvent> {
  const BackendEventResolver();

  @override
  Future<void> resolveLogEvent(LogEvent event) async {
    // e.g. POST event.name + event.properties to your backend
  }

  @override
  Future<void> resolveCustomLogEvent(
    CustomLogEvent<OnboardingAnalyticsEvent> event,
  ) async {
    // map onboarding events to your backend schema
  }
}
```

You only implement the interfaces that your provider needs:

- `LogEventResolver` – for simple log events;
- `CustomLogEventResolver<T>` – for strongly typed custom scenarios;
- `ECommerceEventResolver` – for e‑commerce flows.

### 3. Provider class (`AnalytycsProvider<R>`)

```dart
import 'package:analytics_hub/analytics_hub.dart';

class BackendAnalyticsProvider
    extends AnalytycsProvider<BackendEventResolver> {
  BackendAnalyticsProvider({String? name})
      : super(key: BackendAnalyticsProviderKey(name: name));

  @override
  BackendEventResolver get resolver => const BackendEventResolver();

  @override
  Future<void> initialize() async {
    // e.g. create HTTP client, auth headers
  }

  @override
  Future<void> setSession(Session? session) async {
    // e.g. send session.id to backend for user association
  }

  @override
  Future<void> dispose() async {
    // close HTTP client, etc.
  }
}
```

Important details:

- `key` must uniquely identify this provider instance (type + name).
- `resolver` can be cached or created on demand.
- `setSession` is called whenever the session changes (`HubSessionDelegate.sessionStream`).
- `initialize` / `dispose` help you manage the SDK lifecycle.

### 4. Registering the provider in `AnalyticsHub`

```dart
final hub = AnalyticsHub(
  sessionDelegate: yourSessionDelegate,
  providers: [
    BackendAnalyticsProvider(),
  ],
);

await hub.initialize();
await hub.sendEvent(
  ScreenViewEvent(
    screenName: 'settings',
    screenClass: SettingsScreen,
  ),
);
```

Any event that includes `BackendAnalyticsProviderKey` in `providerKeys`
will be routed to your provider.

## When to create your own provider

- You have an **in‑house analytics system** (logging service, data pipeline, etc.).
- You need to support **another 3rd‑party SDK** that doesn’t have a ready‑made package.
- You want to **wrap a complex SDK** behind a simple resolver,
  so the rest of the app never talks to that SDK directly.

## More information

- Full example: `example/analytics_core_example.dart`.
- Firebase and Mixpanel providers live in:
  - `analytics_hub_firebase`
  - `analytics_hub_mixpanel`

## Suggestions and improvements

Have an idea to improve Analytics Hub or one of the providers? We’d love to hear it. Please [open an issue](https://github.com/4akLoon/analytics_hub/issues) in the repository with your suggestion or feedback.

