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
  Set<ProviderKey<LogEventResolver>> get providerKeys => {
        const ExampleAnalyticsProviderKey(),
        const ExampleAnalyticsProviderKey(name: 'example_value'),
      };
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
  Set<ProviderKey<CustomLogEventResolver<ExampleCustomLogEvent>>>
      get providerKeys => {const ExampleAnalyticsProviderKey()};
}

class ExampleAnalyticsProvider extends AnalytycsProvider<ExampleEventResolver> {
  ExampleAnalyticsProvider({String? name})
      : super(key: ExampleAnalyticsProviderKey(name: name));

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

class ExampleAnalyticsProviderKey extends ProviderKey<ExampleEventResolver> {
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
