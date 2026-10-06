import 'schema.dart';
import 'type.dart';

/// A runtime Node instance in Schemaz.
/// Everything in Schemaz (data, instances, entities, graph nodes) is a Node.
class Node {
  final String? id; // Unique URI or identifier
  final String? baseUrl; // @base URL if specified
  final Schema schema;
  final Map<String, dynamic> properties;

  Node({
    this.id,
    this.baseUrl,
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

    if (baseUrl != null || schema.uri != null) {
      if (baseUrl != null) {
        result['@context'] = {
          if (schema.uri != null) 'schema': schema.uri,
          '@base': baseUrl,
        };
      } else {
        result['@context'] = schema.uri;
      }
    }

    properties.forEach((key, val) {
      result[key] = _serializeValue(val);
    });
    return result;
  }

  dynamic _serializeValue(dynamic val) {
    if (val is Node) {
      return val.toJson();
    }
    if (val is LocalizedText) {
      return val.toJson();
    }
    if (val is List) {
      return val.map((e) => _serializeValue(e)).toList();
    }
    if (val != null && keyIsLocalized(val)) {
      return val.toJson();
    }
    return val;
  }

  bool keyIsLocalized(dynamic val) {
    try {
      return (val as dynamic).toJson is Function && (val as dynamic).language != null;
    } catch (_) {
      return false;
    }
  }

  @override
  String toString() => 'Node(${schema.name}, id: $id, props: $properties)';
}
