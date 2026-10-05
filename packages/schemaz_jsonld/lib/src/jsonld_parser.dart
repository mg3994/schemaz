import 'dart:convert';
import 'package:schemaz_core/schemaz_core.dart';
import 'jsonld_context.dart';

class JsonLdParser {
  /// Parses standard Schema.org JSON-LD graph into a list of [SchemaType] definitions.
  static List<SchemaType> parseGraph(String jsonLdString) {
    final Map<String, dynamic> data = jsonDecode(jsonLdString);
    final context = JsonLdContext.fromJson(data['@context']);
    final List<dynamic> graph = data['@graph'] ?? [data];

    final types = <String, SchemaType>{};
    final properties = <String, PropertyDefinition>{};

    for (final item in graph) {
      if (item is! Map<String, dynamic>) continue;
      final rawId = item['@id'] as String? ?? '';
      final id = context.expandTerm(rawId);
      final type = item['@type'];

      if (type == 'rdfs:Class' || type == 'schema:Type') {
        final name = item['rdfs:label'] is Map
            ? item['rdfs:label']['@value']
            : (item['rdfs:label'] ?? id.split('/').last);

        List<String> supertypes = [];
        if (item['rdfs:subClassOf'] != null) {
          final subClass = item['rdfs:subClassOf'];
          if (subClass is Map) {
            supertypes.add(context.expandTerm(subClass['@id'] ?? ''));
          } else if (subClass is List) {
            for (final sc in subClass) {
              if (sc is Map && sc['@id'] != null) {
                supertypes.add(context.expandTerm(sc['@id']));
              }
            }
          }
        }

        types[id] = SchemaType(
          id,
          name.toString(),
          supertypes: supertypes,
        );
      } else if (type == 'rdf:Property') {
        final name = item['rdfs:label'] is Map
            ? item['rdfs:label']['@value']
            : (item['rdfs:label'] ?? id.split('/').last);

        List<String> domains = [];
        if (item['schema:domainIncludes'] != null) {
          final d = item['schema:domainIncludes'];
          if (d is Map && d['@id'] != null) domains.add(context.expandTerm(d['@id']));
          if (d is List) {
            for (final dom in d) {
              if (dom is Map && dom['@id'] != null) domains.add(context.expandTerm(dom['@id']));
            }
          }
        }

        List<String> ranges = [];
        if (item['schema:rangeIncludes'] != null) {
          final r = item['schema:rangeIncludes'];
          if (r is Map && r['@id'] != null) ranges.add(context.expandTerm(r['@id']));
          if (r is List) {
            for (final ran in r) {
              if (ran is Map && ran['@id'] != null) ranges.add(context.expandTerm(ran['@id']));
            }
          }
        }

        String? inverseOf;
        if (item['schema:inverseOf'] is Map) {
          inverseOf = context.expandTerm(item['schema:inverseOf']['@id']);
        }

        properties[id] = PropertyDefinition(
          id: id,
          name: name.toString(),
          domains: domains,
          ranges: ranges,
          inverseOf: inverseOf,
        );
      }
    }

    // Attach properties to their target domain SchemaTypes
    return types.values.map((schemaType) {
      final typeProps = properties.values.where((prop) {
        return prop.domains.contains(schemaType.id) ||
            prop.domains.contains('schema:${schemaType.name}') ||
            prop.domains.contains('http://schema.org/${schemaType.name}') ||
            prop.domains.contains('https://schema.org/${schemaType.name}');
      }).toList();

      return SchemaType(
        schemaType.id,
        schemaType.name,
        supertypes: schemaType.supertypes,
        properties: typeProps,
      );
    }).toList();
  }
}
