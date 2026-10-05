/// Property definition within a Schemaz schema or vocabulary.
class PropertyDefinition {
  final String id;
  final String name;
  final List<String> domains;
  final List<String> ranges;
  final String? inverseOf;
  final bool isNullable;

  const PropertyDefinition({
    required this.id,
    required this.name,
    this.domains = const [],
    this.ranges = const [],
    this.inverseOf,
    this.isNullable = true,
  });
}
