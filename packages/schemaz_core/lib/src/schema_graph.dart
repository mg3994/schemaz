import 'types.dart';
import 'property.dart';

class SchemaGraphNode {
  final SchemaType schemaType;
  final List<PropertyDefinition> properties;

  const SchemaGraphNode({
    required this.schemaType,
    this.properties = const [],
  });
}

class SchemaGraph {
  final Map<String, SchemaType> _nodes = {};
  final Map<String, PropertyDefinition> _properties = {};

  void addType(SchemaType type) {
    _nodes[type.id] = type;
    _nodes[type.name] = type;
    for (final prop in type.properties) {
      _properties[prop.id] = prop;
      _properties[prop.name] = prop;
    }
  }

  SchemaType? getType(String nameOrId) => _nodes[nameOrId];

  PropertyDefinition? getInverseProperty(PropertyDefinition prop) {
    if (prop.inverseOf != null && _properties.containsKey(prop.inverseOf)) {
      return _properties[prop.inverseOf];
    }
    return _properties.values.cast<PropertyDefinition?>().firstWhere(
      (p) => p != null && p.inverseOf == prop.id || p?.inverseOf == prop.name,
      orElse: () => null,
    );
  }

  List<SchemaType> findSubtypes(String parentNameOrId) {
    return _nodes.values.where((node) {
      return node.supertypes.contains(parentNameOrId);
    }).toSet().toList();
  }
}
