## Analytics Hub Flutter

![Dart](https://img.shields.io/badge/Dart-%3E%3D3.5-0175C2?logo=dart&logoColor=white)
![Part of](https://img.shields.io/badge/part_of-analytics__hub-informational)

> Part of the analytics_hub workspace. New here? Start with the
> [root README](../../README.md).

> Ukrainian version: [README.ua.md](README.ua.md)

`analytics_hub_flutter` puts `analytics_hub` scopes on the widget tree.

- `AnalyticsScopeProvider` — wrap the app once in `.root(hub:)`, then wrap a
  page or a section to give every event sent from that subtree the scope's
  context and interceptors. Nested providers compose root → leaf.
- `AnalyticsImpression` — sends one event when its subtree first has half
  of its area on screen.

## Installation

```yaml
dependencies:
  analytics_hub: ^0.6.0
  analytics_hub_flutter: ^0.6.0
```

## Usage

```dart
runApp(
  AnalyticsScopeProvider.root(
    hub: hub,
    child: const MaterialApp(home: HomePage()),
  ),
);

// A page scope with a section scope inside it.
AnalyticsScopeProvider(
  name: 'home',
  context: const EventContext().withEntry(const PageEntry('home')),
  child: AnalyticsScopeProvider(
    name: 'create',
    context: const EventContext().withEntry(const ElementEntry('create')),
    child: AnalyticsImpression(
      event: () => const SectionViewedEvent(),
      child: Builder(
        builder: (context) => FilledButton(
          onPressed: () => AnalyticsScopeProvider.of(context)
              .sendEvent(const ToolTappedEvent('static_ad')),
          child: const Text('Static ad'),
        ),
      ),
    ),
  ),
)
```

`AnalyticsScopeProvider.of(context)` returns an `AnalyticsSink`: the hub
itself directly under the root, a `ScopedAnalytics` under a scope. Hand it
to a cubit or an analytics helper where the screen creates them, so they
send with the screen's scope without knowing about widgets.
Use `read(context)` where listening is not allowed — `initState`,
`BlocProvider.create`, callbacks.
`scopeOf(context)` returns the nearest `AnalyticsScope` (or `null` under the
root) for code that needs to read the chain.

Equal rebuilds avoid notifying dependents only when the `context` entries and
`interceptors` compare equal, so prefer `const` entries and interceptors or
give them value equality.

Context entries never become properties by themselves. Register an
interceptor on the hub that maps the nearest entries to the keys your
providers expect (see `example/main.dart`'s `SourceAppendInterceptor`).

## What crosses a route boundary

The provider builds an `InheritedTheme`, so Flutter's own overlay helpers —
`showDialog`, `showModalBottomSheet`, `showMenu`, dropdowns, popups — carry
the scope of the context they were opened from into what they show.
`showGeneralDialog`, `showCupertinoDialog`, `showCupertinoModalPopup` and
`SnackBar`s do not capture inherited themes, so they do not see the scope
unless they apply `InheritedTheme.capture` themselves. A route
pushed on a `Navigator` is built under the navigator, not under the page
that pushed it, and does not inherit the scope: give the destination its own
scope and pass whatever "where I came from" data it needs explicitly (route
parameters, arguments).

A sheet or dialog implemented with a hand-written `Route` only sees the
scope if that route applies `InheritedTheme.capture(from:, to:)` the way
`showModalBottomSheet` does.

## Impressions

```dart
AnalyticsImpression(
  event: () => const SectionViewedEvent(),
  visibleFraction: 0.5, // default
  child: section,
)
```

The event is built lazily when the threshold is reached and sent once per
`State` lifetime. A lazy `ListView` or `SliverList` disposes an item that
scrolls far away and sends again when it is rebuilt. For strictly once-only
reporting, keep the item alive (`AutomaticKeepAliveClientMixin` or
`addAutomaticKeepAlives`) or deduplicate in the receiver. Detection runs on
`visibility_detector`; in widget tests set
`VisibilityDetectorController.instance.updateInterval = Duration.zero` so
callbacks fire on the next frame.

## Example

`example/main.dart` wires a page scope, a section scope, an impression, a
tap and a hub-level `SourceAppendInterceptor`, with `LoggingTraceSink` on
so every dispatch prints its stages.
