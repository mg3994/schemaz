import 'package:test/test.dart';
import 'package:schemaz_core/schemaz_core.dart';
import 'package:schemaz_model/schemaz_model.dart';
import 'package:schemaz_codegen/schemaz_codegen.dart';

void main() {
  group('DartGenerator', () {
    test('Generates Dart class code from SchemaDeclaration', () {
      const decl = SchemaDeclaration(
        name: 'Person',
        schemaUri: 'https://schema.org/Person',
        properties: [
          PropertyDefinition(
            id: 'name',
            name: 'name',
            ranges: ['String'],
            isNullable: false,
          ),
          PropertyDefinition(
            id: 'email',
            name: 'email',
            ranges: ['String'],
            isNullable: true,
          ),
        ],
      );

      final code = DartGenerator.generate([decl]);

      expect(code, contains('class Person {'));
      expect(code, contains('final String name;'));
      expect(code, contains('final String? email;'));
      expect(code, contains('static const SchemaDescriptor schema ='));
    });
  });
}
