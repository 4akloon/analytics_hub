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

    test('ignores a null default for a missing key', () {
      const event = ResolvedEvent(
        name: 'click',
        properties: {'b': 2},
        context: EventContext(),
      );

      final result = event.withDefaults({'a': null});

      expect(result.properties, equals({'b': 2}));
    });

    test('keeps an explicit value over a null default', () {
      const event = ResolvedEvent(
        name: 'click',
        properties: {'a': 1},
        context: EventContext(),
      );

      expect(event.withDefaults({'a': null}).properties, equals({'a': 1}));
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
