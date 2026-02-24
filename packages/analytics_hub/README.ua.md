## analytics_hub

> English version: [README.md](README.md)

`analytics_hub` — core-пакет для маршрутизації аналітики між провайдерами
з єдиним API подій, інтерсепторами та типізованим контекстом.

Поточна модель подій навмисно спрощена: підтримується тільки `LogEvent`.

## Що входить у пакет

- `AnalyticsHub` — центральна точка відправки подій.
- `LogEvent` — базова подія з `name`, `properties` і `providers`.
- `AnalytycsProvider` — базовий клас провайдера.
- `ProviderIdentifier` — ідентифікатор провайдера.
- `EventResolver` — контракт обробки подій у провайдері.
- `EventInterceptor` — middleware для трансформації/дропу подій.
- `EventContext` + `ContextEntry` — типізований контекст події.
- `Session` + `HubSessionDelegate` — робота із сесією користувача.

## Встановлення

```yaml
dependencies:
  analytics_hub: ^0.3.3
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
2. Реалізуйте `EventResolver`.
3. Успадкуйтесь від `AnalytycsProvider` і поверніть resolver.

```dart
class BackendAnalyticsProviderIdentifier extends ProviderIdentifier {
  const BackendAnalyticsProviderIdentifier({super.name});
}

class BackendEventResolver implements EventResolver {
  const BackendEventResolver();

  @override
  Future<void> resolve(
    ResolvedEvent event, {
    required EventDispatchContext context,
  }) async {
    // map to your backend SDK/API
    // context.correlationId можна використати для трасування
  }
}

class BackendAnalyticsProvider extends AnalytycsProvider {
  BackendAnalyticsProvider({String? name})
      : super(
          identifier: BackendAnalyticsProviderIdentifier(name: name),
          interceptors: const [],
        );

  @override
  BackendEventResolver get resolver => const BackendEventResolver();

  @override
  Future<void> setSession(Session? session) async {}
}
```

## Контекст і інтерсептори

- `LogEvent.context` дозволяє прикріпити типізовані metadata через `ContextEntry`.
- Під час dispatch `EventDispatchContext` містить типізований контекст із події (`event.context`).
- Доступ у резолверах/інтерсепторах: `context.entry<MyEntry>()`.
