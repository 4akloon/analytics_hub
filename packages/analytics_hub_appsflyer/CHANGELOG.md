## 0.5.0 - 2026-08-05

### Added
- Optional `interceptors` constructor parameter for provider-level interceptors.

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

