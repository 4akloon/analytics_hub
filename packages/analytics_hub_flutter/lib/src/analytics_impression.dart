import 'package:analytics_hub/analytics_hub.dart';
import 'package:flutter/widgets.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'analytics_scope_provider.dart';

/// Sends one event through the nearest [AnalyticsScopeProvider] sink when
/// [child] first has at least [visibleFraction] of its area on screen.
///
/// The event is built lazily by [event] at that moment and sent once per
/// [State] lifetime. In a lazy `ListView` or `SliverList` an item scrolled far
/// enough away is disposed, and it sends again when it is rebuilt. To report
/// strictly once, keep the item alive (`AutomaticKeepAliveClientMixin` or
/// `addAutomaticKeepAlives`) or deduplicate in the receiver, for example in
/// the cubit. The default fraction follows the common impression rule of half
/// the view.
class AnalyticsImpression extends StatefulWidget {
  /// Creates an impression sender around [child].
  const AnalyticsImpression({
    required this.event,
    this.visibleFraction = 0.5,
    required this.child,
    super.key,
  });

  /// Builds the event to send; called once, when the threshold is reached.
  final Event Function() event;

  /// Fraction of [child]'s area that must be visible, between 0 and 1.
  final double visibleFraction;

  /// The subtree whose visibility is observed.
  final Widget child;

  @override
  State<AnalyticsImpression> createState() => _AnalyticsImpressionState();
}

class _AnalyticsImpressionState extends State<AnalyticsImpression> {
  final Key _detectorKey = UniqueKey();
  bool _sent = false;

  void _onVisibilityChanged(VisibilityInfo info) {
    if (_sent || !mounted || info.visibleFraction < widget.visibleFraction) {
      return;
    }
    _sent = true;
    AnalyticsScopeProvider.of(context).sendEvent(widget.event());
  }

  @override
  void dispose() {
    VisibilityDetectorController.instance.forget(_detectorKey);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => VisibilityDetector(
        key: _detectorKey,
        onVisibilityChanged: _onVisibilityChanged,
        child: widget.child,
      );
}
