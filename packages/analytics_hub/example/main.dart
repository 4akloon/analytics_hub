// ignore_for_file: unreachable_from_main

import 'package:analytics_hub/analytics_hub.dart';

class EmptySessionDelegate implements HubSessionDelegate {
  @override
  Stream<Session?> get sessionStream => Stream.value(null);

  @override
  Future<Session?> getSession() async => null;
}

void main() async {
  final hub = AnalyticsHub(
    sessionDelegate: EmptySessionDelegate(),
    providers: [
      ExampleAnalyticsProvider(),
      ExampleAnalyticsProvider(name: 'Another Provider'),
    ],
  );

  await hub.initialize();

  await hub.sendEvent(const ExampleEvent(exampleProperty: 'example_value'));
}

class ExampleEvent extends Event {
  const ExampleEvent({required this.exampleProperty})
      : super('example_log_event');

  final String exampleProperty;

  @override
  Map<String, Object>? get properties => {'example_property': exampleProperty};

  @override
  List<EventProvider> get providers => [
        const EventProvider(ExampleAnalyticsProviderKey()),
        EventProvider(
          const ExampleAnalyticsProviderKey(name: 'Another Provider'),
          options: EventOptions(
            overrides: EventOverrides(
              name: 'example_log_event_overridden',
              properties: {
                'example_property_overridden': exampleProperty,
              },
            ),
          ),
        ),
      ];
}

class ExampleAnalyticsProvider extends AnalytycsProvider {
  ExampleAnalyticsProvider({String? name})
      : super(identifier: ExampleAnalyticsProviderKey(name: name));

  @override
  ExampleEventResolver get resolver => const ExampleEventResolver();

  @override
  Future<void> initialize() async {
    print('ExampleAnalyticsProvider initialized');
  }

  @override
  Future<void> setSession(Session? session) async {
    print('ExampleAnalyticsProvider set session: $session');
  }
}

class ExampleAnalyticsProviderKey extends ProviderIdentifier {
  const ExampleAnalyticsProviderKey({super.name});
}

class ExampleEventResolver implements EventResolver {
  const ExampleEventResolver();

  @override
  Future<void> resolveEvent(Event event) async {
    print('ExampleEventResolver resolved log event: $event');
  }
}
