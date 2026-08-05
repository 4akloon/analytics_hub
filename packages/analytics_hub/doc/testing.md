# Testing code that uses `AnalyticsHub`

Don't reach for a real provider SDK in tests. Register a fake
`AnalyticsProvider` + `EventResolver` pair that records what it receives, and
assert against that.

```dart
import 'dart:async';

import 'package:analytics_hub/analytics_hub.dart';
import 'package:test/test.dart';

class FakeProviderIdentifier extends ProviderIdentifier {
  const FakeProviderIdentifier({super.name});
}

class FakeEventResolver implements EventResolver {
  FakeEventResolver(this.recorder);

  final List<ResolvedEvent> recorder;

  @override
  Future<void> resolve(
    ResolvedEvent event, {
    required EventDispatchContext context,
  }) async {
    recorder.add(event);
  }
}

class FakeProvider extends AnalyticsProvider {
  FakeProvider({required super.identifier, List<ResolvedEvent>? recorder})
      : _resolver = FakeEventResolver(recorder ?? []);

  final FakeEventResolver _resolver;

  @override
  EventResolver get resolver => _resolver;
}

void main() {
  test('sendEvent forwards the event to the targeted provider', () async {
    final recorder = <ResolvedEvent>[];
    final hub = AnalyticsHub(
      providers: [
        FakeProvider(
          identifier: const FakeProviderIdentifier(name: 'test'),
          recorder: recorder,
        ),
      ],
    );
    await hub.initialize();

    await hub.sendEvent(
      const _SignupEvent('email'),
    );

    expect(recorder, hasLength(1));
    expect(recorder.first.name, equals('sign_up'));
    expect(recorder.first.properties, equals({'method': 'email'}));

    await hub.dispose();
  });
}

class _SignupEvent extends LogEvent {
  const _SignupEvent(this.method) : super('sign_up');

  final String method;

  @override
  Map<String, Object?> get properties => {'method': method};

  @override
  List<EventProvider> get providers => const [
        EventProvider(FakeProviderIdentifier(name: 'test')),
      ];
}
```

Things worth asserting on:

- **What was sent** — `recorder` (a `List<ResolvedEvent>`) captures the
  resolved `name`/`properties` after overrides and interceptors ran.
- **Routing** — an event whose `providers` doesn't include a registered
  provider's identifier throws `AnalyticsProviderNotFoundException`; assert
  on that when testing routing mistakes.
- **Context** — if the code under test relies on interceptors or typed
  context, also record `EventDispatchContext` per call (add a
  `List<EventDispatchContext>? contextRecorder` alongside `recorder`) and
  assert on `context.entry<YourContextEntry>()`.
- **Lifecycle** — track `initialize`/`flush`/`dispose` calls on the fake
  provider directly if a test needs to verify lifecycle behavior.

This is the same pattern `analytics_hub`'s own test suite uses internally —
see `test/src/analytics_hub_test.dart` for the full `TestProvider`/
`TestEventResolver` implementation this guide is based on.
