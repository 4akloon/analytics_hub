## analytics_hub_mixpanel

**analytics_hub_mixpanel** — провайдер для інтеграції `analytics_hub`
з **Mixpanel**.

Він надає:

- `MixpanelAnalyticsHubProvider` — реалізація `AnalytycsProvider`, що працює з `Mixpanel`.
- `MixpanelAnalyticsHubProviderKey` — ключ провайдера для фільтрації подій.
- `MixpanelEventResolver` — резолвер, який мапить `LogEvent` у `mixpanel.track`.

## Встановлення

У `pubspec.yaml` вашого застосунку:

```yaml
dependencies:
  mixpanel_flutter: ^2.0.0

  analytics_hub: ^0.0.1
  analytics_hub_mixpanel: ^0.0.1
```

## Швидкий старт

Приклад (скорочений з `example/analytics_hub_mixpanel_example.dart`):

```dart
import 'package:analytics_hub/analytics_hub.dart';
import 'package:analytics_hub_mixpanel/analytics_hub_mixpanel.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

class EmptySessionDelegate implements HubSessionDelegate {
  @override
  Stream<Session?> get sessionStream => Stream.value(null);

  @override
  Future<Session?> getSession() async => null;
}

class ExampleLogEvent extends LogEvent {
  const ExampleLogEvent({required this.exampleProperty})
      : super('example_log_event');

  final String exampleProperty;

  @override
  Map<String, Object>? get properties => {'example_property': exampleProperty};

  @override
  Set<ProviderKey<LogEventResolver>> get providerKeys => {
        const MixpanelAnalyticsHubProviderKey(),
      };
}

Future<void> main() async {
  final mixpanel = await Mixpanel.init(
    'YOUR_MIXPANEL_TOKEN',
    trackAutomaticEvents: false,
  );

  final hub = AnalyticsHub(
    sessionDelegate: EmptySessionDelegate(),
    providers: [
      MixpanelAnalyticsHubProvider(mixpanel: mixpanel),
    ],
  );

  await hub.initialize();

  await hub.sendEvent(
    const ExampleLogEvent(exampleProperty: 'example_property'),
  );

  await hub.dispose();
}
```

## Підтримувані типи подій

`MixpanelEventResolver` реалізує:

- `EventResolver`
- `LogEventResolver`

і мапить лог‑події в `Mixpanel.track`.

### 1. Лог‑події (`LogEvent`)

Будь‑яка подія, що наслідується від `LogEvent` і містить
`MixpanelAnalyticsHubProviderKey` в `providerKeys`,
буде відправлена в Mixpanel:

```dart
class ExampleLogEvent extends LogEvent {
  const ExampleLogEvent({required this.exampleProperty})
      : super('example_log_event');

  final String exampleProperty;

  @override
  Map<String, Object>? get properties => {'example_property': exampleProperty};

  @override
  Set<ProviderKey<LogEventResolver>> get providerKeys => {
        const MixpanelAnalyticsHubProviderKey(),
      };
}
```

Мапінг у Mixpanel:

```dart
@override
Future<void> resolveLogEvent(LogEvent event) =>
    _mixpanel.track(event.name, properties: event.properties);
```

Тобто:

- `event.name` → `event` у Mixpanel;
- `event.properties` → `properties`.

### 2. Інші типи подій

На даний момент:

- `CustomLogEvent<T>` — **не мапиться** в `MixpanelEventResolver` (але ви можете
  зробити свій резолвер/похідний провайдер, якщо потрібно).
- `ECommerceEvent` — **не підтримується** цим провайдером.

Уся додаткова логіка (e‑commerce, custom events під Mixpanel) може бути
реалізована або в core (нові типи `Event`), або в окремому розширенні
резолвера, якщо це буде потрібно.

## Сесії користувача

`MixpanelAnalyticsHubProvider` реалізує логіку сесій:

```dart
@override
Future<void> setSession(Session? session) async {
  if (session != null) {
    await _mixpanel.identify(session.id);
  } else if (_getAnonymousId case final callback?) {
    await _mixpanel.identify(callback());
  } else {
    await _mixpanel.reset();
  }
}
```

- Якщо `Session` є — Mixpanel ідентифікується по `session.id`.
- Якщо `Session == null` і переданий `getAnonymousId` —
  використовується анонімний ID.
- Якщо `Session == null` і анонімного ID немає — робиться `reset()`.

Це дозволяє будувати зручну модель:

- авторизований користувач → трекається по `Session.id`;
- неавторизований → по анонімному ID, який ви контролюєте.

## Які івенти планується реалізувати

Логічні наступні кроки для Mixpanel‑провайдера:

- підтримка **типізованих кастомних подій** через `CustomLogEvent<T>` і
  додатковий інтерфейс резолвера;
- можливі e‑commerce події (`ECommerceEvent`), які будуть мапитись
  у властивості подій/профілів у Mixpanel.

Це дозволить:

- мати однакову модель e‑commerce, як і у Firebase;
- зберегти типізацію та уникати “магічних” рядків у коді.

## Коли варто використовувати analytics_hub_mixpanel

- Ви вже використовуєте Mixpanel і хочете:
  - описувати події як Dart‑класи (`LogEvent` тощо);
  - від’єднати бізнес‑логіку від конкретного SDK;
  - уніфікувати модель подій з іншими аналітиками.
- Ви плануєте або вже користуєтесь іншими провайдерами `analytics_hub`
  (наприклад, Firebase) і хочете відправляти **ті самі події**
  одночасно в Mixpanel та інші системи.

