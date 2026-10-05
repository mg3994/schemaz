import 'package:test/test.dart';
import 'package:schemaz_core/schemaz_core.dart';

void main() {
  group('SchemaGraph', () {
    test('Resolves inverse properties and subtype relationships', () {
      const alumniProp = PropertyDefinition(
        id: 'https://schema.org/alumni',
        name: 'alumni',
        inverseOf: 'https://schema.org/alumniOf',
      );

      const alumniOfProp = PropertyDefinition(
        id: 'https://schema.org/alumniOf',
        name: 'alumniOf',
        inverseOf: 'https://schema.org/alumni',
      );

      const orgType = SchemaType(
        'https://schema.org/Organization',
        'Organization',
        properties: [alumniProp],
      );

      const personType = SchemaType(
        'https://schema.org/Person',
        'Person',
        properties: [alumniOfProp],
      );

      final graph = SchemaGraph();
      graph.addType(orgType);
      graph.addType(personType);

      final inverse = graph.getInverseProperty(alumniProp);
      expect(inverse, isNotNull);
      expect(inverse!.name, equals('alumniOf'));
    });
  });
}
