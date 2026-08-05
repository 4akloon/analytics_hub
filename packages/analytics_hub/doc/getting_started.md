# Getting started

## Install

```yaml
dependencies:
  analytics_hub: ^0.5.0
  # and then any concrete providers you need, e.g.:
  # analytics_hub_firebase: ^0.5.0
  # analytics_hub_mixpanel: ^0.5.0
  # analytics_hub_appsflyer: ^0.5.0
```

## Send your first event

Every event goes through the same three steps: define it, register providers
on the hub, send it.

```dart
import 'package:analytics_hub/analytics_hub.dart';

class SignupEvent extends LogEvent {
  const SignupEvent(this.method) : super('sign_up');

  final String method;

  @override
  Map<String, Object?> get properties => {'method': method};

  @override
  List<EventProvider> get providers => const [
        EventProvider(FirebaseAnalyticsHubIdentifier()),
      ];
}

Future<void> main() async {
  final hub = AnalyticsHub(
    providers: [
      FirebaseAnalyticsHubProvider.fromInstance(),
    ],
  );

  await hub.sendEvent(const SignupEvent('email'));
  await hub.flush();
}
```

- `providers` on the event lists which registered providers should receive
  it, by `ProviderIdentifier`.
- SDK setup belongs in the app — pass already-initialized backend instances
  into provider constructors. The hub is ready as soon as you construct it.
- `sendEvent` resolves the event only for providers it targets; a provider not
  listed in `providers` never sees the event.

## Where to go next

- [providers.md](providers.md) — build your own provider instead of using an
  official one.
- [interceptors_and_context.md](interceptors_and_context.md) — cross-cutting
  behavior (renaming, redaction, sampling) and typed event metadata.
- [testing.md](testing.md) — test app code that calls `AnalyticsHub`.
