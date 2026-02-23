## 0.2.1 - 2026-02-23

### Changed
- Updated README examples to the `Event.providers` / `EventProvider` API.
- Replaced legacy `ProviderKey`/`providerKeys` naming in docs with `ProviderIdentifier`/`providers`.
- Updated installation snippets to current package versions.

## 0.2.0 - 2026-02-23

### Added
- New provider-targeting model via `EventProvider<R, O>` and `EventOptions`.
- Per-provider overrides for `LogEvent` via `LogEventOptions` and `LogEventOverrides`.
- Typed per-provider payload overrides for `CustomLogEvent<T>` and `ECommerceEvent<T>` through `CustomLogEventOptions<T>` and `ECommerceEventOptions<T>`.

### Changed
- Renamed provider identity API from `ProviderKey` to `ProviderIdentifier`.
- `AnalyticsHub` now routes events via `Event.providers` and `EventProvider.identifier`.
- Extended public API documentation to cover new options and routing abstractions.

### Breaking Changes
- `Event.providerKeys` was removed. Implement `Event.providers` instead:
  `List<EventProvider<R, O>> get providers`.
- `ProviderKey<R>` was renamed to `ProviderIdentifier<R>`.
- `AnalytycsProvider` constructor parameter and field were renamed from `key` to `identifier`.
- `Event<R>` now requires options type parameter: `Event<R, O extends EventOptions>`.
- `LogEvent` now extends `Event<LogEventResolver, LogEventOptions>`.
- `CustomLogEvent<T>` moved to `custom_log_event.dart` and now extends
  `Event<CustomLogEventResolver<T>, CustomLogEventOptions<T>>`.
- `ECommerceEvent` now requires a payload type:
  `ECommerceEvent<T> extends Event<ECommerceEventResolver, ECommerceEventOptions<T>>`.

## 0.1.0 - 2026-02-11

### Added
- Public API documentation (`public_member_api_docs`) for all core types: `AnalyticsHub`, events, providers, session, and resolvers.
- Extended e-commerce event model with typed events and data classes: `AddToCart`, `AddToWishlist`, `ViewCart`, `AddPaymentInfo`, `AddShippingInfo`, `BeginCheckout`, `Purchase`, `RemoveFromCart`, `SelectItem`, `ViewItem`, `ViewItemList`, `ViewPromotion`, `Refund`, and `ECommerceEventItem`.

## 0.0.1 - 2026-02-10

### Added
- Initial implementation of `AnalyticsHub` to fan-out events to multiple analytics providers.
- Core event hierarchy: `Event`, `LogEvent`, `CustomLogEvent<T>`, `ECommerceEvent` and `SelectPromotionECommerceEvent`.
- Provider abstraction: `AnalytycsProvider<R>`, `ProviderKey<R>`, `HubSessionDelegate` and `Session` for centralized session management.

