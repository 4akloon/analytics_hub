# Interceptors and context

## Interceptors

Use interceptors for cross-cutting behavior (renaming events, redaction,
sampling) without touching individual events or providers.

```dart
final class PrefixInterceptor implements EventInterceptor {
  const PrefixInterceptor(this.prefix);

  final String prefix;

  @override
  String get name => 'prefix';

  @override
  FutureOr<InterceptorResult> intercept({
    required ResolvedEvent event,
    required EventDispatchContext context,
    required NextEventInterceptor next,
  }) {
    return next(
      event.copyWith(name: '${prefix}_${event.name}'),
      context,
    );
  }
}

final hub = AnalyticsHub(
  providers: [BackendAnalyticsProvider()],
  interceptors: [const PrefixInterceptor('prod')],
);
```

An interceptor can also drop an event instead of forwarding it, by returning
`InterceptorResult.drop(event, context: context)` instead of calling `next`.

## Chain execution order

Scope interceptors (when the event is sent with a scope) run first, then provider overrides, then hub-level interceptors, then provider-level ones.
For a single `sendEvent` call targeting one provider, the order is:

```
scope interceptor … → overrides → hub interceptor 1 → … → provider interceptor 1 → … → resolver
```

Each interceptor calls `next(event, context)` to continue the chain, or
returns `InterceptorResult.drop(...)` to stop it — the resolver only runs if
every interceptor in the chain called `next`.

## `EventDispatchContext`

Each event/provider pair gets its own `EventDispatchContext`, passed to every
interceptor and to the resolver. It exposes:

- `originalEvent` — the event before any overrides/interceptors ran.
- `eventProvider` — the `EventProvider` entry (identifier + overrides) that
  targeted this dispatch.
- `provider` — the resolved `AnalyticsProvider` instance receiving the event.
- `providerIdentifier` — shortcut for `eventProvider.identifier`.
- `timestamp` — when the dispatch context was created.
- `correlationId` — one id per `sendEvent` call, shared by every provider
  dispatch, for tying together logs and interceptor actions across the chain.
- `context` — the effective typed context of this dispatch (scope chain records
  root → leaf, then the event's own); `entry<T>()` is a shortcut.

## Typed context (`EventContext` / `ContextEntry`)

Events can carry typed metadata that interceptors and resolvers read without
parsing `properties`:

```dart
final class FeatureContextEntry extends ContextEntry {
  const FeatureContextEntry(this.feature);

  final String feature;
}

class ScreenViewEvent extends Event {
  const ScreenViewEvent({required this.screenName}) : super('screen_view');

  final String screenName;

  @override
  Map<String, Object?> get properties => {'screen_name': screenName};

  @override
  EventContext get context => const EventContext().withEntry(
        const FeatureContextEntry('navigation'),
      );
}
```

`EventContext` is an **append-only list of records**. Each `ContextRecord`
holds an entry and its `source` — `'event'` for entries declared on the
event, `'scope:<name>'` for entries a scope contributed, `'interceptor:<name>'`
for entries an interceptor appended. Nothing is merged or replaced:

- `entry<T>()` returns the *nearest* entry of type `T` (the last one added),
  matching with `is`, so a sealed base type finds its subtypes.
- `entries<T>()` returns every `T`, root → leaf; `all` every entry; `records`
  every record with its source.
- `withEntry` / `withEntries` append; `append(other)` concatenates two
  contexts; `attributedTo(source)` re-sources every record.

Interceptors and resolvers receive the effective context on both
`ResolvedEvent.context` and `EventDispatchContext.context`
(`context.entry<T>()` is a shortcut). To pass an entry down the chain, forward
`event.copyWith(context: ...)` and `context.copyWith(context: ...)`.

Context never writes properties by itself. An interceptor maps entries to
properties, and should let explicit values win:

```dart
final class SourceAppendInterceptor implements EventInterceptor {
  const SourceAppendInterceptor();

  @override
  String get name => 'source';

  @override
  FutureOr<InterceptorResult> intercept({
    required ResolvedEvent event,
    required EventDispatchContext context,
    required NextEventInterceptor next,
  }) {
    final page = context.entry<PageContextEntry>()?.name;
    return next(event.withDefaults({'source_page': page}), context);
  }
}
```

## Scopes

An `AnalyticsScope` is an immutable value: a name, a context, its own
interceptors and an optional parent. `AnalyticsHub.sendEvent(event, scope:)`
applies the whole chain root → leaf; `ScopedAnalytics` is an `AnalyticsSink`
that does so for every event sent through it:

```dart
final home = ScopedAnalytics(
  hub,
  AnalyticsScope(
    name: 'home',
    context: const EventContext().withEntry(const PageContextEntry('home')),
    interceptors: const [SourceAppendInterceptor()],
  ),
);
final create = home.child(
  name: 'create',
  context: const EventContext().withEntry(const ElementContextEntry('create')),
);

await create.sendEvent(const ToolTappedEvent('static_ad'));
```

Stage order for one event/provider pair:

```
scope interceptors (root → leaf) → provider overrides → hub interceptors
  → provider interceptors → resolver
```

A provider's `EventOverrides.properties` **replaces** the whole property map
and runs after scope interceptors, so properties a scope interceptor added do
not survive a provider's properties override. Hub-level interceptors run after
overrides and are unaffected — when events use property overrides, put shared
enrichment (such as source mapping) at hub level.

Context precedence is positional: `scope[root] … scope[leaf] … event`, and
`entry<T>()` picks the nearest. A scope interceptor runs only for events sent
through that scope or its descendants. Creating a child never changes its
parent; the package keeps no "current" scope, so where a scope starts and who
holds it is the application's decision.

`sendEvent` reads the event's name, properties, context and providers
**synchronously** before anything asynchronous runs, so what was true when
you called it is what gets sent.

## Tracing

Pass `traceSinks` to the hub to receive one `DispatchTrace` per event/provider
dispatch:

```dart
final hub = AnalyticsHub(
  providers: [...],
  traceSinks: [LoggingTraceSink(verbose: true)],
);
```

A trace holds the `correlationId` (shared by every provider dispatch of one
`sendEvent`), the original event name, the provider, timing, the outcome
(`DispatchSent`, `DispatchDropped(stage)`, `DispatchFailed(stage, error)`)
and one `StageRecord` per stage: its name (`scope:home`, `interceptor:source`,
`overrides`, `resolver:mixpanel`), kind, duration, a `PropertiesDiff`
(added / changed / removed), the context records it appended, and whether it
dropped or threw. `DispatchTraceFormatter` renders the compact line and the
verbose stage list that `LoggingTraceSink` logs:

```
click_create → mixpanel  sent  3ms  5 stages  corr=event-1733…
  scope:home            +ctx scope:home: PageContextEntry(home)
  interceptor:source    +source_page=home
  overrides             —
  interceptor:base      +user_id=42 +app_version=8.9.0
  resolver:mixpanel     ok
```

With no sinks the pipeline runs exactly as before: no stage is wrapped and no
diff is computed. An interceptor's stage covers what it received up to what it
passed to `next`; changes it makes to the result *after* `next` returned are
not attributed.
