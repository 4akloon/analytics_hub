import 'package:analytics_hub/src/event/events/events.dart';
import 'package:analytics_hub/src/provider/analytics_provider.dart';
import 'package:analytics_hub/src/provider/provider_identifier.dart';

/// Provider target that receives one event dispatch.
class DispatchTarget {
  /// Creates provider dispatch target.
  const DispatchTarget({
    required this.eventProvider,
    required this.provider,
  });

  /// Event target declaration selected from [Event.providers].
  final EventProvider eventProvider;

  /// Concrete provider instance resolved by identifier.
  final AnalytycsProvider provider;

  /// Convenience accessor for provider identifier.
  ProviderIdentifier get providerIdentifier => eventProvider.identifier;
}
