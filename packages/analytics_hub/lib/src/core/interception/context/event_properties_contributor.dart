/// Opt-in capability for a `ContextEntry` that should also contribute
/// analytics properties.
///
/// Context entries are metadata by default: they are visible to interceptors
/// and resolvers but never reach provider properties. An entry that also
/// implements [EventPropertiesContributor] has [toEventProperties] merged into
/// `ResolvedEvent.properties` before the interceptor chain runs.
///
/// Contributed properties win over event properties (and over
/// `EventOverrides.properties`) when the same key is present in both.
///
/// ```dart
/// final class FlowSourceContextEntry extends ContextEntry
///     implements EventPropertiesContributor {
///   const FlowSourceContextEntry({required this.page, required this.element});
///
///   final String page;
///   final String element;
///
///   @override
///   Map<String, Object?> toEventProperties() => {
///         'source_flow_page': page,
///         'source_flow_element': element,
///       };
/// }
/// ```
abstract interface class EventPropertiesContributor {
  /// Properties to merge into the event properties for this dispatch.
  Map<String, Object?> toEventProperties();
}
