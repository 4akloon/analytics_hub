## Analytics Hub Flutter

![Dart](https://img.shields.io/badge/Dart-%3E%3D3.5-0175C2?logo=dart&logoColor=white)
![Part of](https://img.shields.io/badge/part_of-analytics__hub-informational)

> Частина монорепозиторію analytics_hub. Новачок? Почніть з
> [кореневого README](../../README.md).

> English version: [README.md](README.md)

`analytics_hub_flutter` кладе скоупи `analytics_hub` на дерево віджетів.

- `AnalyticsScopeProvider` — оберніть застосунок один раз у `.root(hub:)`, а
  далі обгортайте сторінку чи секцію, щоб кожна подія, надіслана з цього
  піддерева, отримувала контекст та інтерсептори скоупу. Вкладені провайдери
  складаються від кореня до листка.
- `AnalyticsImpression` — надсилає одну подію, коли половина площі його
  піддерева вперше потрапляє на екран.

## Встановлення

```yaml
dependencies:
  analytics_hub: ^0.6.0
  analytics_hub_flutter: ^0.6.0
```

## Використання

```dart
runApp(
  AnalyticsScopeProvider.root(
    hub: hub,
    child: const MaterialApp(home: HomePage()),
  ),
);

// A page scope with a section scope inside it.
AnalyticsScopeProvider(
  name: 'home',
  context: const EventContext().withEntry(const PageEntry('home')),
  child: AnalyticsScopeProvider(
    name: 'create',
    context: const EventContext().withEntry(const ElementEntry('create')),
    child: AnalyticsImpression(
      event: () => const SectionViewedEvent(),
      child: Builder(
        builder: (context) => FilledButton(
          onPressed: () => AnalyticsScopeProvider.of(context)
              .sendEvent(const ToolTappedEvent('static_ad')),
          child: const Text('Static ad'),
        ),
      ),
    ),
  ),
)
```

`AnalyticsScopeProvider.of(context)` повертає `AnalyticsSink`: безпосередньо
під коренем це сам хаб, під скоупом — `ScopedAnalytics`. Передайте його в
кубіт чи аналітичний хелпер там, де їх створює екран, щоб вони надсилали
події зі скоупом екрана, нічого не знаючи про віджети.
Використовуйте `read(context)` там, де слухати заборонено — `initState`,
`BlocProvider.create`, колбеки. `scopeOf(context)`
повертає найближчий `AnalyticsScope` (або `null` під коренем) для коду, якому
треба прочитати ланцюжок.

Однакові перебудови не сповіщають залежних лише тоді, коли записи `context` та
`interceptors` порівнюються як рівні, тож надавайте перевагу `const`-записам і
`const`-інтерсепторам або дайте їм рівність за значенням.

Записи контексту самі по собі ніколи не стають властивостями. Зареєструйте на
хабі інтерсептор, який відображає найближчі записи на ключі, що очікують ваші
провайдери (див. `SourceAppendInterceptor` у `example/main.dart`).

## Що перетинає межу маршруту

Провайдер будує `InheritedTheme`, тож власні оверлей-хелпери Flutter —
`showDialog`, `showModalBottomSheet`, `showMenu`, випадні списки, попапи —
переносять скоуп контексту, з якого їх відкрито, у те, що вони показують.
`showGeneralDialog`, `showCupertinoDialog`, `showCupertinoModalPopup` і
`SnackBar` не захоплюють успадковані теми, тож скоуп вони не бачать, доки самі
не застосують `InheritedTheme.capture`.
Маршрут, доданий у `Navigator`, будується під навігатором, а не під сторінкою,
що його відкрила, і скоуп не успадковує: дайте призначенню власний скоуп, а
потрібні дані про те, «звідки я прийшов», передайте явно (параметри маршруту,
аргументи).

Шторка чи діалог на власноруч написаному `Route` бачить скоуп, лише якщо цей
маршрут застосовує `InheritedTheme.capture(from:, to:)`, як це робить
`showModalBottomSheet`.

## Імпресії

```dart
AnalyticsImpression(
  event: () => const SectionViewedEvent(),
  visibleFraction: 0.5, // default
  child: section,
)
```

Подія будується ліниво, коли досягнуто порогу, і надсилається один раз за час
життя `State`. Ледачий `ListView` чи `SliverList` знищує елемент, що відійшов
далеко, і надсилає знову, коли його перебудовують. Щоб звітувати строго один
раз, тримайте елемент живим (`AutomaticKeepAliveClientMixin` або
`addAutomaticKeepAlives`) або дедуплікуйте на стороні отримувача. Виявлення
працює на `visibility_detector`; у віджет-тестах встановіть
`VisibilityDetectorController.instance.updateInterval = Duration.zero`, щоб
колбеки спрацьовували на наступному кадрі.

## Приклад

`example/main.dart` збирає скоуп сторінки, скоуп секції, імпресію, тап і
`SourceAppendInterceptor` на рівні хаба, з увімкненим `LoggingTraceSink`, тож
кожна диспетчеризація друкує свої стадії.
