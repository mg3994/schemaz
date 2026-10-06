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

  /// Direct and transitive subtype check
  bool isSubtypeOf(String subCandidate, String superType) {
    if (subCandidate == superType) return true;
    final node = getType(subCandidate);
    if (node == null) return false;

    for (final directSuper in node.supertypes) {
      if (directSuper == superType || isSubtypeOf(directSuper, superType)) {
        return true;
      }
    }
    return false;
  }

  List<SchemaType> findSubtypes(String parentNameOrId) {
    return _nodes.values.where((node) {
      return isSubtypeOf(node.name, parentNameOrId) || isSubtypeOf(node.id, parentNameOrId);
    }).toSet().toList();
  }
}
