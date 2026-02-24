## analytics_hub_mixpanel

> English version: [README.md](README.md)

`analytics_hub_mixpanel` інтегрує `analytics_hub` з Mixpanel.

Поточний обсяг функціоналу — тільки `LogEvent`:
події мапляться у `Mixpanel.track`.

## Встановлення

```yaml
dependencies:
  analytics_hub: ^0.3.0
  analytics_hub_mixpanel: ^0.3.0
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
