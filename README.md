## Analytics Hub

![Dart](https://img.shields.io/badge/Dart-%3E%3D3.5-0175C2?logo=dart&logoColor=white)
![Style](https://img.shields.io/badge/style-lints-brightgreen)

Monorepo with `analytics_hub` packages for unified analytics routing across providers.

Current model is intentionally **single-event**: only `LogEvent` is supported by core and official providers.

## Packages

- `packages/analytics_hub` – core hub abstractions.
- `packages/analytics_hub_firebase` – Firebase provider (`LogEvent` -> `FirebaseAnalytics.logEvent`).
- `packages/analytics_hub_mixpanel` – Mixpanel provider (`LogEvent` -> `Mixpanel.track`).
- `packages/analytics_hub_appsflyer` – Appsflyer provider (`LogEvent` -> `AppsFlyerSdk.logEvent`).

Per-package docs:

- Core: [English](packages/analytics_hub/README.md), [Українська](packages/analytics_hub/README.ua.md)
- Firebase: [English](packages/analytics_hub_firebase/README.md), [Українська](packages/analytics_hub_firebase/README.ua.md)
- Mixpanel: [English](packages/analytics_hub_mixpanel/README.md), [Українська](packages/analytics_hub_mixpanel/README.ua.md)
- Appsflyer: [English](packages/analytics_hub_appsflyer/README.md), [Українська](packages/analytics_hub_appsflyer/README.ua.md)

## Quick start

```yaml
dependencies:
  analytics_hub: ^0.5.0
  analytics_hub_firebase: ^0.5.0
  analytics_hub_mixpanel: ^0.5.0
  # analytics_hub_appsflyer: ^0.5.0 # optional, if you use Appsflyer
```

```dart
class ExampleLogEvent extends LogEvent {
  const ExampleLogEvent(this.value) : super('example_log_event');

  final String value;

  @override
  Map<String, Object?> get properties => {'value': value};

  @override
  List<EventProvider> get providers => const [
        EventProvider(FirebaseAnalyticsHubIdentifier()),
        EventProvider(MixpanelAnalyticsHubIdentifier()),
      ];
}
```
