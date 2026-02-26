## analytics_hub_appsflyer

> English version: [README.md](README.md)

`analytics_hub_appsflyer` інтегрує `analytics_hub` з Appsflyer.

Поточний обсяг функціоналу — тільки `LogEvent`:
події мапляться у `AppsflyerSdk.logEvent`.
Резолвер використовує core-контракт `EventResolver` з `ResolvedEvent`.

## Встановлення

```yaml
dependencies:
  analytics_hub: ^0.4.0
  analytics_hub_appsflyer: ^0.4.0
  appsflyer_sdk: ^6.15.0
```

## Використання

```dart
final options = AppsFlyerOptions(
  afDevKey: 'YOUR_DEV_KEY',
  appId: 'YOUR_APP_ID',
  showDebug: true,
);

final sdk = AppsflyerSdk(options);
await sdk.initSdk(
  registerConversionDataCallback: false,
  registerOnAppOpenAttributionCallback: false,
  registerOnDeepLinkingCallback: false,
);

final hub = AnalyticsHub(
  sessionDelegate: yourSessionDelegate,
  providers: [
    AppsflyerAnalyticsHubProvider(
      appsFlyerSdk: sdk,
      getAnonymousId: () => 'anonymous-user-id',
    ),
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
        EventProvider(AppsflyerAnalyticsHubIdentifier()),
      ];
}
```

## Сесія

`AppsflyerAnalyticsHubProvider` працює так:

- якщо сесія є — викликає `setCustomerUserId(session.id)`;
- якщо сесія `null` — викликає обовʼязковий `getAnonymousId` і передає значення
  у `setCustomerUserId(...)`.

