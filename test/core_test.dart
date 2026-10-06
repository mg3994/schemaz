import 'package:test/test.dart';
import 'package:schemaz/schemaz.dart';

void main() {
  group('Core Semantic Kernel Tests', () {
    test('Registry initializes primitive types', () {
      final registry = SchemaRegistry();
      expect(registry.lookup('Text'), equals(PrimitiveType.text));
      expect(registry.lookup('Integer'), equals(PrimitiveType.integer));
      expect(registry.lookup('Float'), equals(PrimitiveType.float));
      expect(registry.lookup('Boolean'), equals(PrimitiveType.boolean));
    });

    test('Schema definition and property creation', () {
      final registry = SchemaRegistry();
      final personSchema = Schema(
        name: 'Person',
        uri: 'https://schema.org/Person',
        description: 'A person (alive, dead, undead, or fictional).',
      );
      personSchema.addProperty(PropertyDefinition(
        name: 'name',
        type: PrimitiveType.text,
        isRequired: true,
      ));
      personSchema.addProperty(PropertyDefinition(
        name: 'age',
        type: PrimitiveType.integer,
      ));

      registry.registerType(personSchema);

      expect(registry.lookupSchema('Person'), equals(personSchema));
      expect(registry.lookupSchema('https://schema.org/Person'), equals(personSchema));

      final nameProp = personSchema.findProperty('name');
      expect(nameProp, isNotNull);
      expect(nameProp!.type, equals(PrimitiveType.text));
    });

    test('Node instantiation and serialization', () {
      final personSchema = Schema(
        name: 'Person',
        uri: 'https://schema.org/Person',
      )..addProperty(PropertyDefinition(
          name: 'name',
          type: PrimitiveType.text,
        ));

      final personNode = Node(
        id: 'https://example.com/person/1',
        schema: personSchema,
        properties: {'name': 'Manish Gautam'},
      );

      expect(personNode.get('name'), equals('Manish Gautam'));
      final json = personNode.toJson();
      expect(json['@type'], equals('Person'));
      expect(json['@id'], equals('https://example.com/person/1'));
      expect(json['name'], equals('Manish Gautam'));
    });
  });
}
