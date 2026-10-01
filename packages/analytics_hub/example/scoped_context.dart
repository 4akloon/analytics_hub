// ignore_for_file: unreachable_from_main

import 'package:analytics_hub/analytics_hub.dart';

/// Run with `dart run example/scoped_context.dart`.
///
/// Prints what the provider receives for each event sent through a scope:
///
/// ```
/// flow_opened {source_flow_page: home, source_flow_element: create}
/// generation_completed {model: veo, source_flow_page: home, source_flow_element: create}
/// app_opened null
/// ```
void main() async {
  final analyticsHub = AnalyticsHub(providers: [PrintingProvider()]);

  // The application owns this reference: create it when the flow starts,
  // drop it when the flow ends.
  final flowAnalytics = analyticsHub.scoped(
    context: const EventContext().withEntry(
      const FlowSourceContextEntry(page: 'home', element: 'create'),
    ),
  );

  await flowAnalytics.sendEvent(const FlowOpenedEvent());
  await flowAnalytics.sendEvent(const GenerationCompletedEvent(model: 'veo'));

  // Events sent through the hub itself never see scoped metadata.
  await analyticsHub.sendEvent(const AppOpenedEvent());
}

/// Context entry that also contributes provider properties.
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

class FlowOpenedEvent extends Event {
  const FlowOpenedEvent() : super('flow_opened');

  @override
  List<EventProvider> get providers => const [
        EventProvider(PrintingProviderKey()),
      ];
}

class GenerationCompletedEvent extends Event {
  const GenerationCompletedEvent({required this.model})
      : super('generation_completed');

  final String model;

  @override
  Map<String, Object?> get properties => {'model': model};

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
