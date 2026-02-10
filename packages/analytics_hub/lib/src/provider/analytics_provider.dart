import 'dart:async';

import '../event/event_resolver.dart';
import '../session/session.dart';
import 'provider_key.dart';

abstract class AnalytycsProvider<R extends EventResolver> {
  AnalytycsProvider({required this.key});

  final ProviderKey<R> key;

  R get resolver;

  FutureOr<void> initialize() async {}

  Future<void> setSession(Session? session);

  FutureOr<void> dispose() {}
}
