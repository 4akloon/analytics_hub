import '../../provider/provider_identifier.dart';
import '../interception/context/context_record.dart';
import '../interception/context/resolved_event.dart';
import 'dispatch_trace.dart';
import 'properties_diff.dart';
import 'stage_record.dart';

/// Collects [StageRecord]s for one dispatch and builds its [DispatchTrace].
///
/// Internal to the pipeline; one instance per event/provider dispatch, and
/// only when the hub has at least one `TraceSink`.
final class DispatchRecorder {
  /// Starts recording a dispatch.
  DispatchRecorder({
    required this.correlationId,
    required this.eventName,
    required this.provider,
  })  : startedAt = DateTime.now(),
        _clock = Stopwatch()..start();

  /// See [DispatchTrace.correlationId].
  final String correlationId;

  /// See [DispatchTrace.eventName].
  final String eventName;

  /// See [DispatchTrace.provider].
  final ProviderIdentifier provider;

  /// See [DispatchTrace.startedAt].
  final DateTime startedAt;

  final Stopwatch _clock;
  final List<StageRecord> _stages = [];

  /// Elapsed time since the dispatch started.
  Duration get elapsed => _clock.elapsed;

  /// Records a stage that only appended context records.
  void addContextStage({
    required String name,
    required StageKind kind,
    required List<ContextRecord> added,
  }) {
    _stages.add(
      StageRecord(
        name: name,
        kind: kind,
        duration: Duration.zero,
        contextAdded: List.unmodifiable(added),
      ),
    );
  }

  /// Records a stage that transformed [before] into [after].
  ///
  /// [dropped] marks a stage that stopped the pipeline; [error] one that
  /// threw. Context added is derived from the records [after] has beyond
  /// [before].
  void addTransform({
    required String name,
    required StageKind kind,
    required ResolvedEvent before,
    required ResolvedEvent after,
    required Duration duration,
    bool dropped = false,
    Object? error,
  }) {
    final renamed = before.name != after.name;
    final beforeRecords = before.context.records;
    final afterRecords = after.context.records;
    _stages.add(
      StageRecord(
        name: name,
        kind: kind,
        duration: duration,
        nameBefore: renamed ? before.name : null,
        nameAfter: renamed ? after.name : null,
        properties: PropertiesDiff.between(before.properties, after.properties),
        contextAdded: afterRecords.length > beforeRecords.length
            ? List.unmodifiable(afterRecords.sublist(beforeRecords.length))
            : const [],
        dropped: dropped,
        error: error,
      ),
    );
  }

  /// Builds the trace. [error] is an exception not attributed to any stage.
  DispatchTrace finish({Object? error}) {
    _clock.stop();
    return DispatchTrace(
      correlationId: correlationId,
      eventName: eventName,
      provider: provider,
      startedAt: startedAt,
      total: _clock.elapsed,
      stages: List.unmodifiable(_stages),
      outcome: _outcome(error),
    );
  }

  DispatchOutcome _outcome(Object? fallbackError) {
    for (final stage in _stages.reversed) {
      if (stage.error case final error?) {
        return DispatchFailed(stage: stage.name, error: error);
      }
      if (stage.dropped) return DispatchDropped(stage: stage.name);
    }
    if (fallbackError != null) {
      return DispatchFailed(
        stage: _stages.isEmpty ? 'dispatch' : _stages.last.name,
        error: fallbackError,
      );
    }
    return const DispatchSent();
  }
}
