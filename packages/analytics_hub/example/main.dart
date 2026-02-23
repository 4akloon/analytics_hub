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

  await hub.sendEvent(const ExampleLogEvent(exampleProperty: 'example_value'));
}

class ExampleLogEvent extends LogEvent {
  const ExampleLogEvent({required this.exampleProperty})
      : super('example_log_event');

  final String exampleProperty;

  @override
  Map<String, Object>? get properties => {'example_property': exampleProperty};

  @override
  List<EventProvider<LogEventResolver, LogEventOptions>> get providers => [
        const EventProvider(ExampleAnalyticsProviderKey()),
        EventProvider(
          const ExampleAnalyticsProviderKey(name: 'Another Provider'),
          options: LogEventOptions(
            overrides: LogEventOverrides(
              name: 'example_log_event_overridden',
              properties: {
                'example_property_overridden': exampleProperty,
              },
            ),
          ),
        ),
      ];
}

sealed class ExampleCustomLogEvent
    extends CustomLogEvent<ExampleCustomLogEvent> {
  const ExampleCustomLogEvent();
}

abstract class FirstExampleCustomLogEvent extends ExampleCustomLogEvent {
  const FirstExampleCustomLogEvent({required this.exampleProperty});

  final String exampleProperty;
}

abstract class FirstExampleCustomLogEventImpl
    extends FirstExampleCustomLogEvent {
  const FirstExampleCustomLogEventImpl({required super.exampleProperty});

  @override
  List<
      EventProvider<CustomLogEventResolver<ExampleCustomLogEvent>,
          CustomLogEventOptions<ExampleCustomLogEvent>>> get providers => [
        const EventProvider(ExampleAnalyticsProviderKey()),
      ];
}

class ExampleAnalyticsProvider extends AnalytycsProvider<ExampleEventResolver> {
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

class ExampleAnalyticsProviderKey
    extends ProviderIdentifier<ExampleEventResolver> {
  const ExampleAnalyticsProviderKey({super.name});
}

class ExampleEventResolver
    implements
        EventResolver,
        LogEventResolver,
        CustomLogEventResolver<ExampleCustomLogEvent> {
  const ExampleEventResolver();

  @override
  Future<void> resolveLogEvent(LogEvent event) async {
    print('ExampleEventResolver resolved log event: $event');
  }

  @override
  Future<void> resolveCustomLogEvent(
    CustomLogEvent<ExampleCustomLogEvent> event,
  ) async {
    print('ExampleEventResolver resolved custom log event: $event');
  }
}
