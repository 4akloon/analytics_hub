## Analytics Hub Mixpanel Provider

> Ukrainian version: [README.ua.md](README.ua.md)

`analytics_hub_mixpanel` connects `analytics_hub` to Mixpanel.

Current scope is log-only: this package maps `LogEvent` to `Mixpanel.track`.
It uses the core `EventResolver` contract with `ResolvedEvent` payload.

## Installation

```yaml
dependencies:
  analytics_hub: ^0.3.0
  analytics_hub_mixpanel: ^0.3.0
  mixpanel_flutter: ^2.0.0
```

## Usage

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

Event example:

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

## Session handling

`MixpanelAnalyticsHubProvider` behavior:

- If session is present: calls `identify(session.id)`.
- If session is null and `getAnonymousId` callback is provided: identifies with that ID.
- Otherwise: calls `reset()`.
