## 0.2.1 - 2026-02-23

### Changed
- Updated README to use `providers` and `FirebaseAnalyticsHubProviderIdentifier`.
- Refreshed supported-events docs to match current Firebase e-commerce coverage.

### Breaking Changes
- `FirebaseAnalyticsHubProviderKey` was renamed to `FirebaseAnalyticsHubProviderIdentifier`.

## 0.2.0 - 2026-02-23

### Changed
- Migrated provider identity usage from `ProviderKey` to `ProviderIdentifier`.
- Updated examples and tests to the new `Event.providers` API with `EventProvider`.
- Updated dependency constraint to `analytics_hub: ">=0.2.0 <0.3.0"`.

### Breaking Changes
- `FirebaseAnalyticsHubProvider` now uses `identifier` instead of `key`.
- `FirebaseAnalyticsHubProviderKey` now extends `ProviderIdentifier<FirebaseAnalyticsEventResolver>`.
- Events targeting Firebase must define `providers` (`List<EventProvider<...>>`) instead of `providerKeys`.

## 0.1.0 - 2026-02-11

### Added
- Implemented all GA4 e-commerce events in `FirebaseAnalyticsECommerceEventResolver`: `AddToCart`, `AddToWishlist`, `ViewCart`, `AddPaymentInfo`, `AddShippingInfo`, `BeginCheckout`, `Purchase`, `RemoveFromCart`, `SelectItem`, `ViewItem`, `ViewItemList`, `ViewPromotion`, `Refund` (in addition to existing `SelectPromotion`).
- Public API documentation for provider, key, and resolvers.
- Dependency on `analytics_hub: ">=0.1.0 <0.2.0"`.

## 0.0.1 - 2026-02-10

### Added
- Initial Firebase Analytics provider integration for `analytics_hub`.
- `FirebaseAnalyticsHubProvider` and `FirebaseAnalyticsHubProviderKey` for routing events to Firebase.
- `FirebaseAnalyticsEventResolver` mapping `LogEvent` to `FirebaseAnalytics.logEvent`.
- `FirebaseAnalyticsECommerceEventResolver` handling `SelectPromotionECommerceEvent` via `FirebaseAnalytics.logSelectPromotion`.
- Session handling in provider using `FirebaseAnalytics.setUserId` based on `Session.id`.

