## 0.3.0 - 2026-02-24

### Changed
- Reverted Firebase provider to a single `LogEvent` flow.
- Refreshed examples/tests/docs for `List<EventProvider>` and `ProviderIdentifier`.
- Updated dependency constraint to `analytics_hub: ">=0.4.0 <0.5.0"`.
- Migrated `FirebaseAnalyticsEventResolver` to new core resolver API based on
  `ResolvedEvent` and `EventDispatchContext`.
- Updated tests for the new dispatch contract.

### Removed
- `FirebaseAnalyticsECommerceEventResolver`.
- `ECommerceEventResolver` implementation from `FirebaseAnalyticsEventResolver`.
- All README references to GA4 e-commerce event classes in this package.

### Breaking Changes
- `analytics_hub_firebase` no longer supports e-commerce event types from core.
- Resolver implementation now must implement
  `resolve({required ResolvedEvent event, required EventDispatchContext context})`.

## 0.2.2 - 2026-02-23

### Changed
- Updated `FirebaseAnalyticsEventResolver` to support nullable values in
  `LogEvent.properties` by filtering out `null` entries before calling
  `FirebaseAnalytics.logEvent`.
- Updated dependency constraint to `analytics_hub: ">=0.2.2 <0.3.0"`.

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

