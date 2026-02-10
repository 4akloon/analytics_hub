## analytics_hub_firebase

**analytics_hub_firebase** — провайдер для інтеграції `analytics_hub`
з **Firebase Analytics**.

Він надає:

- `FirebaseAnalyticsHubProvider` — реалізація `AnalytycsProvider`, що працює з `FirebaseAnalytics`.
- `FirebaseAnalyticsHubProviderKey` — ключ провайдера для фільтрації подій.
- `FirebaseAnalyticsEventResolver` / `FirebaseAnalyticsECommerceEventResolver` —
  резолвери, які маплять події `analytics_hub` у виклики Firebase SDK.

## Встановлення

У `pubspec.yaml` вашого застосунку:

```yaml
dependencies:
  firebase_core: ^2.0.0
  firebase_analytics: ^10.0.0

  analytics_hub: ^0.0.1
  analytics_hub_firebase: ^0.0.1
```

Не забудьте додати ініціалізацію Firebase у `main()` згідно з офіційною документацією.

## Швидкий старт

Простий приклад (спрощена версія з `example/analytics_hub_firebase_example.dart`):

```dart
import 'package:analytics_hub/analytics_hub.dart';
import 'package:analytics_hub_firebase/analytics_hub_firebase.dart';

class EmptySessionDelegate implements HubSessionDelegate {
  @override
  Stream<Session?> get sessionStream => Stream.value(null);

  @override
  Future<Session?> getSession() async => null;
}

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
        const FirebaseAnalyticsHubProviderKey(),
      };
}

Future<void> main() async {
  // TODO: викличте Firebase.initializeApp() перед цим

  final hub = AnalyticsHub(
    sessionDelegate: EmptySessionDelegate(),
    providers: [
      FirebaseAnalyticsHubProvider.fromInstance(),
    ],
  );

  await hub.initialize();

  await hub.sendEvent(
    const ExampleSelectPromotionECommerceEvent(
      creativeName: 'creative_name',
    ),
  );

  await hub.dispose();
}
```

## Підтримувані типи подій

`FirebaseAnalyticsEventResolver` реалізує:

- `LogEventResolver`
- `ECommerceEventResolver`

і під капотом використовує `FirebaseAnalytics` та `FirebaseAnalyticsECommerceEventResolver`.

### 1. Лог‑події (`LogEvent`)

Будь‑яка подія, що наслідується від `LogEvent` і містить
`FirebaseAnalyticsHubProviderKey` в `providerKeys`,
буде відправлена в Firebase як `logEvent`:

```dart
class ExampleLogEvent extends LogEvent {
  const ExampleLogEvent({required this.value}) : super('example_log_event');

  final String value;

  @override
  Map<String, Object>? get properties => {'value': value};

  @override
  Set<ProviderKey<LogEventResolver>> get providerKeys => {
        const FirebaseAnalyticsHubProviderKey(),
      };
}
```

Мапінг у Firebase:

- викликається:

  ```dart
  _analytics.logEvent(
    name: event.name,
    parameters: event.properties,
  );
  ```

Тобто:

- `event.name` → `name` в `logEvent`;
- `event.properties` → `parameters`.

### 2. E‑commerce події (`ECommerceEvent`)

На даний момент підтримується:

- **`SelectPromotionECommerceEvent`**
  - через `FirebaseAnalyticsECommerceEventResolver`.

Мапінг у Firebase:

```dart
Future<void> _resolveSelectPromotionEvent(
  SelectPromotionECommerceEvent event,
) =>
    _analytics.logSelectPromotion(
      creativeName: event.data.creativeName,
      creativeSlot: event.data.creativeSlot,
      locationId: event.data.locationId,
      promotionId: event.data.promotionId,
      promotionName: event.data.promotionName,
      parameters: event.data.parameters,
    );
```

Відповідно, все, що ви покладете в `SelectPromotionECommerceEventData`,
піде в `logSelectPromotion`.

Приклад:

```dart
class PromoClickEvent extends SelectPromotionECommerceEvent {
  const PromoClickEvent({required this.promoId, required this.creativeName});

  final String promoId;
  final String creativeName;

  @override
  SelectPromotionECommerceEventData get data =>
      SelectPromotionECommerceEventData(
        creativeName: creativeName,
        promotionId: promoId,
      );

  @override
  Set<ProviderKey<ECommerceEventResolver>> get providerKeys => {
        const FirebaseAnalyticsHubProviderKey(),
      };
}
```

## Сесії користувача

`FirebaseAnalyticsHubProvider` реалізує `setSession`:

```dart
@override
Future<void> setSession(Session? session) async {
  await _analytics.setUserId(id: session?.id);
}
```

- Якщо `Session` є — виставляється `userId` у Firebase.
- Якщо `Session == null` — `userId` скидається (`id: null`).

Це дозволяє вам централізовано керувати сесією через `HubSessionDelegate`,
а не напряму через Firebase.

## Які івенти планується реалізувати

На рівні Firebase провайдера логічні подальші кроки:

- Додаткові e‑commerce події:
  - `view_item`, `view_item_list`, `select_item`,
  - `add_to_cart`, `add_to_wishlist`,
  - `begin_checkout`, `add_payment_info`, `add_shipping_info`,
  - `purchase`, `refund` та інші стандартні GA4 події.
- Відповідні підтипи `ECommerceEvent` у core‑пакеті та мапінги в
`FirebaseAnalyticsECommerceEventResolver`.

Загальна ідея — щоб усі стандартні e‑commerce сценарії GA4 можна було
описати типами в `analytics_hub` і автоматично мапити в Firebase через цей провайдер.

## Коли варто використовувати analytics_hub_firebase

- Ви вже використовуєте Firebase Analytics і хочете:
  - типізувати події;
  - мати єдину модель подій для кількох SDK;
  - керувати сесією централізовано.
- Ви плануєте додати інші провайдери (наприклад, Mixpanel), але
не хочете дублювати логіку подій.

