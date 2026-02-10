## 0.0.1 - 2026-02-10

### Added
- Initial implementation of `AnalyticsHub` to fan-out events to multiple analytics providers.
- Core event hierarchy: `Event`, `LogEvent`, `CustomLogEvent<T>`, `ECommerceEvent` and `SelectPromotionECommerceEvent`.
- Provider abstraction: `AnalytycsProvider<R>`, `ProviderKey<R>`, `HubSessionDelegate` and `Session` for centralized session management.

