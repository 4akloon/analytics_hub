import 'dart:async';

import '../context/event_dispatch_context.dart';
import '../context/resolved_event.dart';
import 'interceptor_result.dart';

/// Continuation callback for interceptor chain.
typedef NextEventInterceptor = FutureOr<InterceptorResult> Function(
  ResolvedEvent event,
  EventDispatchContext context,
);

/// Intercepts an event before it is resolved by a provider.
abstract interface class EventInterceptor {
  /// Intercepts [event] and either continues via [next] or short-circuits.
  FutureOr<InterceptorResult> intercept({
    required ResolvedEvent event,
    required EventDispatchContext context,
    required NextEventInterceptor next,
  });
}
