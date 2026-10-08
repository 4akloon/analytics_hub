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

/// A stage dropped the event before the resolver.
final class DispatchDropped extends DispatchOutcome {
  /// Creates a dropped outcome caused by [stage].
  const DispatchDropped({required this.stage});

  /// Name of the stage that returned `InterceptorResult.drop`.
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
}
