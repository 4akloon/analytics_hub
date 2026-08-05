import 'dart:async';

import 'package:analytics_hub/analytics_hub.dart';
import 'package:test/test.dart';

// Test provider and resolver
class TestProviderKey extends ProviderIdentifier {
  const TestProviderKey({super.name});
}

class TestEventResolver implements EventResolver {
  TestEventResolver(this.recorder, this.contextRecorder);

  final List<ResolvedEvent> recorder;
  final List<EventDispatchContext> contextRecorder;

  @override
  Future<void> resolve(
    ResolvedEvent event, {
    required EventDispatchContext context,
  }) async {
    recorder.add(event);
    contextRecorder.add(context);
  }
}

class TestProvider extends AnalyticsProvider {
  TestProvider({
    required super.identifier,
    super.interceptors = const [],
    List<ResolvedEvent>? recorder,
    List<EventDispatchContext>? contextRecorder,
  }) : _resolver = TestEventResolver(recorder ?? [], contextRecorder ?? []);

  final TestEventResolver _resolver;

  @override
  EventResolver get resolver => _resolver;

  var _flushed = false;

  bool get flushed => _flushed;

  @override
  Future<void> flush() async {
    _flushed = true;
  }
}

class TestLogEvent extends Event {
  const TestLogEvent(
    super.name, {
    this.props,
    this.ctx = const EventContext(),
  });

  final Map<String, Object?>? props;
  final EventContext ctx;

  @override
  Map<String, Object?>? get properties => props;

  @override
  EventContext get context => ctx;

  @override
  List<EventProvider> get providers => [
        const EventProvider(TestProviderKey(name: 'test')),
      ];
}

void main() {
  group('AnalyticsHub', () {
    test('sendEvent resolves event with correct provider', () async {
      final recorder = <ResolvedEvent>[];
      final contextRecorder = <EventDispatchContext>[];
      final provider = TestProvider(
        identifier: const TestProviderKey(name: 'test'),
        recorder: recorder,
        contextRecorder: contextRecorder,
      );
      final hub = AnalyticsHub(
        providers: [provider],
      );

      const event = TestLogEvent('test_event', props: {'key': 'value'});
      await hub.sendEvent(event);

      expect(recorder, hasLength(1));
      expect(recorder.first.name, equals('test_event'));
      expect(recorder.first.properties, equals({'key': 'value'}));
      expect(contextRecorder, hasLength(1));
      expect(contextRecorder.first.originalEvent, equals(event));
      expect(contextRecorder.first.providerIdentifier.name, equals('test'));
    });

    test('sendEvent applies provider overrides before resolver', () async {
      final recorder = <ResolvedEvent>[];
      final provider = TestProvider(
        identifier: const TestProviderKey(name: 'test'),
        recorder: recorder,
      );
      final hub = AnalyticsHub(
        providers: [provider],
      );

      final event = _OverriddenProviderEvent(
        'test_event',
        const TestProviderKey(name: 'test'),
      );
      await hub.sendEvent(event);

      expect(recorder, hasLength(1));
      expect(recorder.first.name, equals('test_event_overridden'));
      expect(
        recorder.first.properties,
        equals({'key_overridden': 'value_overridden'}),
      );
    });

    test('global and provider interceptors run in order', () async {
      final order = <String>[];
      final recorder = <ResolvedEvent>[];
      final provider = TestProvider(
        identifier: const TestProviderKey(name: 'test'),
        recorder: recorder,
        interceptors: [
          _SpyInterceptor('provider', order),
        ],
      );
      final hub = AnalyticsHub(
        providers: [provider],
        interceptors: [
          _SpyInterceptor('global', order),
        ],
      );

      await hub.sendEvent(const TestLogEvent('test_event'));

      expect(
        order,
        equals([
          'global-before',
          'provider-before',
          'provider-after',
          'global-after',
        ]),
      );
      expect(recorder, hasLength(1));
    });

    test('interceptor can mutate event name and read typed context', () async {
      final recorder = <ResolvedEvent>[];
      final contextRecorder = <EventDispatchContext>[];
      final provider = TestProvider(
        identifier: const TestProviderKey(name: 'test'),
        recorder: recorder,
        contextRecorder: contextRecorder,
      );
      final hub = AnalyticsHub(
        providers: [provider],
        interceptors: [
          _RenameWithContextInterceptor(),
        ],
      );

      await hub.sendEvent(
        TestLogEvent(
          'test_event',
          ctx: const EventContext().withEntry(
            const _SourceContextEntry('mobile'),
          ),
        ),
      );

      expect(recorder.single.name, equals('test_event_mobile'));
      expect(contextRecorder.single.correlationId, isNotEmpty);
    });

    test('interceptor can drop event before resolver', () async {
      final recorder = <ResolvedEvent>[];
      final provider = TestProvider(
        identifier: const TestProviderKey(name: 'test'),
        recorder: recorder,
      );
      final hub = AnalyticsHub(
        providers: [provider],
        interceptors: [
          _DropInterceptor(),
        ],
      );

      await hub.sendEvent(const TestLogEvent('test_event'));

      expect(recorder, isEmpty);
    });

    test('context contains event metadata', () async {
      final contextRecorder = <EventDispatchContext>[];
      final provider = TestProvider(
        identifier: const TestProviderKey(name: 'test'),
        contextRecorder: contextRecorder,
      );
      final hub = AnalyticsHub(
        providers: [provider],
      );

      await hub.sendEvent(
        TestLogEvent(
          'test_event',
          ctx: const EventContext().withEntry(
            const _SourceContextEntry('mobile'),
          ),
        ),
      );

      final context = contextRecorder.single;
      expect(
        context.entry<_SourceContextEntry>()?.source,
        equals('mobile'),
      );
    });

    test('context does not include provider metadata entries', () async {
      final contextRecorder = <EventDispatchContext>[];
      final provider = TestProvider(
        identifier: const TestProviderKey(name: 'test'),
        contextRecorder: contextRecorder,
      );
      final hub = AnalyticsHub(
        providers: [provider],
      );

      await hub.sendEvent(
        TestLogEvent(
          'test_event',
          ctx: const EventContext().withEntry(
            const _SourceContextEntry('mobile'),
          ),
        ),
      );

      final context = contextRecorder.single;
      expect(context.entry<_SourceContextEntry>()?.source, equals('mobile'));
      expect(context.entries, hasLength(1));
    });

    test('flush calls provider flush', () async {
      final provider = TestProvider(
        identifier: const TestProviderKey(name: 'test'),
      );
      final hub = AnalyticsHub(
        providers: [provider],
      );

      await hub.flush();

      expect(provider.flushed, isTrue);
    });

    test('sendEvent throws when provider not found', () async {
      const otherKey = TestProviderKey(name: 'other');
      final event = _UnknownProviderLogEvent('event', otherKey);
      final hub = AnalyticsHub(
        providers: [
          TestProvider(identifier: const TestProviderKey(name: 'test')),
        ],
      );

      expect(
        () => hub.sendEvent(event),
        throwsA(isA<AnalyticsProviderNotFoundException>()),
      );
      expect(
        () => hub.sendEvent(event),
        throwsA(
          predicate<AnalyticsProviderNotFoundException>(
            (e) => e.key.name == 'other',
          ),
        ),
      );
    });
  });

  group('AnalyticsProviderNotFoundException', () {
    test('toString contains key', () {
      const key = TestProviderKey(name: 'missing');
      const exception = AnalyticsProviderNotFoundException(key);
      expect(exception.toString(), contains('missing'));
      expect(exception.key, equals(key));
    });
  });
}

class _UnknownProviderLogEvent extends Event {
  _UnknownProviderLogEvent(super.name, this.key);

  final TestProviderKey key;

  @override
  List<EventProvider> get providers => [
        EventProvider(key),
      ];
}

class _OverriddenProviderEvent extends Event {
  _OverriddenProviderEvent(super.name, this.key);

  final TestProviderKey key;

  @override
  Map<String, Object?>? get properties => const {'key': 'value'};

  @override
  List<EventProvider> get providers => [
        EventProvider(
          key,
          overrides: const EventOverrides(
            name: 'test_event_overridden',
            properties: {'key_overridden': 'value_overridden'},
          ),
        ),
      ];
}

class _SpyInterceptor implements EventInterceptor {
  _SpyInterceptor(this.name, this.order);

  final String name;
  final List<String> order;

  @override
  FutureOr<InterceptorResult> intercept({
    required ResolvedEvent event,
    required EventDispatchContext context,
    required NextEventInterceptor next,
  }) async {
    order.add('$name-before');
    final result = await next(event, context);
    order.add('$name-after');
    return result;
  }
}

class _DropInterceptor implements EventInterceptor {
  @override
  FutureOr<InterceptorResult> intercept({
    required ResolvedEvent event,
    required EventDispatchContext context,
    required NextEventInterceptor next,
  }) {
    return InterceptorResult.drop(event, context: context);
  }
}

class _RenameWithContextInterceptor implements EventInterceptor {
  @override
  FutureOr<InterceptorResult> intercept({
    required ResolvedEvent event,
    required EventDispatchContext context,
    required NextEventInterceptor next,
  }) {
    final source = event.context.entry<_SourceContextEntry>()?.source;
    final renamed =
        event.copyWith(name: '${event.name}_${source ?? 'unknown'}');
    return next(renamed, context);
  }
}

final class _SourceContextEntry extends ContextEntry {
  const _SourceContextEntry(this.source);

  final String source;
}
