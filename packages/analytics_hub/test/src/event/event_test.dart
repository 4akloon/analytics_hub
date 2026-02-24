import 'package:analytics_hub/analytics_hub.dart';
import 'package:test/test.dart';

class TestProviderKey extends ProviderIdentifier {
  const TestProviderKey({super.name});
}

class TestEvent extends Event {
  const TestEvent(super.name, {this.props});

  final Map<String, Object>? props;

  @override
  Map<String, Object>? get properties => props;

  @override
  List<EventProvider> get providers => [
        const EventProvider(TestProviderKey(name: 'test')),
        const EventProvider(
          TestProviderKey(name: 'test'),
          options: EventOptions(
            overrides: EventOverrides(
              name: 'test_overridden',
            ),
          ),
        ),
      ];
}

void main() {
  group('Event', () {
    test('creates with name only', () {
      const event = TestEvent('event_name');
      expect(event.name, equals('event_name'));
      expect(event.properties, isNull);
    });

    test('creates with name and properties', () {
      const event = TestEvent('event_name', props: {'key': 'value'});
      expect(event.name, equals('event_name'));
      expect(event.properties, equals({'key': 'value'}));
    });

    test('toString contains name', () {
      const event = TestEvent('event_name');
      expect(event.toString(), contains('event_name'));
    });
  });
}
