import 'package:analytics_hub/analytics_hub.dart';
import 'package:test/test.dart';

// Concrete implementation for testing ProviderKey
class TestProviderKey extends ProviderIdentifier<LogEventResolver> {
  const TestProviderKey({super.name});
}

void main() {
  group('ProviderKey', () {
    test('creates with name', () {
      const key = TestProviderKey(name: 'test');
      expect(key.name, equals('test'));
    });

    test('creates with null name', () {
      const key = TestProviderKey();
      expect(key.name, isNull);
    });

    test('equality returns true for same name', () {
      const a = TestProviderKey(name: 'test');
      const b = TestProviderKey(name: 'test');
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('equality returns false for different name', () {
      const a = TestProviderKey(name: 'test1');
      const b = TestProviderKey(name: 'test2');
      expect(a, isNot(equals(b)));
    });

    test('equality with null names', () {
      const a = TestProviderKey();
      const b = TestProviderKey();
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('equality returns true for same name with different instances', () {
      const a = TestProviderKey(name: 'test');
      const b = TestProviderKey(name: 'test');
      expect(a, equals(b));
    });

    test('toString returns correct format', () {
      const key = TestProviderKey(name: 'test');
      expect(
        key.toString(),
        contains('test'),
      );
    });
  });
}
