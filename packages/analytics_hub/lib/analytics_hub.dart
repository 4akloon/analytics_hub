/// Analytics Hub — a unified analytics abstraction for Dart/Flutter apps.
///
/// This library lets you send events to multiple analytics backends (e.g. Firebase,
/// Mixpanel) through a single API. You register [AnalyticsProvider]s, then send
/// [Event]s; each event declares which providers should receive it via [Event.providers].
///
/// Example:
/// ```dart
/// final hub = AnalyticsHub(
///   providers: [firebaseProvider, mixpanelProvider],
/// );
/// await hub.sendEvent(MyLogEvent('button_clicked'));
/// ```
library;

export 'src/analytics_hub.dart';
export 'src/analytics_sink.dart';
export 'src/core/interception/context/context_entry.dart';
export 'src/core/interception/context/context_record.dart';
export 'src/core/interception/context/event_context.dart';
export 'src/core/interception/context/event_dispatch_context.dart';
export 'src/core/interception/context/resolved_event.dart';
export 'src/core/interception/dispatch/context_builder.dart';
export 'src/core/interception/dispatch/correlation_id_generator.dart';
export 'src/core/interception/dispatch/dispatch_target.dart';
export 'src/core/interception/dispatch/event_dispatcher.dart';
export 'src/core/interception/dispatch/event_snapshot.dart';
export 'src/core/interception/dispatch/interceptor_chain_executor.dart';
export 'src/core/interception/dispatch/overrides_applier.dart';
export 'src/core/interception/interceptor/event_interceptor.dart';
export 'src/core/interception/interceptor/interceptor_result.dart';
export 'src/core/trace/dispatch_trace.dart';
export 'src/core/trace/dispatch_trace_formatter.dart';
export 'src/core/trace/logging_trace_sink.dart';
export 'src/core/trace/properties_diff.dart';
export 'src/core/trace/stage_record.dart';
export 'src/core/trace/trace_sink.dart';
export 'src/event/event_resolver.dart';
export 'src/event/events/events.dart';
export 'src/provider/analytics_provider.dart';
export 'src/provider/provider_identifier.dart';
export 'src/scope/analytics_scope.dart';
export 'src/scoped_analytics.dart';
