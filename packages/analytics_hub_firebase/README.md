## analytics_hub_firebase

> This documentation is also available in [Ukrainian](README.ua.md).

**analytics_hub_firebase** is a provider that connects `analytics_hub`
to **Firebase Analytics**.

It provides:

- `FirebaseAnalyticsHubProvider` – an `AnalytycsProvider` implementation backed by `FirebaseAnalytics`;
- `FirebaseAnalyticsHubProviderKey` – provider key used by events;
- `FirebaseAnalyticsEventResolver` / `FirebaseAnalyticsECommerceEventResolver` –
  resolvers that map `analytics_hub` events into Firebase SDK calls.

## Installation

In your app `pubspec.yaml`:

```yaml
dependencies:
  firebase_core: ^2.0.0
  firebase_analytics: ^10.0.0

  analytics_hub: ^0.0.1
  analytics_hub_firebase: ^0.0.1
```

Make sure you call `Firebase.initializeApp()` in `main()` according to the official docs.

## Quick start

Simplified version of `example/analytics_hub_firebase_example.dart`:

```dart
import 'package:analytics_hub/analytics_hub.dart';
import 'package:analytics_hub_firebase/analytics_hub_firebase.dart';

class EmptySessionDelegate implements HubSessionDelegate {
  @override
  Stream<Session?> get sessionStream => Stream.value(null);

  @override
  Future<Session?> getSession() async => null;
}

class ExampleSelectPromotionECommerceEvent
    extends SelectPromotionECommerceEvent {
  const ExampleSelectPromotionECommerceEvent({required this.creativeName});

  final String creativeName;

  @override
  SelectPromotionECommerceEventData get data =>
      SelectPromotionECommerceEventData(
        creativeName: creativeName,
      );

  @override
  Set<ProviderKey<ECommerceEventResolver>> get providerKeys => {
        const FirebaseAnalyticsHubProviderKey(),
      };
}

Future<void> main() async {
  // TODO: call Firebase.initializeApp() before this

  final hub = AnalyticsHub(
    sessionDelegate: EmptySessionDelegate(),
    providers: [
      FirebaseAnalyticsHubProvider.fromInstance(),
    ],
  );

  await hub.initialize();

  await hub.sendEvent(
    const ExampleSelectPromotionECommerceEvent(
      creativeName: 'creative_name',
    ),
  );

  await hub.dispose();
}
```

## Supported event types

`FirebaseAnalyticsEventResolver` implements:

- `LogEventResolver`
- `ECommerceEventResolver`

and internally delegates to `FirebaseAnalytics` and `FirebaseAnalyticsECommerceEventResolver`.

### 1. Log events (`LogEvent`)

Any `LogEvent` that includes `FirebaseAnalyticsHubProviderKey`
in its `providerKeys` set will be sent to Firebase using `logEvent`:

```dart
class ExampleLogEvent extends LogEvent {
  const ExampleLogEvent({required this.value}) : super('example_log_event');

  final String value;

  @override
  Map<String, Object>? get properties => {'value': value};

  @override
  Set<ProviderKey<LogEventResolver>> get providerKeys => {
        const FirebaseAnalyticsHubProviderKey(),
      };
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

Currently supported:

- **`SelectPromotionECommerceEvent`**
  - handled via `FirebaseAnalyticsECommerceEventResolver`.

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
  Set<ProviderKey<ECommerceEventResolver>> get providerKeys => {
        const FirebaseAnalyticsHubProviderKey(),
      };
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

## Roadmap: planned events

On the Firebase provider level, the next logical steps are:

- Additional e‑commerce events:
  - `view_item`, `view_item_list`, `select_item`,
  - `add_to_cart`, `add_to_wishlist`,
  - `begin_checkout`, `add_payment_info`, `add_shipping_info`,
  - `purchase`, `refund`, and other standard GA4 events.
- Matching `ECommerceEvent` subtypes in the core package and mappings
  in `FirebaseAnalyticsECommerceEventResolver`.

The idea is that all common GA4 e‑commerce flows can be expressed as
strongly typed events in `analytics_hub` and automatically mapped
to Firebase through this provider.

## When to use analytics_hub_firebase

- You already use Firebase Analytics and want to:
  - strongly type your events in Dart;
  - share a single event model across multiple analytics SDKs;
  - manage sessions centrally.
- You plan to add other providers (e.g. Mixpanel) and would like
  to **reuse the same event classes** instead of duplicating logic.


