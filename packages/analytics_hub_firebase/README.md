## Analytics Hub Firebase Provider

> Ukrainian version: [README.ua.md](README.ua.md)

`analytics_hub_firebase` connects `analytics_hub` to Firebase Analytics.

Current scope is log-only: this package maps `LogEvent` to `FirebaseAnalytics.logEvent`.
It uses the core `EventResolver` contract with `ResolvedEvent` payload.

## Installation

```yaml
dependencies:
  analytics_hub: ^0.3.1
  analytics_hub_firebase: ^0.3.1
  firebase_core: ^2.0.0
  firebase_analytics: ^10.0.0
```

## Usage

```dart
final hub = AnalyticsHub(
  sessionDelegate: yourSessionDelegate,
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
        EventProvider(FirebaseAnalyticsHubProviderIdentifier()),
      ];
}
```

## Session handling

`FirebaseAnalyticsHubProvider` sets Firebase user id from hub session:

```dart
@override
Future<void> setSession(Session? session) async {
  await _analytics.setUserId(id: session?.id);
}
```

## Notes

- `FirebaseAnalyticsEventResolver` filters out `null` values from properties before calling `logEvent`.
- Provider-specific event renaming/properties overrides are supported through `EventProvider.options`.
