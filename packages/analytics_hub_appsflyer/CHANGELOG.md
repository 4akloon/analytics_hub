## 0.4.0 - 2026-02-26

### Added
- Initial Appsflyer provider integration for `analytics_hub`:
  - `AppsflyerAnalyticsHubProvider` forwards `LogEvent` to `AppsflyerSdk.logEvent`.
  - `AppsflyerAnalyticsHubIdentifier` for routing events to Appsflyer.
  - Required `getAnonymousId` callback used when the hub session becomes `null`
    to set an anonymous customer user ID via `AppsflyerSdk.setCustomerUserId`.
- Example usage and tests for the provider and resolver.

