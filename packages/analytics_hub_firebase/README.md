## Analytics Hub Firebase Provider

![Dart](https://img.shields.io/badge/Dart-%3E%3D3.5-0175C2?logo=dart&logoColor=white)
![Part of](https://img.shields.io/badge/part_of-analytics__hub-informational)

> Part of the analytics_hub workspace. New here? Start with the
> [root README](../../README.md).

> Ukrainian version: [README.ua.md](README.ua.md)

`analytics_hub_firebase` connects `analytics_hub` to Firebase Analytics.

Current scope is log-only: this package maps `LogEvent` to `FirebaseAnalytics.logEvent`.
It uses the core `EventResolver` contract with `ResolvedEvent` payload.

## Installation

```yaml
dependencies:
  analytics_hub: ^0.5.0
  analytics_hub_firebase: ^0.5.0
  firebase_core: ^2.0.0
  firebase_analytics: ^10.0.0
```

## Usage

```dart
final hub = AnalyticsHub(
  providers: [
    FirebaseAnalyticsHubProvider.fromInstance(),
  ],
);

await hub.initialize();
await hub.sendEvent(const SignupEvent('email'));
```

Event example:

```dart
class SignupEvent extends LogEvent {
  const SignupEvent(this.method) : super('sign_up');

  final String method;

  @override
  Map<String, Object?> get properties => {'method': method};

  @override
  List<EventProvider> get providers => const [
        EventProvider(FirebaseAnalyticsHubIdentifier()),
      ];
}
```

## Notes

- User identification is managed by the app directly via `FirebaseAnalytics.setUserId`.
- `FirebaseAnalyticsEventResolver` filters out `null` values from properties before calling `logEvent`.
- Provider-specific event renaming/properties overrides are supported through `EventProvider.overrides`.
- `flush()` is intentionally a no-op for Firebase Analytics (SDK has no explicit flush API).
