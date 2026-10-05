import 'dart:convert';
import 'package:schemaz_core/schemaz_core.dart';

class JsonLdSerializer {
  /// Serializes a list of [SchemaType] definitions into a JSON-LD `@graph` object.
  static Map<String, dynamic> serializeGraph(List<SchemaType> schemaTypes) {
    final graph = <Map<String, dynamic>>[];

    for (final type in schemaTypes) {
      final properties = type.properties
          .map((p) => {
                '@id': p.id,
                '@type': 'rdf:Property',
                'rdfs:label': p.name,
                if (p.inverseOf != null) 'schema:inverseOf': {'@id': p.inverseOf},
              })
          .toList();

      graph.add({
        '@id': type.id,
        '@type': 'rdfs:Class',
        'rdfs:label': type.name,
        if (type.supertypes.isNotEmpty)
          'rdfs:subClassOf': type.supertypes.map((s) => {'@id': s}).toList(),
      });

      graph.addAll(properties);
    }

    return {
      '@context': 'https://schema.org',
      '@graph': graph,
    };
  }

  static String serializeGraphToString(List<SchemaType> schemaTypes) {
    return const JsonEncoder.withIndent('  ').convert(serializeGraph(schemaTypes));
  }
}
