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

