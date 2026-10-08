import 'package:analytics_hub/analytics_hub.dart';
import 'package:analytics_hub_flutter/analytics_hub_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Key extends ProviderIdentifier {
  const _Key() : super(name: 'test');
}

final class _Page extends ContextEntry {
  const _Page(this.name);

  final String name;
}

class _Resolver implements EventResolver {
  final List<ResolvedEvent> events = [];

  @override
  Future<void> resolve(
    ResolvedEvent event, {
    required EventDispatchContext context,
  }) async {
    events.add(event);
  }
}

class _Provider extends AnalyticsProvider {
  _Provider()
      : resolver = _Resolver(),
        super(identifier: const _Key(), interceptors: const []);

  @override
  final _Resolver resolver;
}

class _Event extends Event {
  const _Event(super.name);

  @override
  List<EventProvider> get providers => const [EventProvider(_Key())];
}

List<String> _sources(ResolvedEvent event) =>
    event.context.records.map((r) => r.source).toList();

Widget _app(AnalyticsHub hub, Widget child) => MaterialApp(
      home: AnalyticsScopeProvider.root(
        hub: hub,
        child: Scaffold(body: child),
      ),
    );

void main() {
  late _Provider provider;
  late AnalyticsHub hub;

  setUp(() {
    provider = _Provider();
    hub = AnalyticsHub(providers: [provider]);
  });

  group('AnalyticsScopeProvider', () {
    testWidgets('of under the root is the hub and scopeOf is null',
        (tester) async {
      AnalyticsSink? sink;
      AnalyticsSink? maybe;
      AnalyticsScope? scope;
      await tester.pumpWidget(
        _app(
          hub,
          Builder(
            builder: (context) {
              sink = AnalyticsScopeProvider.of(context);
              maybe = AnalyticsScopeProvider.maybeOf(context);
              scope = AnalyticsScopeProvider.scopeOf(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(sink, same(hub));
      expect(scope, isNull);
      expect(maybe, same(hub));
    });

    testWidgets('maybeOf under a scope is a ScopedAnalytics of that scope',
        (tester) async {
      AnalyticsSink? maybe;
      await tester.pumpWidget(
        _app(
          hub,
          AnalyticsScopeProvider(
            name: 'home',
            child: Builder(
              builder: (context) {
                maybe = AnalyticsScopeProvider.maybeOf(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(maybe, isA<ScopedAnalytics>());
      expect((maybe! as ScopedAnalytics).scope.name, equals('home'));
    });

    testWidgets('nested providers compose the chain root to leaf',
        (tester) async {
      await tester.pumpWidget(
        _app(
          hub,
          AnalyticsScopeProvider(
            name: 'home',
            context: const EventContext().withEntry(const _Page('home')),
            child: AnalyticsScopeProvider(
              name: 'create',
              context: const EventContext().withEntry(const _Page('create')),
              child: Builder(
                builder: (context) {
                  final scope = AnalyticsScopeProvider.scopeOf(context)!;
                  expect(
                    scope.chain.map((s) => s.name),
                    equals(['home', 'create']),
                  );
                  AnalyticsScopeProvider.of(context)
                      .sendEvent(const _Event('click'));
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final event = provider.resolver.events.single;
      expect(_sources(event), equals(['scope:home', 'scope:create']));
      expect(
        event.context.entries<_Page>().map((p) => p.name),
        equals(['home', 'create']),
      );
      expect(event.context.entry<_Page>()?.name, equals('create'));
    });

    testWidgets('of without a root throws a FlutterError', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              AnalyticsScopeProvider.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      final error = tester.takeException();
      expect(error, isA<FlutterError>());
      expect('$error', contains('AnalyticsScopeProvider.root'));
    });

    testWidgets('maybeOf without a root returns null', (tester) async {
      AnalyticsSink? sink = hub;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              sink = AnalyticsScopeProvider.maybeOf(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(sink, isNull);
    });

    testWidgets('a scope provider without a root throws', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AnalyticsScopeProvider(name: 'home', child: SizedBox()),
        ),
      );

      expect(tester.takeException(), isA<FlutterError>());
    });

    testWidgets('showDialog sees the scope it was opened from', (tester) async {
      AnalyticsScope? inDialog;
      await tester.pumpWidget(
        _app(
          hub,
          AnalyticsScopeProvider(
            name: 'home',
            child: Builder(
              builder: (context) => TextButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => Builder(
                    builder: (dialogContext) {
                      inDialog = AnalyticsScopeProvider.scopeOf(dialogContext);
                      return const SizedBox();
                    },
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(inDialog?.chain.map((s) => s.name), equals(['home']));
    });

    testWidgets('showModalBottomSheet sees the scope it was opened from',
        (tester) async {
      AnalyticsScope? inSheet;
      await tester.pumpWidget(
        _app(
          hub,
          AnalyticsScopeProvider(
            name: 'home',
            child: Builder(
              builder: (context) => TextButton(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  builder: (_) => Builder(
                    builder: (sheetContext) {
                      inSheet = AnalyticsScopeProvider.scopeOf(sheetContext);
                      return const SizedBox(height: 100);
                    },
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(inSheet?.chain.map((s) => s.name), equals(['home']));
    });

    testWidgets('a parent scope change reaches nested providers',
        (tester) async {
      late StateSetter rebuildOuter;
      var outerName = 'home';
      List<String>? chain;
      final inner = AnalyticsScopeProvider(
        name: 'create',
        child: Builder(
          builder: (context) {
            chain = AnalyticsScopeProvider.scopeOf(context)!
                .chain
                .map((s) => s.name)
                .toList();
            return const SizedBox();
          },
        ),
      );

      await tester.pumpWidget(
        _app(
          hub,
          StatefulBuilder(
            builder: (context, setState) {
              rebuildOuter = setState;
              return AnalyticsScopeProvider(name: outerName, child: inner);
            },
          ),
        ),
      );
      expect(chain, equals(['home', 'create']));

      rebuildOuter(() => outerName = 'builder');
      await tester.pump();
      expect(chain, equals(['builder', 'create']));
    });

    testWidgets('swapping the hub notifies dependents', (tester) async {
      var dependencyChanges = 0;
      late StateSetter rebuildOuter;
      var currentHub = hub;
      final otherHub = AnalyticsHub(providers: [_Provider()]);

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              rebuildOuter = setState;
              return AnalyticsScopeProvider.root(
                hub: currentHub,
                child: _DependencyCounter(onChange: () => dependencyChanges++),
              );
            },
          ),
        ),
      );
      expect(dependencyChanges, equals(1));

      rebuildOuter(() => currentHub = otherHub);
      await tester.pump();
      expect(dependencyChanges, equals(2));
    });

    testWidgets('rebuilding with equal inputs does not notify dependents',
        (tester) async {
      var dependencyChanges = 0;
      late StateSetter rebuildOuter;
      var name = 'home';

      await tester.pumpWidget(
        _app(
          hub,
          StatefulBuilder(
            builder: (context, setState) {
              rebuildOuter = setState;
              return AnalyticsScopeProvider(
                name: name,
                context: const EventContext().withEntry(const _Page('home')),
                child: _DependencyCounter(onChange: () => dependencyChanges++),
              );
            },
          ),
        ),
      );
      expect(dependencyChanges, equals(1));

      rebuildOuter(() {});
      await tester.pump();
      expect(dependencyChanges, equals(1));

      rebuildOuter(() => name = 'builder');
      await tester.pump();
      expect(dependencyChanges, equals(2));
    });
  });
}

class _DependencyCounter extends StatefulWidget {
  const _DependencyCounter({required this.onChange});

  final VoidCallback onChange;

  @override
  State<_DependencyCounter> createState() => _DependencyCounterState();
}

class _DependencyCounterState extends State<_DependencyCounter> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    AnalyticsScopeProvider.of(context);
    widget.onChange();
  }

  @override
  Widget build(BuildContext context) => const SizedBox();
}
