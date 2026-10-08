## 0.6.0 - 2026-10-08

### Added
- `AnalyticsScopeProvider`: puts an `AnalyticsScope` on the widget tree.
  `of(context)` returns the nearest `AnalyticsSink` (the hub under `.root`,
  a `ScopedAnalytics` under a scope), `maybeOf(context)` the same or `null`
  when there is no provider; `scopeOf(context)` the nearest `AnalyticsScope`. Built on `InheritedTheme`, so `showDialog`,
  `showModalBottomSheet`, menus and other overlays see the scope of the
  context they were opened from.
- `AnalyticsImpression`: sends one event through the nearest sink when its
  subtree first reaches `visibleFraction` (default 0.5), once per `State`
  lifetime — a lazy list that disposes the item re-sends when it is rebuilt.
