## analytics_hub_mixpanel

> This documentation is also available in [Ukrainian](README.ua.md).

**analytics_hub_mixpanel** is a provider that connects `analytics_hub`
to **Mixpanel**.

It provides:

- `MixpanelAnalyticsHubProvider` – `AnalytycsProvider` implementation backed by `Mixpanel`;
- `MixpanelAnalyticsHubProviderKey` – provider key used by events;
- `MixpanelEventResolver` – resolver that maps `LogEvent` to `mixpanel.track`.

## Installation

In your app `pubspec.yaml`:

```yaml
dependencies:
  mixpanel_flutter: ^2.0.0

  analytics_hub: ^0.0.1
  analytics_hub_mixpanel: ^0.0.1
```

## Quick start

Example (from `example/analytics_hub_mixpanel_example.dart`):

```dart
import 'package:analytics_hub/analytics_hub.dart';
import 'package:analytics_hub_mixpanel/analytics_hub_mixpanel.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

class EmptySessionDelegate implements HubSessionDelegate {
  @override
  Stream<Session?> get sessionStream => Stream.value(null);

  @override
  Future<Session?> getSession() async => null;
}

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

Future<void> main() async {
  final mixpanel = await Mixpanel.init(
    'YOUR_MIXPANEL_TOKEN',
    trackAutomaticEvents: false,
  );

  final hub = AnalyticsHub(
    sessionDelegate: EmptySessionDelegate(),
    providers: [
      MixpanelAnalyticsHubProvider(mixpanel: mixpanel),
    ],
  );

  await hub.initialize();

  await hub.sendEvent(
    const ExampleLogEvent(exampleProperty: 'example_property'),
  );

  await hub.dispose();
}
```

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


