## Analytics Hub

[![Pub Version](https://img.shields.io/pub/v/analytics_hub.svg)](https://pub.dev/packages/analytics_hub)
![Dart](https://img.shields.io/badge/Dart-%3E%3D3.5-0175C2?logo=dart&logoColor=white)
![Part of](https://img.shields.io/badge/part_of-analytics__hub-informational)

> Part of the analytics_hub workspace. New here? Start with the
> [root README](../../README.md).

> This documentation is also available in [Ukrainian](README.ua.md).

`analytics_hub` is a small aggregation layer on top of analytics SDKs
such as Firebase, Mixpanel, and custom providers.

## Features

- Single event model based on `LogEvent`.
- One routing entry point via `AnalyticsHub`.
- Provider targeting through `EventProvider`.
- Global and provider-level event interceptors.
- Typed event metadata context (`EventContext` / `ContextEntry`).

### When you might want it

- You send the **same logical event** to multiple analytics SDKs.
- You want to **decouple domain/UI code** from concrete analytics dependencies.
- You need **centralized configuration management** for analytics.
- You want to be able to toggle providers on/off per environment or product.

Current providers (each has its own README with integration steps):

- **Firebase:** [analytics_hub_firebase](https://pub.dev/packages/analytics_hub_firebase) — log events
- **Mixpanel:** [analytics_hub_mixpanel](https://pub.dev/packages/analytics_hub_mixpanel) — log events
- **Appsflyer:** `analytics_hub_appsflyer` — log events via `AppsflyerSdk.logEvent`

## What's inside

| Area | Types | Source |
|---|---|---|
| **Hub** | `AnalyticsHub` | `analytics_hub.dart` |
| **Events** | `Event`, `LogEvent`, `EventProvider`, `EventOverrides` | `event/events/events.dart` |
| **Providers** | `AnalyticsProvider`, `ProviderIdentifier`, `EventResolver` | `provider/`, `event/event_resolver.dart` |
| **Interceptors** | `EventInterceptor`, `InterceptorResult`, `NextEventInterceptor` | `core/interception/interceptor/` |
| **Context** | `Context`, `EventContext`, `ContextEntry`, `EventDispatchContext`, `ResolvedEvent` | `core/interception/context/` |
| **Dispatch pipeline** | `EventDispatcher`, `DispatchTarget`, `EventDispatchContextBuilder`, `InterceptorChainExecutor`, `EventOverridesApplier`, `CorrelationIdGenerator` | `core/interception/dispatch/` |

Source paths are relative to `lib/src/`.

## Installation

In your app `pubspec.yaml`:

```yaml
dependencies:
  analytics_hub: ^0.5.0
  # and then any concrete providers you need, e.g.:
  # analytics_hub_firebase: ^0.5.0
  # analytics_hub_mixpanel: ^0.5.0
  # analytics_hub_appsflyer: ^0.5.0
```

## Core concepts

- **`AnalyticsHub`** – the facade you use to send events.
- **`Event`** – base class for events sent by the hub.
- **`LogEvent`** – simple `name + properties` event.
- **`AnalyticsProvider`** – abstraction of an analytics provider.
- **`EventResolver`** – provider event handling contract.
- **`ProviderIdentifier`** – identifies a provider; events list targets via `EventProvider`.
- **`EventInterceptor`** – middleware that can transform or drop event dispatches.
- **`EventDispatchContext`** – runtime context available inside interceptors and resolvers.

## Event model

Only `LogEvent` is supported by core.

- `name` defines the event key.
- `properties` contains optional payload (`Map<String, Object?>?`).
- `providers` defines which registered providers should receive the event.
- `context` contains typed metadata available during interception and resolving.

## Defining events

```dart
class ScreenViewEvent extends LogEvent {
  const ScreenViewEvent({
    required this.screenName,
    required this.screenClass,
  }) : super(
         'screen_view',
         context: const EventContext().withEntry(
           const FeatureContextEntry('navigation'),
         ),
       );

  final String screenName;
  final Type screenClass;

  @override
  Map<String, Object?> get properties => {
        'screen_name': screenName,
        'screen_class': screenClass.toString(),
      };

  @override
  List<EventProvider> get providers => [
        const EventProvider(BackendAnalyticsProviderIdentifier()),
      ];
}

final class FeatureContextEntry extends ContextEntry {
  const FeatureContextEntry(this.feature);

  final String feature;
}
```

## Implementing your own provider

A custom provider implements a `ProviderIdentifier`, an `EventResolver`, and an
`AnalyticsProvider` that ties them together:

```dart
class BackendAnalyticsProvider extends AnalyticsProvider {
  BackendAnalyticsProvider({String? name})
      : super(
          identifier: BackendAnalyticsProviderIdentifier(name: name),
          interceptors: const [],
        );

  @override
  BackendEventResolver get resolver => const BackendEventResolver();
}
```

See [doc/providers.md](doc/providers.md) for the full walkthrough — the
identifier, the resolver, provider lifecycle (`initialize`/`flush`/`dispose`),
and registering the provider in `AnalyticsHub` — plus guidance on when a
custom provider is worth building.

## Interceptors

Use interceptors for cross-cutting behavior (renaming events, redaction, sampling).

```dart
final class PrefixInterceptor implements EventInterceptor {
  const PrefixInterceptor(this.prefix);

  final String prefix;

  @override
  FutureOr<InterceptorResult> intercept({
    required ResolvedEvent event,
    required EventDispatchContext context,
    required NextEventInterceptor next,
  }) {
    return next(
      event.copyWith(name: '${prefix}_${event.name}'),
      context,
    );
  }
}

final hub = AnalyticsHub(
  providers: [BackendAnalyticsProvider()],
  interceptors: [const PrefixInterceptor('prod')],
);
```

See [doc/interceptors_and_context.md](doc/interceptors_and_context.md) for
the interceptor chain execution order and how typed context flows from an
event through to resolvers.

## Reference

- [doc/getting_started.md](doc/getting_started.md) — install and send your
  first event.
- [doc/providers.md](doc/providers.md) — full custom-provider walkthrough.
- [doc/interceptors_and_context.md](doc/interceptors_and_context.md) —
  interceptor chain order and typed context.
- [doc/testing.md](doc/testing.md) — testing code that uses `AnalyticsHub`.
- Core example: `example/main.dart`.
- Firebase and Mixpanel providers are in sibling packages in this repository.

## Suggestions and improvements

Have an idea to improve Analytics Hub or one of the providers? We’d love to hear it. Please [open an issue](https://github.com/4akLoon/analytics_hub/issues) in the repository with your suggestion or feedback.

