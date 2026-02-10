## 0.0.1 - 2026-02-10

### Added
- Initial Mixpanel provider integration for `analytics_hub`.
- `MixpanelAnalyticsHubProvider` and `MixpanelAnalyticsHubProviderKey` for routing events to Mixpanel.
- `MixpanelEventResolver` mapping `LogEvent` to `Mixpanel.track`.
- Session handling in provider using `Mixpanel.identify` for authenticated users and `identify`/`reset` logic for anonymous sessions.

