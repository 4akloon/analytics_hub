## 0.1.0 - 2026-02-11

### Added
- Public API documentation (`public_member_api_docs`) for all core types: `AnalyticsHub`, events, providers, session, and resolvers.
- Extended e-commerce event model with typed events and data classes: `AddToCart`, `AddToWishlist`, `ViewCart`, `AddPaymentInfo`, `AddShippingInfo`, `BeginCheckout`, `Purchase`, `RemoveFromCart`, `SelectItem`, `ViewItem`, `ViewItemList`, `ViewPromotion`, `Refund`, and `ECommerceEventItem`.

## 0.0.1 - 2026-02-10

### Added
- Initial implementation of `AnalyticsHub` to fan-out events to multiple analytics providers.
- Core event hierarchy: `Event`, `LogEvent`, `CustomLogEvent<T>`, `ECommerceEvent` and `SelectPromotionECommerceEvent`.
- Provider abstraction: `AnalytycsProvider<R>`, `ProviderKey<R>`, `HubSessionDelegate` and `Session` for centralized session management.

