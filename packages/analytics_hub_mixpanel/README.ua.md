## analytics_hub_mixpanel

> English version: [README.md](README.md)

`analytics_hub_mixpanel` інтегрує `analytics_hub` з Mixpanel.

Поточний обсяг функціоналу — тільки `LogEvent`:
події мапляться у `Mixpanel.track`.
Резолвер використовує core-контракт `EventResolver` з `ResolvedEvent`.

## Встановлення

```yaml
dependencies:
  analytics_hub: ^0.3.3
  analytics_hub_mixpanel: ^0.3.3
  mixpanel_flutter: ^2.0.0
```

## Використання

```dart
final mixpanel = await Mixpanel.init(
  'YOUR_MIXPANEL_TOKEN',
  trackAutomaticEvents: false,
);

final hub = AnalyticsHub(
  sessionDelegate: yourSessionDelegate,
  providers: [
    MixpanelAnalyticsHubProvider(mixpanel: mixpanel),
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
        EventProvider(MixpanelAnalyticsHubProviderIdentifier()),
      ];
}
```

## Сесія

`MixpanelAnalyticsHubProvider` працює так:

- якщо сесія є — викликає `identify(session.id)`;
- якщо сесія `null`, але передано `getAnonymousId` — ідентифікує через цей id;
- інакше викликає `reset()`.
- `flush()` підтримується та делегується в `Mixpanel.flush()`.
