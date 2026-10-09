import 'package:analytics_hub/analytics_hub.dart';
import 'package:flutter/widgets.dart';

/// Puts an [AnalyticsScope] on the widget tree.
///
/// Wrap the app in [AnalyticsScopeProvider.root] once, then wrap a page or a
/// section in an [AnalyticsScopeProvider] to give every event sent from that
/// subtree the scope's context and interceptors. Nested providers compose:
/// each one is a child of the nearest provider above it.
///
/// [of] returns the nearest [AnalyticsSink] — the hub itself directly under
/// the root, a `ScopedAnalytics` under a scope. Hand it to a cubit or an
/// analytics helper where the screen creates them.
///
/// The widget builds an `InheritedTheme`, so an overlay opened through
/// `showDialog`, `showModalBottomSheet`, `showMenu`/`PopupMenuButton`,
/// `DropdownButton`, `SearchAnchor` or `showAboutDialog` sees the scope of the
/// context it was opened from. `showGeneralDialog`, `showCupertinoDialog`,
/// `showCupertinoModalPopup` and `SnackBar`s do not capture inherited themes,
/// so they do not see the scope unless they apply `InheritedTheme.capture`
/// themselves. A route pushed on a `Navigator` does not either: carry what it
/// needs explicitly.
class AnalyticsScopeProvider extends StatelessWidget {
  /// Nests a scope named [name] under the nearest provider above.
  ///
  /// Throws at build time when there is no [AnalyticsScopeProvider.root]
  /// above.
  ///
  /// Equal rebuilds do not notify dependents only when `context` entries and
  /// `interceptors` compare equal — prefer `const` entries and interceptors,
  /// or give them value equality.
  const AnalyticsScopeProvider({
    required String name,
    EventContext context = const EventContext(),
    List<EventInterceptor> interceptors = const [],
    required this.child,
    super.key,
  })  : _hub = null,
        _name = name,
        _context = context,
        _interceptors = interceptors;

  /// Provides [hub] to the subtree with no scope of its own.
  ///
  /// Scopes above a root are not visible below it: a nested root starts a
  /// fresh tree.
  const AnalyticsScopeProvider.root({
    required AnalyticsHub hub,
    required this.child,
    super.key,
  })  : _hub = hub,
        _name = null,
        _context = const EventContext(),
        _interceptors = const [];

  final AnalyticsHub? _hub;
  final String? _name;
  final EventContext _context;
  final List<EventInterceptor> _interceptors;

  /// The subtree that sees this provider.
  final Widget child;

  /// The nearest sink: the hub under the root, a `ScopedAnalytics` under
  /// a scope.
  ///
  /// Throws a [FlutterError] when no [AnalyticsScopeProvider.root] is above
  /// [context].
  static AnalyticsSink of(BuildContext context) => _inheritedOf(context).sink;

  /// Like [of], but `null` when no provider is above [context].
  static AnalyticsSink? maybeOf(BuildContext context) =>
      _maybeInheritedOf(context)?.sink;

  /// Like [of], but registers no dependency: callable from `initState`,
  /// `BlocProvider.create` and callbacks. The caller keeps the sink it got
  /// and does not see later scope changes.
  ///
  /// Throws a [FlutterError] when no [AnalyticsScopeProvider.root] is above
  /// [context].
  static AnalyticsSink read(BuildContext context) {
    final inherited =
        context.getInheritedWidgetOfExactType<_AnalyticsScopeInherited>();
    if (inherited == null) throw _missingRoot(context);
    return inherited.sink;
  }

  /// The nearest scope, or `null` directly under the root.
  ///
  /// Throws a [FlutterError] when no [AnalyticsScopeProvider.root] is above
  /// [context].
  static AnalyticsScope? scopeOf(BuildContext context) =>
      _inheritedOf(context).scope;

  static _AnalyticsScopeInherited? _maybeInheritedOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_AnalyticsScopeInherited>();

  static _AnalyticsScopeInherited _inheritedOf(BuildContext context) {
    final inherited = _maybeInheritedOf(context);
    if (inherited == null) throw _missingRoot(context);
    return inherited;
  }

  static FlutterError _missingRoot(BuildContext context) =>
      FlutterError.fromParts([
        ErrorSummary('No AnalyticsScopeProvider found in this context.'),
        ErrorDescription(
          'AnalyticsScopeProvider.of(), read(), scopeOf() and a nested '
          'AnalyticsScopeProvider need an AnalyticsScopeProvider.root above '
          'them. Wrap the app (above the router) in '
          'AnalyticsScopeProvider.root(hub: ...).',
        ),
        context.describeElement('The context used was'),
      ]);

  @override
  Widget build(BuildContext context) {
    if (_hub case final hub?) {
      return _AnalyticsScopeInherited(hub: hub, scope: null, child: child);
    }
    final parent = _inheritedOf(context);
    final name = _name!;
    final scope = switch (parent.scope) {
      null => AnalyticsScope(
          name: name,
          context: _context,
          interceptors: _interceptors,
        ),
      final parentScope => parentScope.child(
          name: name,
          context: _context,
          interceptors: _interceptors,
        ),
    };
    return _AnalyticsScopeInherited(
      hub: parent.hub,
      scope: scope,
      child: child,
    );
  }
}

final class _AnalyticsScopeInherited extends InheritedTheme {
  _AnalyticsScopeInherited({
    required this.hub,
    required this.scope,
    required super.child,
  }) : sink = switch (scope) {
          null => hub,
          final scope => ScopedAnalytics(hub, scope),
        };

  final AnalyticsHub hub;
  final AnalyticsScope? scope;
  final AnalyticsSink sink;

  @override
  Widget wrap(BuildContext context, Widget child) =>
      _AnalyticsScopeInherited(hub: hub, scope: scope, child: child);

  @override
  bool updateShouldNotify(_AnalyticsScopeInherited oldWidget) =>
      oldWidget.hub != hub || oldWidget.scope != scope;
}
