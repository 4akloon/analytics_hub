import 'package:analytics_hub/analytics_hub.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

class _Key extends ProviderIdentifier {
  const _Key() : super(name: 'mixpanel');
}

final class _Page extends ContextEntry {
  const _Page(this.name);

  final String name;

  @override
  String toString() => 'Page($name)';
}

DispatchTrace _trace({DispatchOutcome outcome = const DispatchSent()}) =>
    DispatchTrace(
      correlationId: 'event-1',
      eventName: 'click_create',
      resolvedName: 'click_create',
      provider: const _Key(),
      startedAt: DateTime(2026, 10, 8),
      total: const Duration(milliseconds: 3),
      stages: const [
        StageRecord(
          name: 'scope:home',
          kind: StageKind.scope,
          duration: Duration.zero,
          contextAdded: [
            ContextRecord(entry: _Page('home'), source: 'scope:home'),
          ],
        ),
        StageRecord(
          name: 'interceptor:source',
          kind: StageKind.scopeInterceptor,
          duration: Duration(microseconds: 120),
          properties: PropertiesDiff(added: {'source_page': 'home'}),
        ),
        StageRecord(
          name: 'overrides',
          kind: StageKind.overrides,
          duration: Duration.zero,
          nameBefore: 'click_create',
          nameAfter: 'Click Create',
        ),
        StageRecord(
          name: 'interceptor:legacy',
          kind: StageKind.hubInterceptor,
          duration: Duration.zero,
        ),
        StageRecord(
          name: 'resolver:mixpanel',
          kind: StageKind.resolver,
          duration: Duration(milliseconds: 2),
        ),
      ],
      outcome: outcome,
    );

void main() {
  const formatter = DispatchTraceFormatter();

  group('DispatchTraceFormatter', () {
    test('compact is one line with the outcome', () {
      expect(
        formatter.compact(_trace()),
        equals('click_create → mixpanel  sent  3ms  5 stages  corr=event-1'),
      );
      expect(
        formatter.compact(
          _trace(outcome: const DispatchDropped(stage: 'interceptor:drop')),
        ),
        contains('dropped by interceptor:drop'),
      );
      expect(
        formatter.compact(
          _trace(
            outcome: DispatchFailed(
              stage: 'resolver:mixpanel',
              error: StateError('down'),
            ),
          ),
        ),
        contains('failed at resolver:mixpanel'),
      );
    });

    test('verbose lists every stage with what it changed', () {
      final text = formatter.verbose(_trace());

      expect(
        text.split('\n'),
        equals([
          'click_create → mixpanel  sent  3ms  5 stages  corr=event-1',
          '  scope:home            +ctx scope:home: Page(home)',
          '  interceptor:source    +source_page=home',
          '  overrides             click_create → Click Create',
          '  interceptor:legacy    —',
          '  resolver:mixpanel     ok',
        ]),
      );
    });
  });

  group('LoggingTraceSink', () {
    test('logs the compact line at fine', () {
      final logger = Logger.detached('test');
      final records = <LogRecord>[];
      logger.level = Level.ALL;
      logger.onRecord.listen(records.add);

      LoggingTraceSink(logger: logger).onTrace(_trace());

      expect(records.single.level, equals(Level.FINE));
      expect(records.single.message, startsWith('click_create → mixpanel'));
      expect(records.single.message, isNot(contains('\n')));
    });

    test('verbose logs the stage list', () {
      final logger = Logger.detached('test');
      final records = <LogRecord>[];
      logger.level = Level.ALL;
      logger.onRecord.listen(records.add);

      LoggingTraceSink(verbose: true, logger: logger).onTrace(_trace());

      expect(records.single.message, contains('\n  scope:home'));
    });
  });
}
