import 'package:analytics_hub/src/event/events/events.dart';

import '../context/event_context.dart';
import '../context/resolved_event.dart';
import '../interceptor/event_interceptor.dart';
import '../interceptor/interceptor_result.dart';
import 'context_builder.dart';
import 'context_properties_applier.dart';
import 'dispatch_target.dart';
import 'interceptor_chain_executor.dart';
import 'overrides_applier.dart';

/// Dispatches one event to one provider through the interception pipeline.
class EventDispatcher {
  /// Creates dispatcher with hub interceptors and pipeline collaborators.
  EventDispatcher({
    required List<EventInterceptor> hubInterceptors,
    required EventDispatchContextBuilder contextBuilder,
    EventOverridesApplier overridesApplier = const EventOverridesApplier(),
    EventContextPropertiesApplier contextPropertiesApplier =
        const EventContextPropertiesApplier(),
    InterceptorChainExecutor chainExecutor = const InterceptorChainExecutor(),
  })  : _hubInterceptors = List<EventInterceptor>.unmodifiable(hubInterceptors),
        _contextBuilder = contextBuilder,
        _overridesApplier = overridesApplier,
        _contextPropertiesApplier = contextPropertiesApplier,
        _chainExecutor = chainExecutor;

  final List<EventInterceptor> _hubInterceptors;
  final EventDispatchContextBuilder _contextBuilder;
  final EventOverridesApplier _overridesApplier;
  final EventContextPropertiesApplier _contextPropertiesApplier;
  final InterceptorChainExecutor _chainExecutor;

  /// Dispatches one [event] to one [target] through overrides/interceptors/resolver.
  ///
  /// [inheritedContext] comes from enclosing scopes; [Event.context] entries
  /// override inherited entries of the same type.
  Future<InterceptorResult> dispatch({
    required Event event,
    required DispatchTarget target,
    EventContext inheritedContext = const EventContext(),
  }) {
    final effectiveContext = inheritedContext.isEmpty
        ? event.context
        : inheritedContext.merge(event.context);
    final context = _contextBuilder.build(
      originalEvent: event,
      target: target,
      context: effectiveContext,
    );
    final overriddenEvent = _overridesApplier.apply(
      ResolvedEvent(
        name: event.name,
        properties: event.properties,
        context: effectiveContext,
      ),
      target.eventProvider.overrides,
    );
    final initialEvent =
        _contextPropertiesApplier.apply(overriddenEvent, context);
    final interceptors = [
      ..._hubInterceptors,
      ...target.provider.interceptors,
    ];

    return _chainExecutor.execute(
      interceptors: interceptors,
      event: initialEvent,
      context: context,
      terminal: (event, context) async {
        await target.provider.resolver.resolve(event, context: context);
        return InterceptorResult.continueWith(event, context: context);
      },
    );
  }
}
