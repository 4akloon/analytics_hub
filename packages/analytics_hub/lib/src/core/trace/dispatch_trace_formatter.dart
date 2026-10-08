import 'dispatch_trace.dart';
import 'stage_record.dart';

/// Renders a [DispatchTrace] as text.
///
/// [compact] is one line; [verbose] adds one line per stage showing what it
/// changed. Both are plain text with no ANSI codes, so any sink can reuse
/// them.
final class DispatchTraceFormatter {
  /// Creates a formatter.
  const DispatchTraceFormatter();

  static const int _nameColumn = 22;

  /// One line: event, provider, outcome, duration, stage count, correlation.
  String compact(DispatchTrace trace) {
    final outcome = switch (trace.outcome) {
      DispatchSent() => 'sent',
      DispatchDropped(:final stage) => 'dropped by $stage',
      DispatchFailed(:final stage) => 'failed at $stage',
    };
    return '${trace.eventName} → ${trace.provider.name}  $outcome  '
        '${trace.total.inMilliseconds}ms  ${trace.stages.length} stages  '
        'corr=${trace.correlationId}';
  }

  /// [compact] followed by one indented line per stage.
  String verbose(DispatchTrace trace) {
    final buffer = StringBuffer(compact(trace));
    for (final stage in trace.stages) {
      buffer
        ..write('\n  ')
        ..write(stage.name.padRight(_nameColumn))
        ..write(_describe(stage));
    }
    return buffer.toString();
  }

  String _describe(StageRecord stage) {
    if (stage.error case final error?) return 'error: $error';
    if (stage.dropped) return 'dropped';
    if (stage.kind == StageKind.resolver) return 'ok';
    if (stage.isNoop) return '—';

    final parts = <String>[
      if (stage.nameChanged) '${stage.nameBefore} → ${stage.nameAfter}',
      for (final MapEntry(:key, :value) in stage.properties.added.entries)
        '+$key=$value',
      for (final MapEntry(:key, :value) in stage.properties.changed.entries)
        '~$key=$value',
      for (final key in stage.properties.removed.keys) '-$key',
      for (final record in stage.contextAdded) '+ctx $record',
    ];
    return parts.join(' ');
  }
}
