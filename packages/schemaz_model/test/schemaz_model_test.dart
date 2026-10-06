import 'package:test/test.dart';
import 'package:schemaz_core/schemaz_core.dart';
import 'package:schemaz_model/schemaz_model.dart';

void main() {
  group('Schemaz Model Declarations', () {
    test('SchemaDeclaration creation', () {
      const decl = SchemaDeclaration(
        name: 'Person',
        schemaUri: 'https://schema.org/Person',
        properties: [
          PropertyDefinition(
            id: 'https://schema.org/name',
            name: 'name',
          )
        ],
      );

      expect(decl.name, equals('Person'));
      expect(decl.schemaUri, equals('https://schema.org/Person'));
      expect(decl.properties.length, equals(1));
    });

    test('FunctionDeclaration creation', () {
      const fnDecl = FunctionDeclaration(
        name: 'greet',
        returnType: 'String',
        parameters: {'person': 'Person'},
      );

      expect(fnDecl.name, equals('greet'));
      expect(fnDecl.returnType, equals('String'));
      expect(fnDecl.parameters['person'], equals('Person'));
    });
  });
}
