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
hub interceptor 1 → hub interceptor 2 → ... → provider interceptor 1 → ... → resolver
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
- `correlationId` — a per-dispatch id for tying together logs and interceptor
  actions across the chain.

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
