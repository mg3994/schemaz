import 'package:test/test.dart';
import 'package:schemaz/schemaz.dart';

void main() {
  group('DartCodeGenerator Tests', () {
    test('Generates valid Dart class string from Schemaz Schema', () {
      final personSchema = Schema(
        name: 'Person',
        uri: 'https://schema.org/Person',
      );
      personSchema.addProperty(PropertyDefinition(
        name: 'name',
        type: PrimitiveType.text,
      ));
      personSchema.addProperty(PropertyDefinition(
        name: 'age',
        type: PrimitiveType.integer,
      ));

      final codegen = DartCodeGenerator();
      final dartCode = codegen.generateDartClass(personSchema);

      expect(dartCode, contains('class Person {'));
      expect(dartCode, contains('final String? name;'));
      expect(dartCode, contains('final int? age;'));
      expect(dartCode, contains('factory Person.fromNode(sz.Node node)'));
      expect(dartCode, contains('sz.Node toNode(sz.SchemaRegistry registry)'));
    });
  });
}
