import 'dispatch_trace.dart';

/// Receives one [DispatchTrace] per event/provider dispatch.
///
/// Register sinks through `AnalyticsHub(traceSinks: [...])`. With no sinks
/// the hub records nothing.
abstract interface class TraceSink {
  /// Called once per dispatch, after its outcome is known.
  void onTrace(DispatchTrace trace);
}
