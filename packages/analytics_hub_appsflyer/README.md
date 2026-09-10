## Analytics Hub Appsflyer Provider

![Dart](https://img.shields.io/badge/Dart-%3E%3D3.9-0175C2?logo=dart&logoColor=white)
![Part of](https://img.shields.io/badge/part_of-analytics__hub-informational)

> Part of the analytics_hub workspace. New here? Start with the
> [root README](../../README.md).

> Ukrainian version: [README.ua.md](README.ua.md)

`analytics_hub_appsflyer` connects `analytics_hub` to Appsflyer.

Current scope is log-only: this package maps `LogEvent` to `AppsFlyerSdk.logEvent`.
It uses the core `EventResolver` contract with `ResolvedEvent` payload.

## Installation

```yaml
dependencies:
  analytics_hub: ^0.5.0
  analytics_hub_appsflyer: ^0.6.0
  appsflyer_sdk: ^7.0.0
```

## Usage

```dart
final sdk = AppsFlyerSdk.instance;

await sdk.init(devKey: 'YOUR_DEV_KEY', appId: 'YOUR_APP_ID');

// SDK 7: init no longer sends a session — start once per readiness event.
await sdk.registerSessionReadyListener(sdk.start);

final hub = AnalyticsHub(
  providers: [
    AppsflyerAnalyticsHubProvider(appsFlyerSdk: sdk),
  ],
);

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
        EventProvider(AppsflyerAnalyticsHubIdentifier()),
      ];
}
```

## Notes

- Customer user ID management is handled by the app directly via
  `AppsFlyerSdk.setCustomerUserId`.

