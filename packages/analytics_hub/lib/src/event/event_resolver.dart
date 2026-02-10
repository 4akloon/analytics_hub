import 'event.dart';

abstract interface class EventResolver {}

abstract interface class LogEventResolver extends EventResolver {
  Future<void> resolveLogEvent(LogEvent event);
}

abstract interface class CustomLogEventResolver<T> extends EventResolver {
  Future<void> resolveCustomLogEvent(CustomLogEvent<T> event);
}

abstract interface class ECommerceEventResolver extends EventResolver {
  Future<void> resolveECommerceEvent(ECommerceEvent event);
}
