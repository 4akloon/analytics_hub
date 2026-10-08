import 'package:analytics_hub/analytics_hub.dart';
import 'package:test/test.dart';

sealed class _Surface extends ContextEntry {
  const _Surface(this.name);

  final String name;
}

final class _Page extends _Surface {
  const _Page(super.name);
}

final class _Element extends _Surface {
  const _Element(super.name);
}

final class _Other extends ContextEntry {
  const _Other();
}

void main() {
  group('EventContext', () {
    test('starts empty', () {
      const context = EventContext();
      expect(context.isEmpty, isTrue);
      expect(context.isNotEmpty, isFalse);
      expect(context.records, isEmpty);
      expect(context.entry<_Page>(), isNull);
    });

    test('withEntry appends a record attributed to the event by default', () {
      final context = const EventContext().withEntry(const _Page('home'));

      expect(context.records, hasLength(1));
      expect(context.records.single.entry, equals(const _Page('home')));
      expect(context.records.single.source, equals(EventContext.eventSource));
    });

    test('entry returns the nearest entry of a type', () {
      final context = const EventContext()
          .withEntry(const _Page('home'), source: 'scope:home')
          .withEntry(const _Page('builder'), source: 'scope:builder');

      expect(context.entry<_Page>()?.name, equals('builder'));
      expect(context.records, hasLength(2));
    });

    test('entry matches sealed subtypes through the base type', () {
      final context = const EventContext()
          .withEntry(const _Page('home'))
          .withEntry(const _Element('create'));

      expect(context.entry<_Surface>()?.name, equals('create'));
      expect(context.entry<_Page>()?.name, equals('home'));
      expect(context.entry<_Other>(), isNull);
    });

    test('entries lists every entry of a type root to leaf', () {
      final context = const EventContext()
          .withEntry(const _Page('home'))
          .withEntry(const _Element('create'))
          .withEntry(const _Page('builder'));

      expect(
        context.entries<_Page>().map((e) => e.name),
        equals(['home', 'builder']),
      );
      expect(context.all, hasLength(3));
    });

    test('append concatenates records and never merges', () {
      final outer = const EventContext().withEntry(
        const _Page('home'),
        source: 'scope:home',
      );
      final inner = const EventContext().withEntry(const _Page('builder'));

      final merged = outer.append(inner);

      expect(
        merged.records.map((r) => r.source),
        equals(['scope:home', 'event']),
      );
      expect(merged.entry<_Page>()?.name, equals('builder'));
      expect(outer.records, hasLength(1), reason: 'append returns a new value');
    });

    test('append of an empty context returns the receiver', () {
      final outer = const EventContext().withEntry(const _Page('home'));

      expect(identical(outer.append(const EventContext()), outer), isTrue);
    });

    test('withEntries attributes every entry to one source', () {
      final context = const EventContext().withEntries(
        const [_Page('home'), _Element('create')],
        source: 'scope:home',
      );

      expect(context.records.map((r) => r.source), everyElement('scope:home'));
    });

    test('attributedTo re-sources every record', () {
      final context = const EventContext()
          .withEntry(const _Page('home'))
          .attributedTo('scope:home');

      expect(context.records.single.source, equals('scope:home'));
    });

    test('records is unmodifiable', () {
      final context = const EventContext().withEntry(const _Page('home'));

      expect(
        () => context.records.add(
          const ContextRecord(entry: _Other(), source: 'x'),
        ),
        throwsUnsupportedError,
      );
    });
  });

  group('ContextRecord', () {
    test('equality is by entry and source', () {
      expect(
        const ContextRecord(entry: _Page('home'), source: 'event'),
        equals(const ContextRecord(entry: _Page('home'), source: 'event')),
      );
      expect(
        const ContextRecord(entry: _Page('home'), source: 'event'),
        isNot(
          equals(
            const ContextRecord(entry: _Page('home'), source: 'scope:x'),
          ),
        ),
      );
    });

    test('toString names the source and entry', () {
      expect(
        const ContextRecord(entry: _Other(), source: 'scope:home').toString(),
        equals('scope:home: Instance of \'_Other\''),
      );
    });
  });
}
