## analytics_hub

**analytics_hub** — це невеликий шар-агрегатор поверх аналітичних SDK (Firebase, Mixpanel, власні провайдери), який:

- **уніфікує модель подій** (логові, кастомні, e‑commerce);
- **надає єдину точку входу** (`AnalyticsHub`) замість прямої роботи з кожним SDK;
- **керує сесією користувача** й пробрасыває `Session` у всі підключені провайдери;
- дозволяє **легко додавати/відключати провайдери** без зміни бізнес‑логіки.

### Навіщо це потрібно

- Щоб не дублювати одну й ту саму подію під різні SDK (Firebase, Mixpanel тощо).
- Щоб не тягнути в домен/віджети залежності від конкретних аналітик.
- Щоб централізовано керувати сесіями та конфігурацією аналітики.
- Щоб легко додавати нові провайдери або відключати наявні.

Провайдери в цьому монорепо:

- Firebase: `analytics_hub_firebase`
- Mixpanel: `analytics_hub_mixpanel`

## Встановлення

У `pubspec.yaml` вашого застосунку:

```yaml
dependencies:
  analytics_hub: ^0.0.1
  # далі додаєте конкретні провайдери, наприклад:
  # analytics_hub_firebase: ^0.0.1
  # analytics_hub_mixpanel: ^0.0.1
```

## Основні сутності

- **`AnalyticsHub`** — фасад, через який ви відправляєте події.
- **`Event`** — базовий sealed‑клас для всіх подій.
- **`LogEvent`** — звичайна лог‑подія `name + properties`.
- **`CustomLogEvent<T>`** — типізовані кастомні події для конкретного резолвера.
- **`ECommerceEvent`** — e‑commerce події (зараз реалізовано `SelectPromotionECommerceEvent`).
- **`AnalytycsProvider<R extends EventResolver>`** — абстракція провайдера аналітики.
- **`EventResolver` / `LogEventResolver` / `CustomLogEventResolver<T>` / `ECommerceEventResolver`** — інтерфейси, через які події мапляться у конкретні SDK.
- **`ProviderKey<R>`** — ключ, що ідентифікує провайдера (по ньому подія розуміє, куди летіти).
- **`Session` / `HubSessionDelegate`** — модель сесії та делегат, який постачає поточну сесію і стрім оновлень.

## Які типи подій підтримує core

Сам пакет `analytics_hub` визначає **типи подій**, а конкретні провайдери вирішують, які з них вони підтримують.

### Лог‑події (`LogEvent`)

- Визначаються ім’ям (`name`) та `properties` (опційна `Map<String, Object>`).
- Підтримуються провайдерами, які реалізують `LogEventResolver`:
  - Firebase (`analytics_hub_firebase`)
  - Mixpanel (`analytics_hub_mixpanel`)
  - будь‑які ваші кастомні провайдери

### Кастомні лог‑події (`CustomLogEvent<T>`)

- Дозволяють створювати **сильно типізовані події**, які розуміє тільки певний резолвер.
- Використовуються разом із `CustomLogEventResolver<T>`.
- Приклад реалізації є в `example/analytics_core_example.dart`.

### E‑commerce події (`ECommerceEvent`)

Базовий sealed‑клас, з якого успадковуються конкретні e‑commerce події. Наразі в core є:

- **`SelectPromotionECommerceEvent`**
  - містить `SelectPromotionECommerceEventData` з полями:
    - `creativeName`
    - `creativeSlot`
    - `locationId`
    - `promotionId`
    - `promotionName`
    - `parameters` (`Map<String, Object>?`)

Підтримка за провайдерами:

- **Firebase** (`analytics_hub_firebase`):
  - `SelectPromotionECommerceEvent` → `FirebaseAnalytics.logSelectPromotion`.
- **Mixpanel** (`analytics_hub_mixpanel`):
  - наразі **не підтримує** `ECommerceEvent`, тільки `LogEvent`.

**План (e‑commerce, який можна буде розширити в майбутньому):**

- нові підтипи `ECommerceEvent` для стандартних GA4 сценаріїв:
  - `view_item`, `view_item_list`, `select_item`,
  - `add_to_cart`, `add_to_wishlist`,
  - `begin_checkout`, `add_payment_info`, `add_shipping_info`,
  - `purchase`, `refund` тощо;
- реалізація відповідних мапінгів у Firebase / Mixpanel провайдерах.

## Швидкий старт

Приклад використання `AnalyticsHub` з власним провайдером (аналог `example/analytics_core_example.dart`):

```dart
import 'package:analytics_hub/analytics_hub.dart';

class EmptySessionDelegate implements HubSessionDelegate {
  @override
  Stream<Session?> get sessionStream => Stream.value(null);

  @override
  Future<Session?> getSession() async => null;
}

void main() async {
  final hub = AnalyticsHub(
    sessionDelegate: EmptySessionDelegate(),
    providers: [
      ExampleAnalyticsProvider(),
      ExampleAnalyticsProvider(name: 'Another Provider'),
    ],
  );

  await hub.initialize();

  await hub.sendEvent(
    const ExampleLogEvent(exampleProperty: 'example_value'),
  );

  await hub.dispose();
}
```

## Як описати подію

### Лог‑подія (`LogEvent`)

```dart
class ExampleLogEvent extends LogEvent {
  const ExampleLogEvent({required this.exampleProperty})
      : super('example_log_event');

  final String exampleProperty;

  @override
  Map<String, Object>? get properties => {
        'example_property': exampleProperty,
      };

  @override
  Set<ProviderKey<LogEventResolver>> get providerKeys => {
        const ExampleAnalyticsProviderKey(),
        const ExampleAnalyticsProviderKey(name: 'Another Provider'),
      };
}
```

Ключові моменти:

- **`name`** — технічна назва події.
- **`properties`** — payload, який піде в провайдер.
- **`providerKeys`** — список провайдерів, які мають отримати цю подію.

### Кастомна лог‑подія (`CustomLogEvent<T>`)

```dart
sealed class ExampleCustomLogEvent
    extends CustomLogEvent<ExampleCustomLogEvent> {
  const ExampleCustomLogEvent();
}

abstract class FirstExampleCustomLogEvent extends ExampleCustomLogEvent {
  const FirstExampleCustomLogEvent({required this.exampleProperty});

  final String exampleProperty;
}

abstract class FirstExampleCustomLogEventImpl
    extends FirstExampleCustomLogEvent {
  const FirstExampleCustomLogEventImpl({required super.exampleProperty});

  @override
  Set<ProviderKey<CustomLogEventResolver<ExampleCustomLogEvent>>>
      get providerKeys => {const ExampleAnalyticsProviderKey()};
}
```

Тут головне:

- ви самі визначаєте ієрархію подій;
- резолвер (`CustomLogEventResolver<ExampleCustomLogEvent>`) вирішує, що робити з кожним підтипом.

### E‑commerce `SelectPromotionECommerceEvent`

```dart
class ExampleSelectPromotionECommerceEvent
    extends SelectPromotionECommerceEvent {
  const ExampleSelectPromotionECommerceEvent({required this.creativeName});

  final String creativeName;

  @override
  SelectPromotionECommerceEventData get data =>
      SelectPromotionECommerceEventData(
        creativeName: creativeName,
      );

  @override
  Set<ProviderKey<ECommerceEventResolver>> get providerKeys => {
        // Наприклад, FirebaseAnalyticsHubProviderKey
      };
}
```

## Як зробити власний провайдер (детально)

Власний провайдер у `packages/analytics_hub` складається з трьох частин:

1. **Ключ провайдера** (`ProviderKey<R>`).
2. **Резолвер(и) подій** (`EventResolver` + потрібні інтерфейси).
3. **Клас провайдера** (`AnalytycsProvider<R>`), який буде зареєстрований у `AnalyticsHub`.

### 1. Ключ провайдера (`ProviderKey`)

```dart
import 'package:analytics_hub/analytics_hub.dart';

class ExampleAnalyticsProviderKey extends ProviderKey<ExampleEventResolver> {
  const ExampleAnalyticsProviderKey({super.name});
}
```

- `R` у `ProviderKey<R>` — тип вашого основного резолвера.
- `name` можна використовувати, щоб відрізняти кілька інстансів
  (наприклад, кілька проектів Firebase, кілька Mixpanel workspace).

### 2. Резолвер подій (`EventResolver` + інтерфейси)

```dart
import 'package:analytics_hub/analytics_hub.dart';

class ExampleEventResolver
    implements
        EventResolver,
        LogEventResolver,
        CustomLogEventResolver<ExampleCustomLogEvent> {
  const ExampleEventResolver();

  @override
  Future<void> resolveLogEvent(LogEvent event) async {
    // тут ви мапите LogEvent у виклики вашого SDK
  }

  @override
  Future<void> resolveCustomLogEvent(
    CustomLogEvent<ExampleCustomLogEvent> event,
  ) async {
    // тут ви мапите конкретні кастомні події
  }
}
```

Ви реалізуєте тільки ті інтерфейси, які підтримує ваш провайдер:

- `LogEventResolver` — для простих лог‑подій;
- `CustomLogEventResolver<T>` — для складних типізованих сценаріїв;
- `ECommerceEventResolver` — для e‑commerce подій.

### 3. Клас провайдера (`AnalytycsProvider<R>`)

```dart
import 'package:analytics_hub/analytics_hub.dart';

class ExampleAnalyticsProvider
    extends AnalytycsProvider<ExampleEventResolver> {
  ExampleAnalyticsProvider({String? name})
      : super(key: ExampleAnalyticsProviderKey(name: name));

  @override
  ExampleEventResolver get resolver => const ExampleEventResolver();

  @override
  Future<void> initialize() async {
    // Ініціалізація вашого SDK (init, enable tracking тощо)
  }

  @override
  Future<void> setSession(Session? session) async {
    // Наприклад:
    // sdk.setUserId(session?.id);
  }

  @override
  Future<void> dispose() async {
    // Опційно: очистка ресурсів, закриття стрімів тощо
  }
}
```

Важливі моменти:

- `key` повинен бути унікальним для даного провайдера (тип + name).
- `resolver` повертає екземпляр резолвера (може бути кешований або створюватись щоразу).
- `setSession` викликається при зміні сесії (`HubSessionDelegate.sessionStream`).
- `initialize` / `dispose` — опційні, але зручні для життєвого циклу SDK.

### 4. Реєстрація провайдера в `AnalyticsHub`

```dart
final hub = AnalyticsHub(
  sessionDelegate: EmptySessionDelegate(),
  providers: [
    ExampleAnalyticsProvider(),
  ],
);

await hub.initialize();
await hub.sendEvent(const ExampleLogEvent(exampleProperty: 'value'));
```

Будь‑які події, які включають `ExampleAnalyticsProviderKey` у `providerKeys`,
будуть відправлені вашим провайдером.

## Коли варто робити власний провайдер

- У вас є **власна внутрішня аналітика** (logging service, data pipeline тощо).
- Потрібно додати підтримку **іншого стороннього SDK**, якого ще немає окремим пакетом.
- Ви хочете **обгорнути складний SDK** в простий резолвер, щоб не тягнути його напряму по всьому коду.

## Додаткова інформація

- Повний приклад — у `example/analytics_core_example.dart`.
- Провайдери Firebase і Mixpanel реалізовані в окремих пакетах:
  - `analytics_hub_firebase`
  - `analytics_hub_mixpanel`

