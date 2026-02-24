## analytics_hub

> English version: [README.md](README.md)

`analytics_hub` — core-пакет для маршрутизації аналітики між провайдерами.

Поточна модель подій навмисно спрощена: підтримується тільки `LogEvent`.

## Що входить у пакет

- `AnalyticsHub` — центральна точка відправки подій.
- `LogEvent` — базова подія з `name`, `properties` і `providers`.
- `AnalytycsProvider` — базовий клас провайдера.
- `ProviderIdentifier` — ідентифікатор провайдера.
- `LogEventResolver` — інтерфейс обробки `LogEvent`.
- `Session` + `HubSessionDelegate` — робота із сесією користувача.

## Встановлення

```yaml
dependencies:
  analytics_hub: ^0.3.0
```

## Приклад події

```dart
class ScreenViewEvent extends LogEvent {
  const ScreenViewEvent({
    required this.screenName,
  }) : super('screen_view');

  final String screenName;

  @override
  Map<String, Object?> get properties => {
        'screen_name': screenName,
      };

  @override
  List<EventProvider> get providers => const [
        EventProvider(BackendAnalyticsProviderIdentifier()),
      ];
}
```

## Як зробити власний провайдер

1. Створіть `ProviderIdentifier`.
2. Реалізуйте `LogEventResolver`.
3. Успадкуйтесь від `AnalytycsProvider` і поверніть resolver.

```dart
class BackendAnalyticsProviderIdentifier extends ProviderIdentifier {
  const BackendAnalyticsProviderIdentifier({super.name});
}

class BackendEventResolver implements EventResolver, LogEventResolver {
  const BackendEventResolver();

  @override
  Future<void> resolveLogEvent(LogEvent event) async {
    // map to your backend SDK/API
  }
}

class BackendAnalyticsProvider extends AnalytycsProvider {
  BackendAnalyticsProvider({String? name})
      : super(identifier: BackendAnalyticsProviderIdentifier(name: name));

  @override
  LogEventResolver get resolver => const BackendEventResolver();

  @override
  Future<void> setSession(Session? session) async {}
}
```
