## 0.3.1 - 2026-02-24

### Changed
- Refined interception context architecture by extracting `ContextEntry` and introducing shared `Context` contract (`Context`, `ContextEntry`, `EventContext`, `EventDispatchContext`).
- Updated dispatch context to use typed metadata context composition instead of separate hub/provider metadata maps.
- Removed hub-level interceptor context from `AnalyticsHub`; dispatch context now combines event context and provider interceptor context.
- Renamed provider metadata contract from `interceptorMetadata` to `interceptorContext`.
- Extended/updated tests for typed context merge behavior (`event context + provider context`) and removed obsolete hub-context assertions.
- Updated README docs (EN/UA), examples, and package version snippets for `0.3.1`.

## 0.3.0 - 2026-02-24

### Added
- Universal event interception pipeline with both hub-level and provider-level interceptors.
- Typed event metadata via `EventContext` / `EventContextEntry` (one entry per type, gql_exec-style).
- New dispatch models: `ResolvedEvent`, `EventDispatchContext`, and `InterceptorResult`.
- Hub-level metadata (`interceptorMetadata`) and provider-level metadata (`interceptorMetadata`) in dispatch context.

### Changed
- Reverted core event model to a single `LogEvent` approach.
- Simplified routing and provider abstractions to log-event-only contracts.
- Updated examples, tests, and documentation to use `List<EventProvider>`.
- `AnalyticsHub.sendEvent` now applies `EventProvider.options.overrides` before dispatch.
- `Event` now exposes `context` so metadata is created at event declaration time.
- Internal interception implementation was decomposed into `src/core/interception/*`
  components (`EventDispatcher`, context builder, chain executor, overrides applier).

### Removed
- `CustomLogEvent`, `CustomLogEventResolver`, and `CustomLogEventOptions`.
- `ECommerceEvent`, all e-commerce event/data types, and `ECommerceEventResolver`.
- Generic resolver typing from `ProviderIdentifier`, `AnalytycsProvider`, and `EventProvider`.

### Breaking Changes
- `Event` is no longer generic and resolves only via `LogEventResolver`.
- `AnalytycsProvider` is no longer generic and now exposes `LogEventResolver`.
- `ProviderIdentifier` is no longer generic.
- `EventResolver` contract changed from `resolveEvent(Event)` to
  `resolve({required ResolvedEvent event, required EventDispatchContext context})`.
- `AnalytycsProvider` now supports optional `interceptors` and `interceptorMetadata`.
- `AnalyticsHub` constructor now supports global `interceptors` and `interceptorMetadata`.

## 0.2.2 - 2026-02-23

### Changed
- Added nullable property value support in `LogEvent.properties`:
  `Map<String, Object?>?`.
- Added nullable property value support in `LogEventOverrides.properties`:
  `Map<String, Object?>?`.

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

