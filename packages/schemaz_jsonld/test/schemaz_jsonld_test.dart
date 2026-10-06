import 'package:test/test.dart';
import 'package:schemaz_jsonld/schemaz_jsonld.dart';

void main() {
  group('JsonLdParser', () {
    test('Parses JSON-LD graph into SchemaTypes', () {
      const sampleJsonLd = '''
      {
        "@graph": [
          {
            "@id": "https://schema.org/Person",
            "@type": "rdfs:Class",
            "rdfs:label": "Person",
            "rdfs:subClassOf": { "@id": "https://schema.org/Thing" }
          },
          {
            "@id": "https://schema.org/name",
            "@type": "rdf:Property",
            "rdfs:label": "name",
            "schema:domainIncludes": { "@id": "https://schema.org/Person" },
            "schema:rangeIncludes": { "@id": "https://schema.org/Text" }
          }
        ]
      }
      ''';

      final types = JsonLdParser.parseGraph(sampleJsonLd);
      expect(types.length, equals(1));
      final person = types.first;
      expect(person.name, equals('Person'));
      expect(person.properties.length, equals(1));
      expect(person.properties.first.name, equals('name'));
    });
  });
}
