## analytics_hub_appsflyer

![Dart](https://img.shields.io/badge/Dart-%3E%3D3.9-0175C2?logo=dart&logoColor=white)
![Part of](https://img.shields.io/badge/part_of-analytics__hub-informational)

> Частина монорепозиторію analytics_hub. Новачок? Почніть з
> [кореневого README](../../README.md).

> English version: [README.md](README.md)

`analytics_hub_appsflyer` інтегрує `analytics_hub` з Appsflyer.

Поточний обсяг функціоналу — тільки `LogEvent`:
події мапляться у `AppsFlyerSdk.logEvent`.
Резолвер використовує core-контракт `EventResolver` з `ResolvedEvent`.

## Встановлення

```yaml
dependencies:
  analytics_hub: ^0.5.0
  analytics_hub_appsflyer: ^0.6.0
  appsflyer_sdk: ^7.0.0
```

## Використання

```dart
final sdk = AppsFlyerSdk.instance;

await sdk.init(devKey: 'YOUR_DEV_KEY', appId: 'YOUR_APP_ID');

// SDK 7: init більше не надсилає сесію — викликайте start на кожну готовність.
await sdk.registerSessionReadyListener(sdk.start);

final hub = AnalyticsHub(
  providers: [
    AppsflyerAnalyticsHubProvider(appsFlyerSdk: sdk),
  ],
);

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
  `AppsFlyerSdk.setCustomerUserId`.

