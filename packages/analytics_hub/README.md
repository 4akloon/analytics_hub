## Analytics Hub

[![Pub Version](https://img.shields.io/pub/v/analytics_hub.svg)](https://pub.dev/packages/analytics_hub)

> This documentation is also available in [Ukrainian](README.ua.md).

`analytics_hub` is a small aggregation layer on top of analytics SDKs
such as Firebase, Mixpanel, and custom providers.

## Features

- Single event model based on `LogEvent`.
- One routing entry point via `AnalyticsHub`.
- Provider targeting through `EventProvider`.
- Centralized session propagation through `HubSessionDelegate`.
- Global and provider-level event interceptors.
- Typed event metadata context (`EventContext` / `ContextEntry`).

### When you might want it

- You send the **same logical event** to multiple analytics SDKs.
- You want to **decouple domain/UI code** from concrete analytics dependencies.
- You need **centralized session and configuration management** for analytics.
- You want to be able to toggle providers on/off per environment or product.

Current providers (each has its own README with integration steps):

- **Firebase:** [analytics_hub_firebase](https://pub.dev/packages/analytics_hub_firebase) — log events
- **Mixpanel:** [analytics_hub_mixpanel](https://pub.dev/packages/analytics_hub_mixpanel) — log events

## Installation

In your app `pubspec.yaml`:

```yaml
dependencies:
  analytics_hub: ^0.3.3
  # and then any concrete providers you need, e.g.:
  # analytics_hub_firebase: ^0.3.3
  # analytics_hub_mixpanel: ^0.3.3
```

## Core concepts

- **`AnalyticsHub`** – the facade you use to send events.
- **`Event`** – base class for events sent by the hub.
- **`LogEvent`** – simple `name + properties` event.
- **`AnalytycsProvider`** – abstraction of an analytics provider.
- **`EventResolver`** – provider event handling contract.
- **`ProviderIdentifier`** – identifies a provider; events list targets via `EventProvider`.
- **`Session` / `HubSessionDelegate`** – session model plus a delegate that supplies the current
  session and a stream of session changes.
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

## Implementing your own provider (step‑by‑step)

A custom provider (e.g. sending events to your backend) consists of:

1. **Provider identifier** (`ProviderIdentifier`).
2. **Event resolver** (`EventResolver`).
3. **Provider class** (`AnalytycsProvider`) registered in `AnalyticsHub`.

### 1. Provider identifier (`ProviderIdentifier`)

```dart
import 'package:analytics_hub/analytics_hub.dart';

class BackendAnalyticsProviderIdentifier
    extends ProviderIdentifier {
  const BackendAnalyticsProviderIdentifier({super.name});
}
```

### 2. Event resolver (`EventResolver`)

```dart
import 'package:analytics_hub/analytics_hub.dart';

class BackendEventResolver
    implements EventResolver {
  const BackendEventResolver();

  @override
  Future<void> resolve(
    ResolvedEvent event, {
    required EventDispatchContext context,
  }) async {
    // e.g. POST event.name + event.properties to your backend.
    // context has event metadata and correlationId for tracing.
  }
}
```

### 3. Provider class (`AnalytycsProvider`)

```dart
import 'package:analytics_hub/analytics_hub.dart';

class BackendAnalyticsProvider
    extends AnalytycsProvider {
  BackendAnalyticsProvider({String? name})
      : super(
          identifier: BackendAnalyticsProviderIdentifier(name: name),
          interceptors: const [],
        );

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

- `identifier` must uniquely identify this provider instance (type + name).
- `resolver` can be cached or created on demand.
- `setSession` is called whenever the session changes (`HubSessionDelegate.sessionStream`).
- `initialize` / `flush` / `dispose` help you manage provider lifecycle.

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
await hub.flush();
```

Any event that includes `BackendAnalyticsProviderIdentifier` in `providers`
will be routed to your provider.

## When to create your own provider

- You have an **in‑house analytics system** (logging service, data pipeline, etc.).
- You need to support **another 3rd‑party SDK** that doesn’t have a ready‑made package.
- You want to **wrap a complex SDK** behind a simple resolver,
  so the rest of the app never talks to that SDK directly.

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
  sessionDelegate: yourSessionDelegate,
  providers: [BackendAnalyticsProvider()],
  interceptors: [const PrefixInterceptor('prod')],
);
```

## More information

- Core example: `example/main.dart`.
- Firebase and Mixpanel providers are in sibling packages in this repository.

## Suggestions and improvements

Have an idea to improve Analytics Hub or one of the providers? We’d love to hear it. Please [open an issue](https://github.com/4akLoon/analytics_hub/issues) in the repository with your suggestion or feedback.

