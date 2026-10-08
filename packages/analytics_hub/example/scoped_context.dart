// ignore_for_file: unreachable_from_main, avoid_print

import 'dart:async';

import 'package:analytics_hub/analytics_hub.dart';

/// Run with `dart run example/scoped_context.dart`.
///
/// Prints what the provider receives and the trace of each dispatch:
///
/// ```
/// tool_tapped {tool: static_ad, source_page: home, source_element: create}
/// tool_tapped → printing  sent  3ms  5 stages  corr=event-…
///   scope:home            +ctx scope:home: Page(home)
///   scope:create          +ctx scope:create: Element(create)
///   interceptor:source    +source_page=home +source_element=create
///   overrides             —
///   resolver:printing     ok
/// app_opened null
/// app_opened → printing  sent  0ms  2 stages  corr=event-…
///   overrides             —
///   resolver:printing     ok
/// ```
void main() async {
  final hub = AnalyticsHub(
    providers: [PrintingProvider()],
    traceSinks: [PrintingTraceSink()],
  );

  final home = ScopedAnalytics(
    hub,
    AnalyticsScope(
      name: 'home',
      context: const EventContext().withEntry(const Page('home')),
      interceptors: const [SourceAppendInterceptor()],
    ),
  );
  final create = home.child(
    name: 'create',
    context: const EventContext().withEntry(const Element('create')),
  );

  await create.sendEvent(const ToolTappedEvent('static_ad'));
  await hub.sendEvent(const AppOpenedEvent());
}

final class Page extends ContextEntry {
  const Page(this.name);

  final String name;

  @override
  String toString() => 'Page($name)';
}

final class Element extends ContextEntry {
  const Element(this.name);

  final String name;

  @override
  String toString() => 'Element($name)';
}

final class SourceAppendInterceptor implements EventInterceptor {
  const SourceAppendInterceptor();

  @override
  String get name => 'source';

  @override
  FutureOr<InterceptorResult> intercept({
    required ResolvedEvent event,
    required EventDispatchContext context,
    required NextEventInterceptor next,
  }) =>
      next(
        event.withDefaults({
          'source_page': context.entry<Page>()?.name,
          'source_element': context.entry<Element>()?.name,
        }),
        context,
      );
}

class ToolTappedEvent extends Event {
  const ToolTappedEvent(this.tool) : super('tool_tapped');

  final String tool;

  @override
  Map<String, Object?> get properties => {'tool': tool};

  @override
  List<EventProvider> get providers => const [
        EventProvider(PrintingProviderKey()),
      ];
}

class AppOpenedEvent extends Event {
  const AppOpenedEvent() : super('app_opened');

  @override
  List<EventProvider> get providers => const [
        EventProvider(PrintingProviderKey()),
      ];
}

class PrintingProviderKey extends ProviderIdentifier {
  const PrintingProviderKey() : super(name: 'printing');
}

class PrintingProvider extends AnalyticsProvider {
  PrintingProvider()
      : super(identifier: const PrintingProviderKey(), interceptors: const []);

  @override
  EventResolver get resolver => const PrintingResolver();
}

class PrintingResolver implements EventResolver {
  const PrintingResolver();

  @override
  Future<void> resolve(
    ResolvedEvent event, {
    required EventDispatchContext context,
  }) async {
    print('${event.name} ${event.properties}');
  }
}

final class PrintingTraceSink implements TraceSink {
  @override
  void onTrace(DispatchTrace trace) =>
      print(const DispatchTraceFormatter().verbose(trace));
}
