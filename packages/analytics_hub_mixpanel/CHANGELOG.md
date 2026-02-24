## 0.3.3 - 2026-02-24

### Changed
- Updated dependency constraint to `analytics_hub: ">=0.3.3 <0.4.0"`.
- Added `logging` dependency and provider-level logging for session handling.
- Updated `MixpanelAnalyticsHubProvider` constructor call to the new core provider contract (explicit `interceptors`).
- Implemented provider `flush()` override delegated to `Mixpanel.flush()`.
- Added tests for provider flush delegation.

## 0.3.1 - 2026-02-24

### Changed
- Updated dependency constraint to `analytics_hub: ">=0.3.1 <0.4.0"`.
- Synced resolver/tests with the refined typed context API used by core (`Context`/`ContextEntry`-based dispatch context).
- Updated README docs (EN/UA) and version snippets to `0.3.1`.

## 0.3.0 - 2026-02-24

### Changed
- Updated examples/tests/docs to the log-only core API (`List<EventProvider>`).
- Updated dependency constraint to `analytics_hub: ">=0.3.0 <0.4.0"`.
- Migrated `MixpanelEventResolver` to new core resolver API based on
  `ResolvedEvent` and `EventDispatchContext`.
- Updated tests for the new dispatch contract.

### Breaking Changes
- Version aligned with `analytics_hub` `0.3.x` API changes.
- Resolver implementation now must implement
  `resolve({required ResolvedEvent event, required EventDispatchContext context})`.

## 0.2.1 - 2026-02-23

### Changed
- Updated README to use `providers` and `MixpanelAnalyticsHubProviderIdentifier`.
- Updated installation/dependency snippets to current versions.

### Breaking Changes
- `MixpanelAnalyticsHubProviderKey` was renamed to `MixpanelAnalyticsHubProviderIdentifier`.

## 0.2.0 - 2026-02-23

### Changed
- Migrated provider identity usage from `ProviderKey` to `ProviderIdentifier`.
- Updated examples and tests to the new `Event.providers` API with `EventProvider`.
- Updated dependency constraint to `analytics_hub: ">=0.2.0 <0.3.0"`.

### Breaking Changes
- `MixpanelAnalyticsHubProvider` now uses `identifier` instead of `key`.
- `MixpanelAnalyticsHubProviderKey` now extends `ProviderIdentifier<MixpanelEventResolver>`.
- Events targeting Mixpanel must define `providers` (`List<EventProvider<...>>`) instead of `providerKeys`.

## 0.1.0 - 2026-02-11

### Added
- Public API documentation for provider, key, and resolver.
- Dependency on `analytics_hub: ">=0.0.1 <0.2.0"`.

## 0.0.1 - 2026-02-10

### Added
- Initial Mixpanel provider integration for `analytics_hub`.
- `MixpanelAnalyticsHubProvider` and `MixpanelAnalyticsHubProviderKey` for routing events to Mixpanel.
- `MixpanelEventResolver` mapping `LogEvent` to `Mixpanel.track`.
- Session handling in provider using `Mixpanel.identify` for authenticated users and `identify`/`reset` logic for anonymous sessions.

