import 'property.dart';

/// Descriptor providing runtime reflection/introspection metadata for a schema.
class SchemaDescriptor {
  final String id;
  final String name;
  final List<PropertyDefinition> properties;

  const SchemaDescriptor({
    required this.id,
    required this.name,
    this.properties = const [],
  });
}
