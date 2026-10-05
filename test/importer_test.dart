import 'package:test/test.dart';
import 'package:schemaz/schemaz.dart';

void main() {
  group('SchemaOrgImporter & JsonLdCodec Tests', () {
    final sampleJsonLd = '''
    {
      "@context": {
        "schema": "https://schema.org/"
      },
      "@graph": [
        {
          "@id": "https://schema.org/Thing",
          "@type": "rdfs:Class",
          "rdfs:label": "Thing",
          "rdfs:comment": "The most generic type of item."
        },
        {
          "@id": "https://schema.org/Person",
          "@type": "rdfs:Class",
          "rdfs:label": "Person",
          "rdfs:comment": "A person.",
          "rdfs:subClassOf": { "@id": "https://schema.org/Thing" }
        },
        {
          "@id": "https://schema.org/name",
          "@type": "rdf:Property",
          "rdfs:label": "name",
          "rdfs:comment": "The name of the item.",
          "schema:domainIncludes": { "@id": "https://schema.org/Thing" },
          "schema:rangeIncludes": { "@id": "https://schema.org/Text" }
        },
        {
          "@id": "https://schema.org/email",
          "@type": "rdf:Property",
          "rdfs:label": "email",
          "rdfs:comment": "Email address.",
          "schema:domainIncludes": { "@id": "https://schema.org/Person" },
          "schema:rangeIncludes": { "@id": "https://schema.org/Text" }
        }
      ]
    }
    ''';

    test('Imports classes and properties from JSON-LD sample', () {
      final registry = SchemaRegistry();
      final importer = SchemaOrgImporter(registry: registry);

      importer.importJsonLd(sampleJsonLd);

      final person = registry.lookupSchema('Person');
      expect(person, isNotNull);
      expect(person!.description, equals('A person.'));
      expect(person.parents.length, equals(1));
      expect(person.parents.first.name, equals('Thing'));

      final emailProp = person.findProperty('email');
      expect(emailProp, isNotNull);
      expect(emailProp!.type, equals(PrimitiveType.text));
    });

    test('JsonLdCodec encodes and decodes Node accurately', () {
      final registry = SchemaRegistry();
      final importer = SchemaOrgImporter(registry: registry);
      importer.importJsonLd(sampleJsonLd);

      final personSchema = registry.lookupSchema('Person')!;
      final originalNode = Node(
        id: 'https://example.com/people/manish',
        schema: personSchema,
        properties: {
          'name': 'Manish Gautam',
          'email': 'manish@example.com',
        },
      );

      final codec = JsonLdCodec(registry);
      final jsonLdMap = codec.encodeNode(originalNode);

      expect(jsonLdMap['@type'], equals('Person'));
      expect(jsonLdMap['name'], equals('Manish Gautam'));

      final decodedNode = codec.decodeNode(jsonLdMap);
      expect(decodedNode.schema.name, equals('Person'));
      expect(decodedNode.get('name'), equals('Manish Gautam'));
      expect(decodedNode.get('email'), equals('manish@example.com'));
    });
  });
}
