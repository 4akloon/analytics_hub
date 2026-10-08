import 'package:analytics_hub/analytics_hub.dart';
import 'package:test/test.dart';

void main() {
  group('PropertiesDiff.between', () {
    test('reports added, changed and removed keys', () {
      final diff = PropertiesDiff.between(
        {'a': 1, 'b': 'x', 'c': true},
        {'a': 1, 'b': 'y', 'd': null},
      );

      expect(diff.added, equals({'d': null}));
      expect(
        diff.changed,
        equals({'b': const PropertyChange(from: 'x', to: 'y')}),
      );
      expect(diff.removed, equals({'c': true}));
      expect(diff.isNotEmpty, isTrue);
    });

    test('is empty for equal maps and for null to null', () {
      expect(PropertiesDiff.between({'a': 1}, {'a': 1}).isEmpty, isTrue);
      expect(PropertiesDiff.between(null, null).isEmpty, isTrue);
    });

    test('treats null as an empty map', () {
      expect(PropertiesDiff.between(null, {'a': 1}).added, equals({'a': 1}));
      expect(PropertiesDiff.between({'a': 1}, null).removed, equals({'a': 1}));
    });
  });

  group('StageRecord', () {
    test('nameChanged only when both names are set and differ', () {
      const unchanged = StageRecord(
        name: 'overrides',
        kind: StageKind.overrides,
        duration: Duration.zero,
      );
      const changed = StageRecord(
        name: 'overrides',
        kind: StageKind.overrides,
        duration: Duration.zero,
        nameBefore: 'a',
        nameAfter: 'b',
      );

      expect(unchanged.nameChanged, isFalse);
      expect(changed.nameChanged, isTrue);
    });
  });
}
