import 'package:test/test.dart';
import 'package:schemaz_core/schemaz_core.dart';
import 'package:schemaz_jsonld/schemaz_jsonld.dart';

void main() {
  group('JsonLdSerializer', () {
    test('Serializes SchemaTypes to JSON-LD @graph structure', () {
      const type = SchemaType(
        'https://schema.org/Person',
        'Person',
        supertypes: ['https://schema.org/Thing'],
        properties: [
          PropertyDefinition(
            id: 'https://schema.org/name',
            name: 'name',
          )
        ],
      );

      final jsonLdMap = JsonLdSerializer.serializeGraph([type]);

      expect(jsonLdMap['@context'], equals('https://schema.org'));
      final graph = jsonLdMap['@graph'] as List;
      expect(graph.length, equals(2)); // 1 class + 1 property
    });
  });
}
