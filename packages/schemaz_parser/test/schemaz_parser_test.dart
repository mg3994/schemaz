import 'package:test/test.dart';
import 'package:schemaz_lexer/schemaz_lexer.dart';
import 'package:schemaz_parser/schemaz_parser.dart';
import 'package:schemaz_model/schemaz_model.dart';

void main() {
  group('Schemaz Parser', () {
    test('Parses schema declaration with annotation', () {
      const source = '''
      @schema('https://schema.org/Person')
      schema Person extends Thing {
        name: String;
        email: String?;
      }
      ''';

      final lexer = Lexer(source);
      final tokens = lexer.tokenize();
      final parser = Parser(tokens);
      final declarations = parser.parse();

      expect(declarations.length, equals(1));
      final schemaDecl = declarations.first as SchemaDeclaration;
      expect(schemaDecl.name, equals('Person'));
      expect(schemaDecl.supertype, equals('Thing'));
      expect(schemaDecl.schemaUri, equals('https://schema.org/Person'));
      expect(schemaDecl.properties.length, equals(2));
      expect(schemaDecl.properties.last.isNullable, isTrue);
    });

    test('Parses function declaration', () {
      const source = '''
      fn greet(Person person) -> String {
        return "Hello";
      }
      ''';

      final lexer = Lexer(source);
      final tokens = lexer.tokenize();
      final parser = Parser(tokens);
      final declarations = parser.parse();

      expect(declarations.length, equals(1));
      final fnDecl = declarations.first as FunctionDeclaration;
      expect(fnDecl.name, equals('greet'));
      expect(fnDecl.returnType, equals('String'));
      expect(fnDecl.parameters['person'], equals('Person'));
    });
  });
}
