## analytics_hub_firebase

![Dart](https://img.shields.io/badge/Dart-%3E%3D3.5-0175C2?logo=dart&logoColor=white)
![Part of](https://img.shields.io/badge/part_of-analytics__hub-informational)

> Частина монорепозиторію analytics_hub. Новачок? Почніть з
> [кореневого README](../../README.md).

> English version: [README.md](README.md)

`analytics_hub_firebase` інтегрує `analytics_hub` з Firebase Analytics.

Поточний обсяг функціоналу — тільки `LogEvent`:
події мапляться у `FirebaseAnalytics.logEvent`.
Резолвер використовує core-контракт `EventResolver` з `ResolvedEvent`.

## Встановлення

```yaml
dependencies:
  analytics_hub: ^0.5.0
  analytics_hub_firebase: ^0.5.0
  firebase_core: ^2.0.0
  firebase_analytics: ^10.0.0
```

## Використання

```dart
final hub = AnalyticsHub(
  providers: [
    FirebaseAnalyticsHubProvider.fromInstance(),
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
        EventProvider(FirebaseAnalyticsHubIdentifier()),
      ];
}
```

## Нотатки

- Ідентифікацію користувача застосунок керує самостійно через `FirebaseAnalytics.setUserId`.
- `FirebaseAnalyticsEventResolver` відфільтровує `null`-значення з `properties` перед `logEvent`.
- Перезапис `name/properties` під конкретний провайдер працює через `EventProvider.overrides`.
- `flush()` для Firebase реалізований як no-op (SDK не має явного API для flush).
