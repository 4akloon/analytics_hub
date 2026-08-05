## analytics_hub_appsflyer

![Dart](https://img.shields.io/badge/Dart-%3E%3D3.5-0175C2?logo=dart&logoColor=white)
![Part of](https://img.shields.io/badge/part_of-analytics__hub-informational)

> Частина монорепозиторію analytics_hub. Новачок? Почніть з
> [кореневого README](../../README.md).

> English version: [README.md](README.md)

`analytics_hub_appsflyer` інтегрує `analytics_hub` з Appsflyer.

Поточний обсяг функціоналу — тільки `LogEvent`:
події мапляться у `AppsflyerSdk.logEvent`.
Резолвер використовує core-контракт `EventResolver` з `ResolvedEvent`.

## Встановлення

```yaml
dependencies:
  analytics_hub: ^0.5.0
  analytics_hub_appsflyer: ^0.5.0
  appsflyer_sdk: ^6.15.0
```

## Використання

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

await hub.initialize();
await hub.sendEvent(const SignupEvent('email'));
```

Приклад події:

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

## Нотатки

- Керування customer user ID застосунок здійснює самостійно через
  `AppsflyerSdk.setCustomerUserId`.

