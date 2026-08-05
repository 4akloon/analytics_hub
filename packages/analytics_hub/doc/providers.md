# Implementing your own provider

Official providers exist for Firebase, Mixpanel, and Appsflyer. For anything
else — an in-house analytics backend, another 3rd-party SDK, or wrapping a
complex SDK behind a simple interface — implement your own provider.

A custom provider consists of three pieces:

1. **Provider identifier** (`ProviderIdentifier`).
2. **Event resolver** (`EventResolver`).
3. **Provider class** (`AnalyticsProvider`) registered in `AnalyticsHub`.

## 1. Provider identifier (`ProviderIdentifier`)

```dart
import 'package:analytics_hub/analytics_hub.dart';

class BackendAnalyticsProviderIdentifier
    extends ProviderIdentifier {
  const BackendAnalyticsProviderIdentifier({super.name});
}
```

The identifier is what events reference in their `providers` list, and what
the hub uses to route each event to the right provider instance. `name` lets
you register multiple instances of the same provider type (e.g. two backends)
side by side — see [analytics_hub.dart's `AnalyticsHub`](../lib/src/analytics_hub.dart)
for how identifiers are matched.

## 2. Event resolver (`EventResolver`)

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

The resolver is the only place that talks to the underlying SDK/API. It
receives the event *after* overrides and interceptors have already run, so
`event.name`/`event.properties` are final.

## 3. Provider class (`AnalyticsProvider`)

```dart
import 'package:analytics_hub/analytics_hub.dart';

class BackendAnalyticsProvider
    extends AnalyticsProvider {
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
  Future<void> dispose() async {
    // close HTTP client, etc.
  }
}
```

Important details:

- `identifier` must uniquely identify this provider instance (type + name).
- `resolver` can be cached or created on demand.
- `initialize` / `flush` / `dispose` help you manage provider lifecycle.

## 4. Registering the provider in `AnalyticsHub`

```dart
final hub = AnalyticsHub(
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

- You have an **in-house analytics system** (logging service, data pipeline, etc.).
- You need to support **another 3rd-party SDK** that doesn't have a ready-made package.
- You want to **wrap a complex SDK** behind a simple resolver, so the rest of
  the app never talks to that SDK directly.
