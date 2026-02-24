import 'package:analytics_hub/src/event/events/events.dart';
import 'package:logging/logging.dart';

import '../context/resolved_event.dart';
import '../interceptor/event_interceptor.dart';
import '../interceptor/interceptor_result.dart';
import 'context_builder.dart';
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
    InterceptorChainExecutor chainExecutor = const InterceptorChainExecutor(),
  })  : _hubInterceptors = List<EventInterceptor>.unmodifiable(hubInterceptors),
        _contextBuilder = contextBuilder,
        _overridesApplier = overridesApplier,
        _chainExecutor = chainExecutor;

  final List<EventInterceptor> _hubInterceptors;
  final EventDispatchContextBuilder _contextBuilder;
  final EventOverridesApplier _overridesApplier;
  final InterceptorChainExecutor _chainExecutor;

  static final _logger = Logger('AnalyticsHub.EventDispatcher');

  /// Dispatches one [event] to one [target] through overrides/interceptors/resolver.
  Future<InterceptorResult> dispatch({
    required Event event,
    required DispatchTarget target,
  }) async {
    _logger.info(
      'Dispatching event: $event to target: ${target.provider.identifier}',
    );

    final context = _contextBuilder.build(
      originalEvent: event,
      target: target,
    );
    final initialEvent = _overridesApplier.apply(
      ResolvedEvent(
        name: event.name,
        properties: event.properties,
        context: event.context,
      ),
      target.eventProvider.options,
    );
    final interceptors = [
      ..._hubInterceptors,
      ...target.provider.interceptors,
    ];

    final result = await _chainExecutor.execute(
      interceptors: interceptors,
      event: initialEvent,
      context: context,
      terminal: (event, context) async {
        await target.provider.resolver.resolve(event, context: context);
        return InterceptorResult.continueWith(event, context: context);
      },
    );

    _logger.info('Dispatch completed: $result');

    return result;
  }
}
