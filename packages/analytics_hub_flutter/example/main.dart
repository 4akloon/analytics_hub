import 'dart:async';

import 'package:analytics_hub/analytics_hub.dart';
import 'package:analytics_hub_flutter/analytics_hub_flutter.dart';
import 'package:flutter/material.dart';

/// Wrap the app once in [AnalyticsScopeProvider.root], then scope pages and
/// sections. This file is meant to be copied into an app's `main.dart`.
void main() {
  final hub = AnalyticsHub(
    providers: [PrintingProvider()],
    interceptors: const [SourceAppendInterceptor()],
    traceSinks: [LoggingTraceSink(verbose: true)],
  );
  runApp(
    AnalyticsScopeProvider.root(
      hub: hub,
      child: const MaterialApp(home: HomePage()),
    ),
  );
}

/// A page scope with a section scope inside it.
class HomePage extends StatelessWidget {
  /// Creates the page.
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => AnalyticsScopeProvider(
        name: 'home',
        context: const EventContext().withEntry(const PageEntry('home')),
        child: Scaffold(
          body: ListView(
            children: const [
              SizedBox(height: 24),
              CreateSection(),
            ],
          ),
        ),
      );
}

/// A section that reports an impression and a tap, both with
/// `source_page=home` and `source_element=create` appended by
/// [SourceAppendInterceptor].
class CreateSection extends StatelessWidget {
  /// Creates the section.
  const CreateSection({super.key});

  @override
  Widget build(BuildContext context) => AnalyticsScopeProvider(
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
      );
}

/// Marks the page an event was sent from.
final class PageEntry extends ContextEntry {
  /// Creates a page entry.
  const PageEntry(this.name);

  /// Page name.
  final String name;

  @override
  String toString() => 'Page($name)';
}

/// Marks the element an event was sent from.
final class ElementEntry extends ContextEntry {
  /// Creates an element entry.
  const ElementEntry(this.name);

  /// Element name.
  final String name;

  @override
  String toString() => 'Element($name)';
}

/// Maps the nearest page and element entries to properties.
final class SourceAppendInterceptor implements EventInterceptor {
  /// Creates the interceptor.
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
          'source_page': context.entry<PageEntry>()?.name,
          'source_element': context.entry<ElementEntry>()?.name,
        }),
        context,
      );
}

/// Sent once when the section is half visible.
class SectionViewedEvent extends Event {
  /// Creates the event.
  const SectionViewedEvent() : super('section_viewed');

  @override
  List<EventProvider> get providers => const [
        EventProvider(PrintingProviderKey()),
      ];
}

/// Sent on every tap of a tool card.
class ToolTappedEvent extends Event {
  /// Creates the event for [tool].
  const ToolTappedEvent(this.tool) : super('tool_tapped');

  /// The tool that was tapped.
  final String tool;

  @override
  Map<String, Object?> get properties => {'tool': tool};

  @override
  List<EventProvider> get providers => const [
        EventProvider(PrintingProviderKey()),
      ];
}

/// Identifies [PrintingProvider].
class PrintingProviderKey extends ProviderIdentifier {
  /// Creates the key.
  const PrintingProviderKey() : super(name: 'printing');
}

/// A provider that prints what it receives.
class PrintingProvider extends AnalyticsProvider {
  /// Creates the provider.
  PrintingProvider()
      : super(identifier: const PrintingProviderKey(), interceptors: const []);

  @override
  EventResolver get resolver => const PrintingResolver();
}

/// Prints the event name and properties.
class PrintingResolver implements EventResolver {
  /// Creates the resolver.
  const PrintingResolver();

  @override
  Future<void> resolve(
    ResolvedEvent event, {
    required EventDispatchContext context,
  }) async {
    debugPrint('${event.name} ${event.properties}');
  }
}
