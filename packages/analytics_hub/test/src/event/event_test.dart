import 'package:analytics_hub/analytics_hub.dart';
import 'package:test/test.dart';

// Concrete LogEvent implementation for testing
class TestProviderKey extends ProviderKey<LogEventResolver> {
  const TestProviderKey({super.name});
}

class TestLogEvent extends LogEvent {
  const TestLogEvent(super.name, {this.props});

  final Map<String, Object>? props;

  @override
  Map<String, Object>? get properties => props;

  @override
  Set<ProviderKey<LogEventResolver>> get providerKeys =>
      {const TestProviderKey(name: 'test')};
}

void main() {
  group('LogEvent', () {
    test('creates with name only', () {
      const event = TestLogEvent('event_name');
      expect(event.name, equals('event_name'));
      expect(event.properties, isNull);
    });

    test('creates with name and properties', () {
      const event = TestLogEvent('event_name', props: {'key': 'value'});
      expect(event.name, equals('event_name'));
      expect(event.properties, equals({'key': 'value'}));
    });

    test('toString contains name', () {
      const event = TestLogEvent('event_name');
      expect(event.toString(), contains('event_name'));
    });
  });
}
