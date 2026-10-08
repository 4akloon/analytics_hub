import '../../../scope/analytics_scope.dart';
import '../../trace/dispatch_recorder.dart';
import '../../trace/stage_record.dart';
import '../../trace/tracing_interceptor.dart';
import '../context/event_context.dart';
import '../context/resolved_event.dart';
import '../interceptor/event_interceptor.dart';
import '../interceptor/interceptor_result.dart';
import 'context_builder.dart';
import 'dispatch_target.dart';
import 'event_snapshot.dart';
import 'interceptor_chain_executor.dart';
import 'overrides_applier.dart';

/// Dispatches one event to one provider through the interception pipeline.
///
/// Stage order: scope interceptors (root → leaf) → provider overrides →
/// hub interceptors → provider interceptors → resolver.
class EventDispatcher {
  /// Creates dispatcher with hub interceptors and pipeline collaborators.
  EventDispatcher({
    required List<EventInterceptor> hubInterceptors,
    required EventDispatchContextBuilder contextBuilder,
    EventOverridesApplier overridesApplier = const EventOverridesApplier(),
    InterceptorChainExecutor chainExecutor = const InterceptorChainExecutor(),
  })  : _hubInterceptors = List<EventInterceptor>.unmodifiable(hubInterceptors),
        _contextBuilder = contextBuilder,
        _overridesApplier = overridesApplier,
        _chainExecutor = chainExecutor;

  final List<EventInterceptor> _hubInterceptors;
  final EventDispatchContextBuilder _contextBuilder;
  final EventOverridesApplier _overridesApplier;
  final InterceptorChainExecutor _chainExecutor;

  /// Dispatches [snapshot] to [target].
  ///
  /// [scopes] is the scope chain root → leaf; its context precedes the
  /// event's own and its interceptors run first. With [recorder], every stage
  /// is wrapped and reported to it.
  Future<InterceptorResult> dispatch({
    required EventSnapshot snapshot,
    required DispatchTarget target,
    required String correlationId,
    List<AnalyticsScope> scopes = const [],
    DispatchRecorder? recorder,
  }) {
    var context = const EventContext();
    for (final scope in scopes) {
      context = context.append(scope.context);
      recorder?.addContextStage(
        name: scope.source,
        kind: StageKind.scope,
        added: scope.context.records,
      );
    }
    context = context.append(snapshot.context);

    final dispatchContext = _contextBuilder.build(
      originalEvent: snapshot.event,
      target: target,
      context: context,
      correlationId: correlationId,
    );
    final initialEvent = ResolvedEvent(
      name: snapshot.name,
      properties: snapshot.properties,
      context: context,
    );
    final scopeInterceptors = [
      for (final scope in scopes)
        for (final interceptor in scope.interceptors)
          _traced(interceptor, StageKind.scopeInterceptor, recorder),
    ];
    final hubAndProviderInterceptors = [
      for (final interceptor in _hubInterceptors)
        _traced(interceptor, StageKind.hubInterceptor, recorder),
      for (final interceptor in target.provider.interceptors)
        _traced(interceptor, StageKind.providerInterceptor, recorder),
    ];

    return _chainExecutor.execute(
      interceptors: scopeInterceptors,
      event: initialEvent,
      context: dispatchContext,
      terminal: (event, context) {
        final clock = _startClock(recorder);
        final overriddenEvent = _overridesApplier.apply(
          event,
          target.eventProvider.overrides,
        );
        recorder?.addTransform(
          name: 'overrides',
          kind: StageKind.overrides,
          before: event,
          after: overriddenEvent,
          duration: clock?.elapsed ?? Duration.zero,
        );
        return _chainExecutor.execute(
          interceptors: hubAndProviderInterceptors,
          event: overriddenEvent,
          context: context,
          terminal: (event, context) async {
            final clock = _startClock(recorder);
            try {
              await target.provider.resolver.resolve(event, context: context);
            } catch (error) {
              recorder?.addTransform(
                name: _resolverStage(target),
                kind: StageKind.resolver,
                before: event,
                after: event,
                duration: clock?.elapsed ?? Duration.zero,
                error: error,
              );
              rethrow;
            }
            recorder?.addTransform(
              name: _resolverStage(target),
              kind: StageKind.resolver,
              before: event,
              after: event,
              duration: clock?.elapsed ?? Duration.zero,
            );
            return InterceptorResult.continueWith(event, context: context);
          },
        );
      },
    );
  }

  static Stopwatch? _startClock(DispatchRecorder? recorder) =>
      recorder == null ? null : (Stopwatch()..start());

  static String _resolverStage(DispatchTarget target) =>
      'resolver:${target.provider.identifier.name}';

  static EventInterceptor _traced(
    EventInterceptor interceptor,
    StageKind kind,
    DispatchRecorder? recorder,
  ) =>
      recorder == null
          ? interceptor
          : TracingInterceptor(interceptor, kind: kind, recorder: recorder);
}
