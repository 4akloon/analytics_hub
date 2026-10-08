import 'dart:async';

import 'package:analytics_hub/analytics_hub.dart';
import 'package:test/test.dart';

final class _Page extends ContextEntry {
  const _Page(this.name);

  final String name;
}

final class _NoopInterceptor implements EventInterceptor {
  const _NoopInterceptor(this.name);

  @override
  final String name;

  @override
  FutureOr<InterceptorResult> intercept({
    required ResolvedEvent event,
    required EventDispatchContext context,
    required NextEventInterceptor next,
  }) =>
      next(event, context);
}

void main() {
  group('AnalyticsScope', () {
    test('attributes its context records to scope:<name>', () {
      final scope = AnalyticsScope(
        name: 'home',
        context: const EventContext().withEntry(const _Page('home')),
      );

      expect(scope.source, equals('scope:home'));
      expect(scope.context.records.single.source, equals('scope:home'));
    });

    test('child keeps the parent and chain runs root to leaf', () {
      final root = AnalyticsScope(name: 'root');
      final home = root.child(name: 'home');
      final create = home.child(name: 'create');

      expect(create.parent, same(home));
      expect(
        create.chain.map((s) => s.name),
        equals(['root', 'home', 'create']),
      );
      expect(root.chain.map((s) => s.name), equals(['root']));
    });

    test('child never changes its parent', () {
      final home = AnalyticsScope(
        name: 'home',
        context: const EventContext().withEntry(const _Page('home')),
      );

      home.child(
        name: 'create',
        context: const EventContext().withEntry(const _Page('create')),
      );

      expect(home.context.records, hasLength(1));
      expect(home.interceptors, isEmpty);
    });

    test('effectiveContext appends the chain root to leaf', () {
      final home = AnalyticsScope(
        name: 'home',
        context: const EventContext().withEntry(const _Page('home')),
      );
      final builder = home.child(
        name: 'builder',
        context: const EventContext().withEntry(const _Page('builder')),
      );

      final context = builder.effectiveContext;

      expect(
        context.records.map((r) => r.source),
        equals(['scope:home', 'scope:builder']),
      );
      expect(context.entry<_Page>()?.name, equals('builder'));
    });

    test('equality is by name, context, interceptors and parent', () {
      const interceptor = _NoopInterceptor('a');
      AnalyticsScope build() => AnalyticsScope(
            name: 'home',
            context: const EventContext().withEntry(const _Page('home')),
            interceptors: const [interceptor],
          );

      expect(build(), equals(build()));
      expect(build().child(name: 'x'), equals(build().child(name: 'x')));
      expect(build(), isNot(equals(build().child(name: 'x'))));
      expect(
        build(),
        isNot(equals(AnalyticsScope(name: 'home'))),
      );
      expect(build().hashCode, equals(build().hashCode));
    });
  });
}
