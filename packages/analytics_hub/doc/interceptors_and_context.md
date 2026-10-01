# Interceptors and context

## Interceptors

Use interceptors for cross-cutting behavior (renaming events, redaction,
sampling) without touching individual events or providers.

```dart
final class PrefixInterceptor implements EventInterceptor {
  const PrefixInterceptor(this.prefix);

  final String prefix;

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

Interceptors registered on `AnalyticsHub` (hub-level) always run before
interceptors registered on the individual `AnalyticsProvider` (provider-level).
For a single `sendEvent` call targeting one provider, the order is:

```
overrides → context properties → hub interceptor 1 → hub interceptor 2 → ...
  → provider interceptor 1 → ... → resolver
```

`overrides` applies `EventProvider.overrides`; `context properties` merges in
properties from `EventPropertiesContributor` entries (see
[Scoped analytics context](#scoped-analytics-context)). Both run before any
interceptor, so interceptors see the final name and properties.

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
- `correlationId` — a per-dispatch id for tying together logs and interceptor
  actions across the chain.

Its typed entries (and `ResolvedEvent.context`) hold the **effective
context**: the event's own `context` merged on top of any context inherited
from [scopes](#scoped-analytics-context). `originalEvent.context` is left
untouched.

## Typed context (`EventContext` / `ContextEntry`)

Events can carry typed metadata that interceptors and resolvers read without
parsing `properties`:

```dart
final class FeatureContextEntry extends ContextEntry {
  const FeatureContextEntry(this.feature);

  final String feature;
}

class ScreenViewEvent extends LogEvent {
  const ScreenViewEvent({required this.screenName})
      : super(
          'screen_view',
          context: const EventContext().withEntry(
            const FeatureContextEntry('navigation'),
          ),
        );

  final String screenName;

  @override
  Map<String, Object?> get properties => {'screen_name': screenName};
}
```

`EventDispatchContext` (which implements the same `Context` contract as
`EventContext`) copies the originating event's entries, so any interceptor or
resolver can read them back with `context.entry<FeatureContextEntry>()`. There
is one entry per `ContextEntry` subtype — registering a second entry of the
same type replaces the first.

## Scoped analytics context

A **scope** is an `AnalyticsDispatcher` that applies an `EventContext` to
every event sent through it. Create one with `scoped()`:

```dart
final flowAnalytics = analyticsHub.scoped(
  context: const EventContext().withEntry(
    const FlowSourceContextEntry(page: 'home', element: 'create'),
  ),
);
```

`AnalyticsHub` and every scope implement `AnalyticsDispatcher`
(`sendEvent` + `scoped`), so code that only sends events can depend on the
interface instead of the hub. A scope is not a second hub: it shares the
hub's providers, routing and interceptors and only carries its context.

### Immutable and safe across concurrent flows

A scope never changes after it is created, and the hub has no "current"
context. Two flows running at the same time each use their own scope and
cannot see each other's metadata:

```dart
final flowA = analyticsHub.scoped(context: contextA);
final flowB = analyticsHub.scoped(context: contextB);

await Future.wait([
  flowA.sendEvent(eventA), // sees only contextA
  flowB.sendEvent(eventB), // sees only contextB
]);
```

Events sent through `analyticsHub.sendEvent` directly never see scoped
metadata.

### Nested scopes and precedence

`scoped()` can be called on a scope. The child inherits the parent's context;
creating it does not change the parent.

```dart
final generation = analyticsHub.scoped(context: generationContext);
final editor = generation.scoped(context: editorContext);

await editor.sendEvent(event); // generationContext + editorContext + event.context
await generation.sendEvent(event); // generationContext + event.context
```

There is one entry per `ContextEntry` type. When the same type is provided at
several levels, the more specific one wins:

```
outer scope  <  inner scope  <  event.context
```

### Context entries vs. event properties

A `ContextEntry` is **metadata by default**: interceptors, resolvers and
routing logic can read it, but it never reaches provider properties on its
own. To opt an entry into provider properties, also implement
`EventPropertiesContributor`:

```dart
final class FlowSourceContextEntry extends ContextEntry
    implements EventPropertiesContributor {
  const FlowSourceContextEntry({required this.page, required this.element});

  final String page;
  final String element;

  @override
  Map<String, Object?> toEventProperties() => {
        'source_flow_page': page,
        'source_flow_element': element,
      };
}
```

The hub merges `toEventProperties()` of every contributing entry in the
effective context into `ResolvedEvent.properties`, right after overrides and
before the first interceptor. Providers need no changes — Firebase, Mixpanel,
AppsFlyer and custom resolvers just receive the final properties.

**Collision rule:** contributed properties win. If an event (or its
`EventOverrides.properties`) already has a key that a context entry also
contributes, the context value is used and a warning is logged under the
`AnalyticsHub` logger. Flow-level metadata is not silently overwritten by an
individual call site. Avoid emitting the same key from two different
contributing entries.

### Full example

```dart
final flowAnalytics = analyticsHub.scoped(
  context: const EventContext().withEntry(
    const FlowSourceContextEntry(page: 'home', element: 'create'),
  ),
);

await flowAnalytics.sendEvent(const FlowOpenedEvent());
await flowAnalytics.sendEvent(const GenerationCompletedEvent(model: 'veo'));
```

The provider's resolver receives:

```
flow_opened           {source_flow_page: home, source_flow_element: create}
generation_completed  {model: veo, source_flow_page: home, source_flow_element: create}
```

The runnable version is
[`example/scoped_context.dart`](../example/scoped_context.dart).

### Lifecycle is owned by your app

The package does not know when a flow starts or ends. Scope creation,
retention and disposal are owned by the consumer application — for example:

```dart
class BuilderTrackingHelper {
  BuilderTrackingHelper(this._analytics);

  final AnalyticsDispatcher _analytics;
  AnalyticsDispatcher? _flowAnalytics;

  void startFlow({required String page, required String element}) {
    _flowAnalytics = _analytics.scoped(
      context: EventContext().withEntry(
        FlowSourceContextEntry(page: page, element: element),
      ),
    );
  }

  Future<void> track(Event event) =>
      (_flowAnalytics ?? _analytics).sendEvent(event);

  void endFlow() => _flowAnalytics = null;
}
```

`scoped()` replaces manual context propagation inside helpers like this; it
does not replace the helper itself.

