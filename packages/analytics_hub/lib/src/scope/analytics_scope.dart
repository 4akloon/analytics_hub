import '../core/interception/context/event_context.dart';
import '../core/interception/interceptor/event_interceptor.dart';

/// An immutable slice of analytics context with its own interceptors.
///
/// Scopes nest through [child]; [chain] lists them root → leaf. A scope owns
/// no providers, routing or state — `AnalyticsHub.sendEvent(event, scope:)`
/// applies the chain's context and runs the chain's interceptors before the
/// hub's own. Creating a child never changes its parent.
final class AnalyticsScope {
  /// Creates a scope named [name].
  ///
  /// Every record of [context] is re-attributed to `'scope:<name>'`.
  AnalyticsScope({
    required this.name,
    EventContext context = const EventContext(),
    this.interceptors = const [],
    this.parent,
  }) : context = context.attributedTo('scope:$name');

  /// Scope name, e.g. `'home'` or `'create'`.
  final String name;

  /// This scope's own records, attributed to [source].
  final EventContext context;

  /// Interceptors that run only for events sent through this scope or one of
  /// its descendants, before the hub's interceptors.
  final List<EventInterceptor> interceptors;

  /// The enclosing scope, or `null` for a root.
  final AnalyticsScope? parent;

  /// The source every record of [context] carries: `'scope:<name>'`.
  String get source => 'scope:$name';

  /// This scope and its ancestors, root first.
  List<AnalyticsScope> get chain {
    final result = <AnalyticsScope>[];
    for (AnalyticsScope? scope = this; scope != null; scope = scope.parent) {
      result.add(scope);
    }
    return result.reversed.toList(growable: false);
  }

  /// Every record of [chain], root → leaf.
  EventContext get effectiveContext => chain.fold(
        const EventContext(),
        (acc, scope) => acc.append(scope.context),
      );

  /// Returns a scope nested in this one.
  AnalyticsScope child({
    required String name,
    EventContext context = const EventContext(),
    List<EventInterceptor> interceptors = const [],
  }) =>
      AnalyticsScope(
        name: name,
        context: context,
        interceptors: interceptors,
        parent: this,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalyticsScope &&
          other.name == name &&
          other.parent == parent &&
          _listEquals(other.context.records, context.records) &&
          _listEquals(other.interceptors, interceptors);

  @override
  int get hashCode => Object.hash(
        name,
        parent,
        Object.hashAll(context.records),
        Object.hashAll(interceptors),
      );

  @override
  String toString() => 'AnalyticsScope(${chain.map((s) => s.name).join('/')})';

  static bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
