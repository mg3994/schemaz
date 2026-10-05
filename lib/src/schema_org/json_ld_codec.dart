import 'dart:convert';
import '../core/node.dart';
import '../core/registry.dart';
import '../core/schema.dart';

/// Helper for serializing Schemaz Nodes to and from standard JSON-LD objects.
class JsonLdCodec {
  final SchemaRegistry registry;

  JsonLdCodec(this.registry);

  /// Convert a Node to JSON-LD map structure
  Map<String, dynamic> encodeNode(Node node) {
    return node.toJson();
  }

  /// Convert JSON-LD map structure back to a Schemaz Node
  Node decodeNode(Map<String, dynamic> json) {
    final typeName = json['@type'] as String?;
    if (typeName == null) {
      throw FormatException('Missing @type in JSON-LD document');
    }

    final schema = registry.lookupSchema(typeName) ??
        Schema(name: typeName, uri: json['@context'] as String?);

    final id = json['@id'] as String?;
    final props = <String, dynamic>{};

    json.forEach((key, value) {
      if (key == '@type' || key == '@id' || key == '@context') return;

      if (value is Map<String, dynamic> && value.containsKey('@type')) {
        props[key] = decodeNode(value);
      } else if (value is List) {
        props[key] = value.map((item) {
          if (item is Map<String, dynamic> && item.containsKey('@type')) {
            return decodeNode(item);
          }
          return item;
        }).toList();
      } else {
        props[key] = value;
      }
    });

    return Node(id: id, schema: schema, properties: props);
  }
}
