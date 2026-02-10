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
  group('SelectPromotionECommerceEventData', () {
    test('creates with all optional fields', () {
      const data = SelectPromotionECommerceEventData(
        creativeName: 'name',
        creativeSlot: 'slot',
        locationId: 'loc',
        promotionId: 'promo',
        promotionName: 'promoName',
        parameters: {'key': 'value'},
      );
      expect(data.creativeName, equals('name'));
      expect(data.creativeSlot, equals('slot'));
      expect(data.locationId, equals('loc'));
      expect(data.promotionId, equals('promo'));
      expect(data.promotionName, equals('promoName'));
      expect(data.parameters, equals({'key': 'value'}));
    });

    test('creates with minimal fields', () {
      const data = SelectPromotionECommerceEventData();
      expect(data.creativeName, isNull);
      expect(data.creativeSlot, isNull);
      expect(data.locationId, isNull);
      expect(data.promotionId, isNull);
      expect(data.promotionName, isNull);
      expect(data.parameters, isNull);
    });
  });

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
