## analytics_hub

![Dart](https://img.shields.io/badge/Dart-%3E%3D3.5-0175C2?logo=dart&logoColor=white)
![Part of](https://img.shields.io/badge/part_of-analytics__hub-informational)

> Частина монорепозиторію analytics_hub. Новачок? Почніть з
> [кореневого README](../../README.md).

> English version: [README.md](README.md)

`analytics_hub` — core-пакет для маршрутизації аналітики між провайдерами
з єдиним API подій, інтерсепторами та типізованим контекстом.

Поточна модель подій навмисно спрощена: підтримується тільки `LogEvent`.

## Що входить у пакет

- `AnalyticsHub` — центральна точка відправки подій.
- `AnalyticsDispatcher` — контракт відправки подій; його реалізують хаб і scope-и з `scoped()`.
- `LogEvent` — базова подія з `name`, `properties` і `providers`.
- `AnalyticsProvider` — базовий клас провайдера.
- `ProviderIdentifier` — ідентифікатор провайдера.
- `EventResolver` — контракт обробки подій у провайдері.
- `EventInterceptor` — middleware для трансформації/дропу подій.
- `EventContext` + `ContextEntry` — типізований контекст події.
- `EventPropertiesContributor` — opt-in: `ContextEntry`, що додає свої значення в `properties` події.

## Встановлення

```yaml
dependencies:
  analytics_hub: ^0.5.1
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
3. Успадкуйтесь від `AnalyticsProvider` і поверніть resolver.

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

class BackendAnalyticsProvider extends AnalyticsProvider {
  BackendAnalyticsProvider({String? name})
      : super(
          identifier: BackendAnalyticsProviderIdentifier(name: name),
          interceptors: const [],
        );

  @override
  BackendEventResolver get resolver => const BackendEventResolver();
}
```

## Контекст і інтерсептори

- `LogEvent.context` дозволяє прикріпити типізовані metadata через `ContextEntry`.
- Під час dispatch `EventDispatchContext` містить типізований контекст із події (`event.context`).
- Доступ у резолверах/інтерсепторах: `context.entry<MyEntry>()`.

## Scoped-контекст

`scoped()` повертає незмінний `AnalyticsDispatcher`, який застосовує
`EventContext` до кожної відправленої через нього події.

```dart
final flowAnalytics = analyticsHub.scoped(
  context: const EventContext().withEntry(
    const FlowSourceContextEntry(page: 'home', element: 'create_video'),
  ),
);

await flowAnalytics.sendEvent(const GenerationCompletedEvent());
```

- Scope-и можна вкладати: `outer < inner < event.context` для записів одного типу.
- Створення дочірнього scope-а не змінює батьківський; паралельні scope-и ізольовані.
- `ContextEntry` за замовчуванням — лише metadata. Лише записи, що реалізують
  `EventPropertiesContributor`, потрапляють у `properties`; при конфлікті ключів
  значення з контексту перемагає.
- Пакет не керує життєвим циклом flow: створення, зберігання й відмова від
  scope-а — відповідальність застосунку.

Детальніше: [doc/interceptors_and_context.md](doc/interceptors_and_context.md#scoped-analytics-context).
