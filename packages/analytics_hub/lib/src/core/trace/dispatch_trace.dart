import '../../provider/provider_identifier.dart';
import 'stage_record.dart';

/// How a dispatch ended.
sealed class DispatchOutcome {
  const DispatchOutcome();
}

/// The resolver accepted the event.
final class DispatchSent extends DispatchOutcome {
  /// Creates a sent outcome.
  const DispatchSent();
}

/// A stage dropped the event before the resolver, or ended the pipeline
/// without reaching it (an interceptor that returned without calling `next`).
final class DispatchDropped extends DispatchOutcome {
  /// Creates a dropped outcome caused by [stage].
  const DispatchDropped({required this.stage});

  /// Name of the stage that returned `InterceptorResult.drop`, or the last
  /// stage recorded when the pipeline ended before the resolver.
  final String stage;
}

/// A stage threw.
final class DispatchFailed extends DispatchOutcome {
  /// Creates a failed outcome caused by [stage].
  const DispatchFailed({required this.stage, required this.error});

  /// Name of the stage that threw.
  final String stage;

  /// What it threw.
  final Object error;
}

/// The full story of one event reaching one provider.
final class DispatchTrace {
  /// Creates a trace.
  const DispatchTrace({
    required this.correlationId,
    required this.eventName,
    required this.provider,
    required this.startedAt,
    required this.total,
    required this.stages,
    required this.outcome,
    required this.resolvedName,
    this.resolvedProperties,
  });

  /// Id shared by every provider dispatch of the same `sendEvent` call.
  final String correlationId;

  /// The event name as passed to `sendEvent`, before any override.
  final String eventName;

  /// The provider this dispatch targeted.
  final ProviderIdentifier provider;

  /// When the dispatch started.
  final DateTime startedAt;

  /// Wall time from start to outcome.
  final Duration total;

  /// Stages in execution order.
  final List<StageRecord> stages;

  /// How the dispatch ended.
  final DispatchOutcome outcome;

  /// The event name as the resolver received it (after overrides and
  /// interceptors), or as it stood when the dispatch dropped or failed.
  final String resolvedName;

  /// The event properties as the resolver received them, or as they stood
  /// when the dispatch dropped or failed.
  final Map<String, Object?>? resolvedProperties;
}
