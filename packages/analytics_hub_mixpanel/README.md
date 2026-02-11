## Analytics Hub Mixpanel Provider

[![Pub Version](https://img.shields.io/pub/v/analytics_hub_mixpanel.svg)](https://pub.dev/packages/analytics_hub_mixpanel)
[![Pub Likes](https://img.shields.io/pub/likes/analytics_hub_mixpanel.svg)](https://pub.dev/packages/analytics_hub_mixpanel)
[![Pub Points](https://img.shields.io/pub/points/analytics_hub_mixpanel.svg)](https://pub.dev/packages/analytics_hub_mixpanel)
[![Platform](https://img.shields.io/badge/platform-flutter-blue.svg)](https://flutter.dev)

> This documentation is also available in [Ukrainian](README.ua.md).

**analytics_hub_mixpanel** is a provider that connects `analytics_hub`
to **Mixpanel**: you keep a strongly‑typed event model in core,
and this package takes care of turning those events into `mixpanel.track` calls.

### Features

It provides:

- `MixpanelAnalyticsHubProvider` – `AnalytycsProvider` implementation backed by `Mixpanel`;
- `MixpanelAnalyticsHubProviderKey` – provider key used by events;
- `MixpanelEventResolver` – resolver that maps `LogEvent` to `mixpanel.track`.

### Essence of the solution

In one sentence: **you use the same `LogEvent` classes as for other analytics providers,
and this package sends them to Mixpanel without your app ever depending on the Mixpanel SDK directly**.

For **general Analytics Hub setup** (creating the hub, session delegate, registering providers), see the [analytics_hub](https://pub.dev/packages/analytics_hub) package README.

## Installation

Add this provider and its dependencies to your app `pubspec.yaml`:

```yaml
dependencies:
  mixpanel_flutter: ^2.0.0

  analytics_hub: ^0.0.1
  analytics_hub_mixpanel: ^0.0.1
```

## Integrating this provider

1. Create your `AnalyticsHub` as described in the [analytics_hub README](https://pub.dev/packages/analytics_hub).
2. Initialize Mixpanel (e.g. `await Mixpanel.init('YOUR_TOKEN', trackAutomaticEvents: false)`), then add the Mixpanel provider to the hub’s `providers` list:

```dart
import 'package:analytics_hub_mixpanel/analytics_hub_mixpanel.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

// After Mixpanel.init(...):
final mixpanel = await Mixpanel.init('YOUR_MIXPANEL_TOKEN', trackAutomaticEvents: false);

final hub = AnalyticsHub(
  sessionDelegate: yourSessionDelegate,
  providers: [
    MixpanelAnalyticsHubProvider(mixpanel: mixpanel), // add this
    // ... other providers
  ],
);
```

3. In events that should go to Mixpanel, include `MixpanelAnalyticsHubProviderKey` in `providerKeys` (see [Supported event types](#supported-event-types) below).

## Supported event types

`MixpanelEventResolver` implements:

- `EventResolver`
- `LogEventResolver`

and maps log events to `Mixpanel.track`.

### 1. Log events (`LogEvent`)

Any event that extends `LogEvent` and includes
`MixpanelAnalyticsHubProviderKey` in `providerKeys`
will be sent to Mixpanel:

```dart
class ExampleLogEvent extends LogEvent {
  const ExampleLogEvent({required this.exampleProperty})
      : super('example_log_event');

  final String exampleProperty;

  @override
  Map<String, Object>? get properties => {'example_property': exampleProperty};

  @override
  Set<ProviderKey<LogEventResolver>> get providerKeys => {
        const MixpanelAnalyticsHubProviderKey(),
      };
}
```

Mapping in Mixpanel:

```dart
@override
Future<void> resolveLogEvent(LogEvent event) =>
    _mixpanel.track(event.name, properties: event.properties);
```

So:

- `event.name` → Mixpanel event name;
- `event.properties` → Mixpanel properties.

### 2. Other event types

Currently:

- `CustomLogEvent<T>` – **not mapped** by `MixpanelEventResolver` (you can extend it
  or build your own provider if you need this).
- `ECommerceEvent` – **not supported** by this provider yet.

Any additional logic (e‑commerce, special custom events for Mixpanel) can be
implemented either in the core (new `Event` types) or in an extended resolver
if your use case requires it.

## Session handling

`MixpanelAnalyticsHubProvider` implements session logic as:

```dart
@override
Future<void> setSession(Session? session) async {
  if (session != null) {
    await _mixpanel.identify(session.id);
  } else if (_getAnonymousId case final callback?) {
    await _mixpanel.identify(callback());
  } else {
    await _mixpanel.reset();
  }
}
```

- When `Session` is non‑null, Mixpanel identifies the user with `session.id`.
- When `Session == null` and `getAnonymousId` is provided, an anonymous ID is used.
- When `Session == null` and there is no anonymous ID, `reset()` is called.

This allows you to model:

- authenticated users → tracked by `Session.id`;
- anonymous users → tracked by a controlled anonymous ID.

## Roadmap: planned events

Next steps for the Mixpanel provider:

- support **strongly typed custom events** via `CustomLogEvent<T>` and an
  extended resolver interface;
- possible support for e‑commerce events (`ECommerceEvent`) mapped into
  Mixpanel event properties / profiles.

This would:

- align the e‑commerce model with the Firebase provider;
- keep everything strongly typed and avoid “magic strings”.

## When to use analytics_hub_mixpanel

- You already use Mixpanel and want to:
  - describe events as Dart classes (`LogEvent`, etc.);
  - decouple business logic from the Mixpanel SDK;
  - share an event model with other analytics providers.
- You plan to or already use other `analytics_hub` providers
  (e.g. Firebase) and want to send **the same events**
  to Mixpanel and other systems in parallel.

## Suggestions and improvements

Have an idea to improve this provider or the hub? [Open an issue](https://github.com/4akLoon/analytics_hub/issues) in the repository with your suggestion or feedback.

