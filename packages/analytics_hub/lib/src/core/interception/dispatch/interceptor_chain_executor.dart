import 'package:logging/logging.dart';

import '../context/event_dispatch_context.dart';
import '../context/resolved_event.dart';
import '../interceptor/event_interceptor.dart';
import '../interceptor/interceptor_result.dart';

/// Final pipeline callback executed after all interceptors.
typedef TerminalDispatch = Future<InterceptorResult> Function(
  ResolvedEvent event,
  EventDispatchContext context,
);

/// Executes interceptor chain and then delegates to terminal dispatch.
class InterceptorChainExecutor {
  /// Creates interceptor chain executor.
  const InterceptorChainExecutor();

  static final _logger = Logger('AnalyticsHub.InterceptorChainExecutor');

  /// Executes [interceptors] and then [terminal] with the final payload/context.
  Future<InterceptorResult> execute({
    required List<EventInterceptor> interceptors,
    required ResolvedEvent event,
    required EventDispatchContext context,
    required TerminalDispatch terminal,
  }) {
    _logger.fine('Executing interceptor chain: $interceptors');
    Future<InterceptorResult> runAt(
      int index, {
      required ResolvedEvent event,
      required EventDispatchContext context,
    }) async {
      if (index >= interceptors.length) {
        _logger.fine('Executing terminal dispatch: $terminal');
        return terminal(event, context);
      }

      final interceptor = interceptors[index];
      _logger.fine('Executing interceptor: $interceptor');
      return interceptor.intercept(
        event: event,
        context: context,
        next: (event, context) {
          return runAt(index + 1, event: event, context: context);
        },
      );
    }

    return runAt(0, event: event, context: context);
  }
}
