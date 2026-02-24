## 0.3.0 - 2026-02-24

### Changed
- Updated dependency constraint to `analytics_hub: ">=0.3.0 <0.4.0"`.
- Updated examples/tests/docs to the log-only core API (`List<EventProvider>`).

### Breaking Changes
- Version aligned with `analytics_hub` `0.3.x` API changes.

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

