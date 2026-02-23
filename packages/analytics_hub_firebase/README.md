## Analytics Hub Firebase Provider

[![Pub Version](https://img.shields.io/pub/v/analytics_hub_firebase.svg)](https://pub.dev/packages/analytics_hub_firebase)
[![Pub Likes](https://img.shields.io/pub/likes/analytics_hub_firebase.svg)](https://pub.dev/packages/analytics_hub_firebase)
[![Pub Points](https://img.shields.io/pub/points/analytics_hub_firebase.svg)](https://pub.dev/packages/analytics_hub_firebase)
[![Platform](https://img.shields.io/badge/platform-dart%20%7C%20flutter-blue.svg)](https://dart.dev)

> This documentation is also available in [Ukrainian](README.ua.md).

**analytics_hub_firebase** is a provider that connects `analytics_hub`
to **Firebase Analytics**: you keep a strongly‑typed event model in core,
and this package maps those events to Firebase Analytics (including e‑commerce).

### Features

- `FirebaseAnalyticsHubProvider` – `AnalytycsProvider` implementation backed by `FirebaseAnalytics`;
- `FirebaseAnalyticsHubProviderIdentifier` – provider identifier used by events;
- `FirebaseAnalyticsEventResolver` / `FirebaseAnalyticsECommerceEventResolver` –
  resolvers that map `LogEvent` and `ECommerceEvent` into Firebase SDK calls.

### Essence of the solution

In one sentence: **you use the same event classes as for other analytics providers,
and this package sends them to Firebase (log events + e‑commerce like `SelectPromotion`) without your app calling the Firebase SDK directly**.

For **general Analytics Hub setup** (creating the hub, session delegate, registering providers), see the [analytics_hub](https://pub.dev/packages/analytics_hub) package README.

## Installation

Add this provider and its dependencies to your app `pubspec.yaml`:

```yaml
dependencies:
  firebase_core: ^2.0.0
  firebase_analytics: ^10.0.0

  analytics_hub: ^0.2.1
  analytics_hub_firebase: ^0.2.1
```

Call `Firebase.initializeApp()` in `main()` before using the hub (see [Firebase docs](https://firebase.google.com/docs/flutter/setup)).

## Integrating this provider

1. Initialize Firebase (e.g. in `main()`), then create your `AnalyticsHub` as described in the [analytics_hub README](https://pub.dev/packages/analytics_hub).
2. Add the Firebase provider to the hub’s `providers` list:

```dart
import 'package:analytics_hub_firebase/analytics_hub_firebase.dart';

// When building your hub:
final hub = AnalyticsHub(
  sessionDelegate: yourSessionDelegate,
  providers: [
    FirebaseAnalyticsHubProvider.fromInstance(), // add this
    // ... other providers
  ],
);
```

3. In events that should go to Firebase, include `FirebaseAnalyticsHubProviderIdentifier` in `providers` (see [Supported event types](#supported-event-types) below).

## Supported event types

`FirebaseAnalyticsEventResolver` implements:

- `LogEventResolver`
- `ECommerceEventResolver`

and internally delegates to `FirebaseAnalytics` and `FirebaseAnalyticsECommerceEventResolver`.

### 1. Log events (`LogEvent`)

Any `LogEvent` that includes `FirebaseAnalyticsHubProviderIdentifier`
in its `providers` list will be sent to Firebase using `logEvent`:

```dart
class ExampleLogEvent extends LogEvent {
  const ExampleLogEvent({required this.value}) : super('example_log_event');

  final String value;

  @override
  Map<String, Object>? get properties => {'value': value};

  @override
  List<EventProvider<LogEventResolver, LogEventOptions>> get providers => [
        const EventProvider(FirebaseAnalyticsHubProviderIdentifier()),
      ];
}
```

Mapping in Firebase:

```dart
_analytics.logEvent(
  name: event.name,
  parameters: event.properties,
);
```

So:

- `event.name` → `name` in `logEvent`;
- `event.properties` → `parameters`.

### 2. E‑commerce events (`ECommerceEvent`)

Currently supported (all mapped by `FirebaseAnalyticsECommerceEventResolver`):

- `SelectPromotionECommerceEvent`
- `AddToCartECommerceEvent`
- `AddToWishlistECommerceEvent`
- `ViewCartECommerceEvent`
- `AddPaymentInfoECommerceEvent`
- `AddShippingInfoECommerceEvent`
- `BeginCheckoutECommerceEvent`
- `PurchaseECommerceEvent`
- `RemoveFromCartECommerceEvent`
- `SelectItemECommerceEvent`
- `ViewItemECommerceEvent`
- `ViewItemListECommerceEvent`
- `ViewPromotionECommerceEvent`
- `RefundECommerceEvent`

Mapping in Firebase:

```dart
Future<void> _resolveSelectPromotionEvent(
  SelectPromotionECommerceEvent event,
) =>
    _analytics.logSelectPromotion(
      creativeName: event.data.creativeName,
      creativeSlot: event.data.creativeSlot,
      locationId: event.data.locationId,
      promotionId: event.data.promotionId,
      promotionName: event.data.promotionName,
      parameters: event.data.parameters,
    );
```

Whatever you put into `SelectPromotionECommerceEventData`
is passed directly to `logSelectPromotion`.

Example:

```dart
class PromoClickEvent extends SelectPromotionECommerceEvent {
  const PromoClickEvent({required this.promoId, required this.creativeName});

  final String promoId;
  final String creativeName;

  @override
  SelectPromotionECommerceEventData get data =>
      SelectPromotionECommerceEventData(
        creativeName: creativeName,
        promotionId: promoId,
      );

  @override
  List<
      EventProvider<ECommerceEventResolver,
          ECommerceEventOptions<SelectPromotionECommerceEventData>>> get providers => [
        const EventProvider(FirebaseAnalyticsHubProviderIdentifier()),
      ];
}
```

## Session handling

`FirebaseAnalyticsHubProvider` implements `setSession` as:

```dart
@override
Future<void> setSession(Session? session) async {
  await _analytics.setUserId(id: session?.id);
}
```

- If `Session` is non‑null, `userId` is set in Firebase.
- If `Session == null`, `userId` is reset (`id: null`).

This lets you manage the session centrally via `HubSessionDelegate`
instead of calling Firebase APIs directly throughout your app.

## Event routing with provider options

The core `analytics_hub` API lets each event define `providers` via
`EventProvider<Resolver, Options>`. This allows:

- explicit provider targeting by `ProviderIdentifier`;
- provider-specific options/overrides for the same logical event.

## When to use analytics_hub_firebase

- You already use Firebase Analytics and want to:
  - strongly type your events in Dart;
  - share a single event model across multiple analytics SDKs;
  - manage sessions centrally.
- You plan to add other providers (e.g. Mixpanel) and would like
  to **reuse the same event classes** instead of duplicating logic.

## Suggestions and improvements

Have an idea to improve this provider or the hub? [Open an issue](https://github.com/4akLoon/analytics_hub/issues) in the repository with your suggestion or feedback.

