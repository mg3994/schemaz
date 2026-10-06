import 'package:test/test.dart';
import 'package:schemaz/schemaz.dart';

void main() {
  group('SchemaValidator Tests', () {
    test('Validates required fields and property types', () {
      final registry = SchemaRegistry();
      StandardVocabularies.registerStandardSchemaOrgTypes(registry);

      final personSchema = registry.lookupSchema('Person')!;
      personSchema.addProperty(PropertyDefinition(
        name: 'age',
        type: PrimitiveType.integer,
        isRequired: true,
      ));

      final validNode = Node(
        schema: personSchema,
        properties: {
          'name': 'Manish Gautam',
          'age': 30,
        },
      );

      final validator = SchemaValidator(registry: registry);
      final res1 = validator.validateNode(validNode);
      expect(res1.isValid, isTrue);

      final invalidNode = Node(
        schema: personSchema,
        properties: {
          'name': 'Manish Gautam',
          'age': "thirty", // Wrong type
        },
      );

      final res2 = validator.validateNode(invalidNode);
      expect(res2.isValid, isFalse);
      expect(res2.errors.length, equals(1));
      expect(res2.errors.first.message, contains('Expected Integer'));
    });
  });
}
