import 'package:analytics_hub/analytics_hub.dart';
import 'package:analytics_hub_flutter/analytics_hub_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visibility_detector/visibility_detector.dart';

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
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
    provider = _Provider();
    hub = AnalyticsHub(providers: [provider]);
  });

  group('AnalyticsImpression', () {
    testWidgets('sends the event once when the subtree becomes visible',
        (tester) async {
      var built = 0;
      await tester.pumpWidget(
        _app(
          hub,
          AnalyticsScopeProvider(
            name: 'home',
            context: const EventContext().withEntry(const _Page('home')),
            child: AnalyticsImpression(
              event: () {
                built++;
                return const _Event('section_viewed');
              },
              child: const SizedBox(width: 100, height: 100),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(provider.resolver.events, hasLength(1));
      expect(built, equals(1));
      final event = provider.resolver.events.single;
      expect(event.name, equals('section_viewed'));
      expect(
        event.context.records.map((r) => r.source),
        equals(['scope:home']),
      );
    });

    testWidgets('does not send while the subtree is off screen',
        (tester) async {
      await tester.pumpWidget(
        _app(
          hub,
          // The item sits just past the 600 px viewport, inside the default
          // 250 px cache extent, so it stays built and keeps its State.
          ListView(
            children: [
              const SizedBox(height: 650),
              AnalyticsImpression(
                event: () => const _Event('section_viewed'),
                child: const SizedBox(height: 100),
              ),
            ],
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(provider.resolver.events, isEmpty);

      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();
      await tester.pump();

      expect(provider.resolver.events, hasLength(1));

      await tester.drag(find.byType(ListView), const Offset(0, 300));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();
      await tester.pump();

      expect(provider.resolver.events, hasLength(1), reason: 'sent once');
    });

    testWidgets('a lazy list that disposes the item sends again when rebuilt',
        (tester) async {
      await tester.pumpWidget(
        _app(
          hub,
          ListView(
            children: [
              const SizedBox(height: 2000),
              AnalyticsImpression(
                event: () => const _Event('section_viewed'),
                child: const SizedBox(height: 100),
              ),
              const SizedBox(height: 2000),
            ],
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      await tester.drag(find.byType(ListView), const Offset(0, -2000));
      await tester.pumpAndSettle();
      await tester.pump();

      expect(provider.resolver.events, hasLength(1));

      await tester.drag(find.byType(ListView), const Offset(0, 2000));
      await tester.pumpAndSettle();
      await tester.pump();

      expect(find.byType(AnalyticsImpression), findsNothing);

      await tester.drag(find.byType(ListView), const Offset(0, -2000));
      await tester.pumpAndSettle();
      await tester.pump();

      expect(provider.resolver.events, hasLength(2));
    });

    testWidgets('respects visibleFraction', (tester) async {
      await tester.pumpWidget(
        _app(
          hub,
          ListView(
            children: [
              const SizedBox(height: 550),
              AnalyticsImpression(
                event: () => const _Event('section_viewed'),
                visibleFraction: 0.9,
                child: const SizedBox(height: 200),
              ),
            ],
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(
        provider.resolver.events,
        isEmpty,
        reason: 'only the top 50 px of 200 are visible on a 600 px screen',
      );

      await tester.drag(find.byType(ListView), const Offset(0, -150));
      await tester.pumpAndSettle();
      await tester.pump();

      expect(provider.resolver.events, hasLength(1));
    });
  });
}
