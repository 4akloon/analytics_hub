import 'package:analytics_hub/analytics_hub.dart';
import 'package:test/test.dart';

void main() {
  group('ResolvedEvent.withDefaults', () {
    test('fills missing keys and keeps explicit values', () {
      const event = ResolvedEvent(
        name: 'click',
        properties: {'source_page': 'builder', 'count': 2},
        context: EventContext(),
      );

      final result = event.withDefaults({
        'source_page': 'home',
        'source_element': 'create',
      });

      expect(
        result.properties,
        equals({
          'source_page': 'builder',
          'count': 2,
          'source_element': 'create',
        }),
      );
    });

    test('treats an explicit null as unset', () {
      const event = ResolvedEvent(
        name: 'click',
        properties: {'source_page': null},
        context: EventContext(),
      );

      final result = event.withDefaults({'source_page': 'home'});

      expect(result.properties, equals({'source_page': 'home'}));
    });

    test('creates properties when the event has none', () {
      const event = ResolvedEvent(name: 'click', context: EventContext());

      expect(
        event.withDefaults({'a': 1}).properties,
        equals({'a': 1}),
      );
    });

    test('returns the receiver for empty defaults', () {
      const event = ResolvedEvent(name: 'click', context: EventContext());

      expect(identical(event.withDefaults(const {}), event), isTrue);
    });
  });
}
