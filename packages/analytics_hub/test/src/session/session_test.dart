import 'package:analytics_hub/analytics_hub.dart';
import 'package:test/test.dart';

void main() {
  group('Session', () {
    test('creates with id', () {
      const session = Session(id: 'user-123');
      expect(session.id, equals('user-123'));
    });

    test('equality returns true for same id', () {
      const a = Session(id: 'user-123');
      const b = Session(id: 'user-123');
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('equality returns false for different id', () {
      const a = Session(id: 'user-123');
      const b = Session(id: 'user-456');
      expect(a, isNot(equals(b)));
      expect(a.hashCode, isNot(equals(b.hashCode)));
    });

    test('equality returns false for non-Session', () {
      const session = Session(id: 'user-123');
      expect(session, isNot(equals('user-123')));
    });

    test('toString returns correct format', () {
      const session = Session(id: 'user-123');
      expect(session.toString(), equals('Session(id: user-123)'));
    });
  });
}
