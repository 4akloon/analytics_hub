## 0.6.0 - 2026-09-10

### Changed
- Migrated to `appsflyer_sdk` 7.x: dependency constraint is now
  `>=7.0.0 <8.0.0`.

### Breaking Changes
- Requires `appsflyer_sdk` 7.x — 6.x is no longer supported. The two majors
  cannot be supported from one version: SDK 7 renamed the plugin type and
  changed `logEvent` from positional to named arguments. Stay on 0.5.x if you
  need `appsflyer_sdk` 6.x.
- `AppsflyerAnalyticsHubProvider`'s `appsFlyerSdk` parameter now takes an
  `AppsFlyerSdk` (SDK 7 renamed `AppsflyerSdk` -> `AppsFlyerSdk`). Pass the
  shared `AppsFlyerSdk.instance`; `AppsflyerSdk(AppsFlyerOptions(...))` is gone.
- Raised the minimum Dart SDK to `>=3.9.0` (Flutter `>=3.35.0`), as required by
  `appsflyer_sdk` 7.x.

## 0.5.0 - 2026-08-05

### Added
- Optional `interceptors` constructor parameter for provider-level interceptors.

### Changed
- Removed the `logging` dependency; `flush()` no longer logs a "not supported"
  message and simply inherits the base no-op.

### Breaking Changes
- Removed `setSession` and the required `getAnonymousId` parameter along with core
  session support. Manage the customer user ID directly via
  `AppsflyerSdk.setCustomerUserId`.
- Updated dependency constraint to `analytics_hub: ">=0.5.0 <0.6.0"`.

## 0.4.0 - 2026-02-26

### Added
- Initial Appsflyer provider integration for `analytics_hub`:
  - `AppsflyerAnalyticsHubProvider` forwards `LogEvent` to `AppsflyerSdk.logEvent`.
  - `AppsflyerAnalyticsHubIdentifier` for routing events to Appsflyer.
  - Required `getAnonymousId` callback used when the hub session becomes `null`
    to set an anonymous customer user ID via `AppsflyerSdk.setCustomerUserId`.
- Example usage and tests for the provider and resolver.

