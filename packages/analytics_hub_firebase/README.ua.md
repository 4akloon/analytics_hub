## analytics_hub_firebase

> English version: [README.md](README.md)

`analytics_hub_firebase` інтегрує `analytics_hub` з Firebase Analytics.

Поточний обсяг функціоналу — тільки `LogEvent`:
події мапляться у `FirebaseAnalytics.logEvent`.

## Встановлення

```yaml
dependencies:
  analytics_hub: ^0.3.0
  analytics_hub_firebase: ^0.3.0
  firebase_core: ^2.0.0
  firebase_analytics: ^10.0.0
```

## Використання

```dart
final hub = AnalyticsHub(
  sessionDelegate: yourSessionDelegate,
  providers: [
    FirebaseAnalyticsHubProvider.fromInstance(),
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
        EventProvider(FirebaseAnalyticsHubProviderIdentifier()),
      ];
}
```

## Сесія

Провайдер синхронізує `Session.id` з Firebase user id:

```dart
@override
Future<void> setSession(Session? session) async {
  await _analytics.setUserId(id: session?.id);
}
```
