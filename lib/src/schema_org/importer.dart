import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/registry.dart';
import '../core/schema.dart';
import '../core/type.dart';

/// Importer for Schema.org JSON-LD vocabularies.
class SchemaOrgImporter {
  final SchemaRegistry registry;

  SchemaOrgImporter({SchemaRegistry? registry})
      : registry = registry ?? SchemaRegistry();

  /// Load and parse JSON-LD schema definition from string content.
  void importJsonLd(String jsonLdContent) {
    final Map<String, dynamic> data = jsonDecode(jsonLdContent);
    _parseJsonLdData(data);
  }

  /// Load JSON-LD from HTTP URL.
  Future<void> importFromUrl(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      importJsonLd(response.body);
    } else {
      throw Exception('Failed to load JSON-LD from $url: ${response.statusCode}');
    }
  }

  void _parseJsonLdData(Map<String, dynamic> data) {
    // 1. Process @context definitions if available
    if (data.containsKey('@context')) {
      final context = data['@context'];
      if (context is Map) {
        context.forEach((key, val) {
          if (val is String) {
            registry.registerContext(key.toString(), val);
          }
        });
      }
    }

    // 2. Process @graph nodes
    if (data.containsKey('@graph')) {
      final List<dynamic> graph = data['@graph'];

      // First pass: create all classes/types
      for (final item in graph) {
        if (item is Map<String, dynamic>) {
          _registerClassIfType(item);
        }
      }

      // Second pass: setup inheritance (rdfs:subClassOf)
      for (final item in graph) {
        if (item is Map<String, dynamic>) {
          _linkParentClasses(item);
        }
      }

      // Third pass: process properties (schema:domainIncludes / schema:rangeIncludes)
      for (final item in graph) {
        if (item is Map<String, dynamic>) {
          _registerProperty(item);
        }
      }
    }
  }

  void _registerClassIfType(Map<String, dynamic> item) {
    final type = _getTypes(item);
    if (type.contains('rdfs:Class') || type.contains('schema:Class') || type.contains('Class')) {
      final id = item['@id'] as String? ?? '';
      final label = _extractLabel(item);
      final comment = _extractComment(item);

      if (label.isNotEmpty) {
        final schema = Schema(
          name: label,
          uri: id.isNotEmpty ? id : null,
          description: comment.isNotEmpty ? comment : null,
        );
        registry.registerType(schema);
      }
    }
  }

  void _linkParentClasses(Map<String, dynamic> item) {
    final type = _getTypes(item);
    if (type.contains('rdfs:Class') || type.contains('schema:Class') || type.contains('Class')) {
      final label = _extractLabel(item);
      final schema = registry.lookupSchema(label);
      if (schema == null) return;

      final subClassOf = item['rdfs:subClassOf'];
      if (subClassOf != null) {
        final parentIds = _extractIdList(subClassOf);
        for (final parentId in parentIds) {
          final parentSchema = registry.lookupSchema(_cleanId(parentId));
          if (parentSchema != null && !schema.parents.contains(parentSchema)) {
            schema.parents.add(parentSchema);
          }
        }
      }
    }
  }

  void _registerProperty(Map<String, dynamic> item) {
    final type = _getTypes(item);
    if (type.contains('rdf:Property') || type.contains('schema:Property') || type.contains('Property')) {
      final propName = _extractLabel(item);
      final propUri = item['@id'] as String?;
      final comment = _extractComment(item);

      if (propName.isEmpty) return;

      // Determine ranges (types)
      SchemazType propertyType = PrimitiveType.any;
      if (item.containsKey('schema:rangeIncludes')) {
        final ranges = _extractIdList(item['schema:rangeIncludes']);
        if (ranges.isNotEmpty) {
          final rangeTypeNames = ranges.map(_cleanId).toList();
          final resolvedType = registry.lookup(rangeTypeNames.first);
          if (resolvedType != null) {
            propertyType = resolvedType;
          }
        }
      }

      final propDef = PropertyDefinition(
        name: propName,
        type: propertyType,
        description: comment,
        uri: propUri,
      );

      // Determine domains (which schemas have this property)
      if (item.containsKey('schema:domainIncludes')) {
        final domains = _extractIdList(item['schema:domainIncludes']);
        for (final domainId in domains) {
          final schemaName = _cleanId(domainId);
          final targetSchema = registry.lookupSchema(schemaName);
          if (targetSchema != null) {
            targetSchema.addProperty(propDef);
          }
        }
      }
    }
  }

  List<String> _getTypes(Map<String, dynamic> item) {
    final rawType = item['@type'];
    if (rawType is String) return [rawType];
    if (rawType is List) return rawType.cast<String>();
    return [];
  }

  String _extractLabel(Map<String, dynamic> item) {
    if (item.containsKey('rdfs:label')) {
      final label = item['rdfs:label'];
      if (label is String) return label;
      if (label is Map && label.containsKey('@value')) return label['@value'];
    }
    final id = item['@id'] as String? ?? '';
    return _cleanId(id);
  }

  String _extractComment(Map<String, dynamic> item) {
    if (item.containsKey('rdfs:comment')) {
      final comment = item['rdfs:comment'];
      if (comment is String) return comment;
      if (comment is Map && comment.containsKey('@value')) return comment['@value'];
    }
    return '';
  }

  List<String> _extractIdList(dynamic field) {
    if (field is Map && field.containsKey('@id')) {
      return [field['@id'].toString()];
    }
    if (field is List) {
      final res = <String>[];
      for (final item in field) {
        if (item is Map && item.containsKey('@id')) {
          res.add(item['@id'].toString());
        } else if (item is String) {
          res.add(item);
        }
      }
      return res;
    }
    if (field is String) return [field];
    return [];
  }

  String _cleanId(String uri) {
    if (uri.contains('/')) {
      return uri.split('/').last;
    }
    if (uri.contains(':')) {
      return uri.split(':').last;
    }
    return uri;
  }
}
