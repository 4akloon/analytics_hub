import 'package:logging/logging.dart';

import 'dispatch_trace.dart';
import 'dispatch_trace_formatter.dart';
import 'trace_sink.dart';

/// A [TraceSink] that logs every trace at [Level.FINE].
///
/// Logs the compact line by default; [verbose] adds the stage list.
final class LoggingTraceSink implements TraceSink {
  /// Creates a sink logging to [logger] (default `AnalyticsHub.trace`).
  LoggingTraceSink({
    this.verbose = false,
    Logger? logger,
    DispatchTraceFormatter formatter = const DispatchTraceFormatter(),
  })  : _logger = logger ?? Logger('AnalyticsHub.trace'),
        _formatter = formatter;

  /// Whether to log one line per stage after the summary line.
  final bool verbose;

  final Logger _logger;
  final DispatchTraceFormatter _formatter;

  @override
  void onTrace(DispatchTrace trace) {
    _logger.fine(
      verbose ? _formatter.verbose(trace) : _formatter.compact(trace),
    );
  }
}
