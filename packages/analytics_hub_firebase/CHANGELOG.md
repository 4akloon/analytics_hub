## 0.0.1 - 2026-02-10

### Added
- Initial Firebase Analytics provider integration for `analytics_hub`.
- `FirebaseAnalyticsHubProvider` and `FirebaseAnalyticsHubProviderKey` for routing events to Firebase.
- `FirebaseAnalyticsEventResolver` mapping `LogEvent` to `FirebaseAnalytics.logEvent`.
- `FirebaseAnalyticsECommerceEventResolver` handling `SelectPromotionECommerceEvent` via `FirebaseAnalytics.logSelectPromotion`.
- Session handling in provider using `FirebaseAnalytics.setUserId` based on `Session.id`.

