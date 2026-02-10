## analytics_hub

> This documentation is also available in [Ukrainian](README.ua.md).

**analytics_hub** is a small aggregation layer on top of analytics SDKs
such as Firebase, Mixpanel, and your own providers. It:

- **unifies the event model** (log, custom, e‑commerce);
- **provides a single entry point** (`AnalyticsHub`) instead of talking to each SDK directly;
- **manages the user session** and propagates a `Session` to all providers;
- makes it easy to **add or remove providers** without touching business logic.

### Why you might want it

- You send the **same logical event** to multiple analytics SDKs.
- You want to **decouple domain/UI code** from concrete analytics dependencies.
- You need **centralized session and configuration management** for analytics.
- You want to be able to toggle providers on/off per environment or product.

Current providers in this monorepo:

- Firebase: `analytics_hub_firebase`
- Mixpanel: `analytics_hub_mixpanel`

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

class EmptySessionDelegate implements HubSessionDelegate {
  @override
  Stream<Session?> get sessionStream => Stream.value(null);

  @override
  Future<Session?> getSession() async => null;
}

void main() async {
  final hub = AnalyticsHub(
    sessionDelegate: EmptySessionDelegate(),
    providers: [
      ExampleAnalyticsProvider(),
      ExampleAnalyticsProvider(name: 'Another Provider'),
    ],
  );

  await hub.initialize();

  await hub.sendEvent(
    const ExampleLogEvent(exampleProperty: 'example_value'),
  );

  await hub.dispose();
}
```

## Defining events

### Log event (`LogEvent`)

```dart
class ExampleLogEvent extends LogEvent {
  const ExampleLogEvent({required this.exampleProperty})
      : super('example_log_event');

  final String exampleProperty;

  @override
  Map<String, Object>? get properties => {
        'example_property': exampleProperty,
      };

  @override
  Set<ProviderKey<LogEventResolver>> get providerKeys => {
        const ExampleAnalyticsProviderKey(),
        const ExampleAnalyticsProviderKey(name: 'Another Provider'),
      };
}
```

Key points:

- **`name`** – technical event name.
- **`properties`** – payload that will be passed to providers.
- **`providerKeys`** – which providers should receive this event.

### Custom log events (`CustomLogEvent<T>`)

```dart
sealed class ExampleCustomLogEvent
    extends CustomLogEvent<ExampleCustomLogEvent> {
  const ExampleCustomLogEvent();
}

abstract class FirstExampleCustomLogEvent extends ExampleCustomLogEvent {
  const FirstExampleCustomLogEvent({required this.exampleProperty});

  final String exampleProperty;
}

abstract class FirstExampleCustomLogEventImpl
    extends FirstExampleCustomLogEvent {
  const FirstExampleCustomLogEventImpl({required super.exampleProperty});

  @override
  Set<ProviderKey<CustomLogEventResolver<ExampleCustomLogEvent>>>
      get providerKeys => {const ExampleAnalyticsProviderKey()};
}
```

The idea:

- you design your own event hierarchy;
- the resolver (`CustomLogEventResolver<ExampleCustomLogEvent>`) decides how to handle each subtype.

### E‑commerce `SelectPromotionECommerceEvent`

```dart
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
        // e.g. FirebaseAnalyticsHubProviderKey
      };
}
```

## Implementing your own provider (step‑by‑step)

A custom provider in `packages/analytics_hub` consists of:

1. **Provider key** (`ProviderKey<R>`).
2. **Event resolver(s)** (`EventResolver` + required interfaces).
3. **Provider class** (`AnalytycsProvider<R>`) registered in `AnalyticsHub`.

### 1. Provider key (`ProviderKey`)

```dart
import 'package:analytics_hub/analytics_hub.dart';

class ExampleAnalyticsProviderKey extends ProviderKey<ExampleEventResolver> {
  const ExampleAnalyticsProviderKey({super.name});
}
```

- `R` in `ProviderKey<R>` is the type of your main resolver.
- `name` can be used to distinguish multiple instances
  (e.g. multiple Firebase projects or Mixpanel workspaces).

### 2. Event resolver (`EventResolver` + interfaces)

```dart
import 'package:analytics_hub/analytics_hub.dart';

class ExampleEventResolver
    implements
        EventResolver,
        LogEventResolver,
        CustomLogEventResolver<ExampleCustomLogEvent> {
  const ExampleEventResolver();

  @override
  Future<void> resolveLogEvent(LogEvent event) async {
    // map LogEvent into your SDK calls
  }

  @override
  Future<void> resolveCustomLogEvent(
    CustomLogEvent<ExampleCustomLogEvent> event,
  ) async {
    // handle specific custom events
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

class ExampleAnalyticsProvider
    extends AnalytycsProvider<ExampleEventResolver> {
  ExampleAnalyticsProvider({String? name})
      : super(key: ExampleAnalyticsProviderKey(name: name));

  @override
  ExampleEventResolver get resolver => const ExampleEventResolver();

  @override
  Future<void> initialize() async {
    // initialize your SDK (init, enable tracking, etc.)
  }

  @override
  Future<void> setSession(Session? session) async {
    // e.g. sdk.setUserId(session?.id);
  }

  @override
  Future<void> dispose() async {
    // optional: clean up resources, close streams, etc.
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
  sessionDelegate: EmptySessionDelegate(),
  providers: [
    ExampleAnalyticsProvider(),
  ],
);

await hub.initialize();
await hub.sendEvent(const ExampleLogEvent(exampleProperty: 'value'));
```

Any event that includes `ExampleAnalyticsProviderKey` in `providerKeys`
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


