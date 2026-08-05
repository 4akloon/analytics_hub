## Analytics Hub Appsflyer Provider

![Dart](https://img.shields.io/badge/Dart-%3E%3D3.5-0175C2?logo=dart&logoColor=white)
![Part of](https://img.shields.io/badge/part_of-analytics__hub-informational)

> Part of the analytics_hub workspace. New here? Start with the
> [root README](../../README.md).

> Ukrainian version: [README.ua.md](README.ua.md)

`analytics_hub_appsflyer` connects `analytics_hub` to Appsflyer.

Current scope is log-only: this package maps `LogEvent` to `AppsflyerSdk.logEvent`.
It uses the core `EventResolver` contract with `ResolvedEvent` payload.

## Installation

```yaml
dependencies:
  analytics_hub: ^0.5.0
  analytics_hub_appsflyer: ^0.5.0
  appsflyer_sdk: ^6.15.0
```

## Usage

```dart
final options = AppsFlyerOptions(
  afDevKey: 'YOUR_DEV_KEY',
  appId: 'YOUR_APP_ID',
  showDebug: true,
);

final sdk = AppsflyerSdk(options);
await sdk.initSdk(
  registerConversionDataCallback: false,
  registerOnAppOpenAttributionCallback: false,
  registerOnDeepLinkingCallback: false,
);

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
  `AppsflyerSdk.setCustomerUserId`.

