import 'package:test/test.dart';
import 'package:schemaz_core/schemaz_core.dart';

void main() {
  group('Schemaz Core Types', () {
    test('SchemaType instantiation and properties', () {
      const prop = PropertyDefinition(
        id: 'https://schema.org/name',
        name: 'name',
        domains: ['https://schema.org/Person'],
        ranges: ['https://schema.org/Text'],
      );

      const personType = SchemaType(
        'https://schema.org/Person',
        'Person',
        properties: [prop],
      );

      expect(personType.id, equals('https://schema.org/Person'));
      expect(personType.name, equals('Person'));
      expect(personType.properties.length, equals(1));
      expect(personType.properties.first.name, equals('name'));
    });

    test('SchemaDescriptor runtime introspection model', () {
      const prop = PropertyDefinition(
        id: 'https://schema.org/email',
        name: 'email',
        isNullable: true,
      );

      const descriptor = SchemaDescriptor(
        id: 'https://schema.org/Person',
        name: 'Person',
        properties: [prop],
      );

      expect(descriptor.name, equals('Person'));
      expect(descriptor.properties.first.isNullable, isTrue);
    });
  });
}
