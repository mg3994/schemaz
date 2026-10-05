import 'schema.dart';

/// A runtime Node instance in Schemaz.
/// Everything in Schemaz (data, instances, entities, graph nodes) is a Node.
class Node {
  final String? id; // Unique URI or identifier
  final Schema schema;
  final Map<String, dynamic> properties;

  Node({
    this.id,
    required this.schema,
    Map<String, dynamic>? properties,
  }) : properties = properties ?? {};

  dynamic get(String propertyName) {
    if (properties.containsKey(propertyName)) {
      return properties[propertyName];
    }
    return null;
  }

  void set(String propertyName, dynamic value) {
    properties[propertyName] = value;
  }

  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{
      if (id != null) '@id': id,
      '@type': schema.name,
    };
    if (schema.uri != null) {
      result['@context'] = schema.uri;
    }
    properties.forEach((key, val) {
      if (val is Node) {
        result[key] = val.toJson();
      } else if (val is List) {
        result[key] = val.map((e) => e is Node ? e.toJson() : e).toList();
      } else {
        result[key] = val;
      }
    });
    return result;
  }

  @override
  String toString() => 'Node(${schema.name}, id: $id, props: $properties)';
}
