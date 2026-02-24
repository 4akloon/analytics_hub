/// Generates correlation IDs for event dispatch context.
abstract interface class CorrelationIdGenerator {
  /// Returns next correlation ID value.
  String nextCorrelationId();
}

/// Correlation ID generator based on current microsecond timestamp.
class TimestampCorrelationIdGenerator implements CorrelationIdGenerator {
  /// Creates a timestamp-based generator.
  const TimestampCorrelationIdGenerator();

  @override
  String nextCorrelationId() {
    final now = DateTime.now().microsecondsSinceEpoch;
    return 'event-$now';
  }
}
