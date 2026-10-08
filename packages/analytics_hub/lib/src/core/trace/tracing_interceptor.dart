import 'dart:async';

import '../interception/context/event_dispatch_context.dart';
import '../interception/context/resolved_event.dart';
import '../interception/interceptor/event_interceptor.dart';
import '../interception/interceptor/interceptor_result.dart';
import 'dispatch_recorder.dart';
import 'stage_record.dart';

/// Wraps an [EventInterceptor] and records what it did.
///
/// The stage is measured from entry until the interceptor calls `next`, and
/// the diff is between what it received and what it forwarded. A result
/// returned without calling `next` is recorded as a drop (or as whatever the
/// interceptor returned). An exception the interceptor throws, before or after
/// `next`, is recorded as its own error stage; one thrown downstream of `next`
/// is left to the stage that threw it. Changes made to the result *after*
/// `next` returned are not attributed.
final class TracingInterceptor implements EventInterceptor {
  /// Wraps [inner] as a stage of [kind] reporting to [recorder].
  const TracingInterceptor(
    this.inner, {
    required this.kind,
    required this.recorder,
  });

  /// The interceptor being traced.
  final EventInterceptor inner;

  /// Stage kind written to every record.
  final StageKind kind;

  /// Where the stage record goes.
  final DispatchRecorder recorder;

  @override
  String get name => inner.name;

  String get _stageName => 'interceptor:${inner.name}';

  @override
  FutureOr<InterceptorResult> intercept({
    required ResolvedEvent event,
    required EventDispatchContext context,
    required NextEventInterceptor next,
  }) async {
    final clock = Stopwatch()..start();
    var forwarded = false;
    var downstreamError = false;
    try {
      final result = await inner.intercept(
        event: event,
        context: context,
        next: (nextEvent, nextContext) async {
          forwarded = true;
          recorder.addTransform(
            name: _stageName,
            kind: kind,
            before: event,
            after: nextEvent,
            duration: clock.elapsed,
          );
          try {
            return await next(nextEvent, nextContext);
          } catch (_) {
            downstreamError = true;
            rethrow;
          }
        },
      );
      if (!forwarded) {
        recorder.addTransform(
          name: _stageName,
          kind: kind,
          before: event,
          after: result.event,
          duration: clock.elapsed,
          dropped: result.isDropped,
        );
      }
      return result;
    } catch (error) {
      if (!forwarded || !downstreamError) {
        recorder.addTransform(
          name: _stageName,
          kind: kind,
          before: event,
          after: event,
          duration: clock.elapsed,
          error: error,
        );
      }
      rethrow;
    }
  }
}
