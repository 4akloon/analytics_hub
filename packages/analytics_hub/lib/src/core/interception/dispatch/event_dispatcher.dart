import '../../../scope/analytics_scope.dart';
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
  /// event's own and its interceptors run first.
  Future<InterceptorResult> dispatch({
    required EventSnapshot snapshot,
    required DispatchTarget target,
    required String correlationId,
    List<AnalyticsScope> scopes = const [],
  }) {
    var context = const EventContext();
    for (final scope in scopes) {
      context = context.append(scope.context);
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
      for (final scope in scopes) ...scope.interceptors,
    ];
    final hubAndProviderInterceptors = [
      ..._hubInterceptors,
      ...target.provider.interceptors,
    ];

    return _chainExecutor.execute(
      interceptors: scopeInterceptors,
      event: initialEvent,
      context: dispatchContext,
      terminal: (event, context) {
        final overriddenEvent = _overridesApplier.apply(
          event,
          target.eventProvider.overrides,
        );
        return _chainExecutor.execute(
          interceptors: hubAndProviderInterceptors,
          event: overriddenEvent,
          context: context,
          terminal: (event, context) async {
            await target.provider.resolver.resolve(event, context: context);
            return InterceptorResult.continueWith(event, context: context);
          },
        );
      },
    );
  }
}
