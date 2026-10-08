import '../interception/context/context_record.dart';
import 'properties_diff.dart';

/// Which part of the pipeline a [StageRecord] describes.
enum StageKind {
  /// A scope contributing its context records.
  scope,

  /// An interceptor owned by a scope.
  scopeInterceptor,

  /// Provider-specific `EventOverrides`.
  overrides,

  /// An interceptor registered on the hub.
  hubInterceptor,

  /// An interceptor registered on the provider.
  providerInterceptor,

  /// The provider's resolver.
  resolver,
}

/// What one pipeline stage did during a dispatch.
final class StageRecord {
  /// Creates a record of one stage.
  const StageRecord({
    required this.name,
    required this.kind,
    required this.duration,
    this.nameBefore,
    this.nameAfter,
    this.properties = const PropertiesDiff(),
    this.contextAdded = const [],
    this.dropped = false,
    this.error,
  });

  /// Stage name: `'scope:<name>'`, `'interceptor:<name>'`, `'overrides'`
  /// or `'resolver:<provider>'`.
  final String name;

  /// What kind of stage this was.
  final StageKind kind;

  /// Time the stage spent before handing the event on (or dropping it).
  final Duration duration;

  /// Event name before the stage, set only when the stage renamed it.
  final String? nameBefore;

  /// Event name after the stage, set only when the stage renamed it.
  final String? nameAfter;

  /// Property changes made by the stage.
  final PropertiesDiff properties;

  /// Context records the stage appended.
  final List<ContextRecord> contextAdded;

  /// Whether the stage stopped the pipeline.
  final bool dropped;

  /// The error the stage threw, if any.
  final Object? error;

  /// Whether the stage renamed the event.
  bool get nameChanged =>
      nameBefore != null && nameAfter != null && nameBefore != nameAfter;

  /// Whether the stage changed nothing and let the event through.
  bool get isNoop =>
      !nameChanged &&
      properties.isEmpty &&
      contextAdded.isEmpty &&
      !dropped &&
      error == null;
}
