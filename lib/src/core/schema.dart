import 'type.dart';

/// Definition of a property/field within a Schema.
class PropertyDefinition {
  final String name;
  final SchemazType type;
  final bool isRequired;
  final dynamic defaultValue;
  final String? description;
  final String? uri; // e.g. https://schema.org/name

  const PropertyDefinition({
    required this.name,
    required this.type,
    this.isRequired = false,
    this.defaultValue,
    this.description,
    this.uri,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type.toJson(),
        'isRequired': isRequired,
        if (defaultValue != null) 'defaultValue': defaultValue,
        if (description != null) 'description': description,
        if (uri != null) 'uri': uri,
      };
}

/// A Schema defines the shape, types, constraints, and parents of data nodes.
class Schema extends SchemazType {
  final String? uri; // e.g. https://schema.org/Person
  final List<Schema> parents;
  final Map<String, PropertyDefinition> properties;

  Schema({
    required String name,
    String? description,
    this.uri,
    List<Schema>? parents,
    Map<String, PropertyDefinition>? properties,
  })  : parents = parents ?? [],
        properties = properties ?? {},
        super(name, description: description);

  void addProperty(PropertyDefinition property) {
    properties[property.name] = property;
  }

  PropertyDefinition? findProperty(String propName) {
    if (properties.containsKey(propName)) {
      return properties[propName];
    }
    for (final parent in parents) {
      final prop = parent.findProperty(propName);
      if (prop != null) return prop;
    }
    return null;
  }

  bool inheritsFrom(Schema other) {
    if (this == other || uri == other.uri) return true;
    for (final parent in parents) {
      if (parent.inheritsFrom(other)) return true;
    }
    return false;
  }

  @override
  bool isAssignableTo(SchemazType other) {
    if (other == PrimitiveType.any) return true;
    if (other is Schema) {
      return inheritsFrom(other);
    }
    return false;
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': 'Schema',
        'name': name,
        if (uri != null) 'uri': uri,
        if (description != null) 'description': description,
        'parents': parents.map((p) => p.name).toList(),
        'properties': properties.map((k, v) => MapEntry(k, v.toJson())),
      };
}
