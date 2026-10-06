import 'package:test/test.dart';
import 'package:schemaz/schemaz.dart';

void main() {
  group('Lexer & Parser Tests', () {
    test('Tokenizes and parses schema and instance declarations', () {
      final source = '''
      schema Person {
        name: Text
        age: Integer
      }

      person Person {
        name: "Manish"
        age: 30
      }

      function greet(p: Person) -> Text {
        let message = "Hello " + p.name
        return message
      }
      ''';

      final lexer = Lexer(source);
      final tokens = lexer.tokenize();
      final parser = Parser(tokens);
      final ast = parser.parse();

      expect(ast.statements.length, equals(3));
      expect(ast.statements[0], isA<SchemaDeclNode>());
      expect(ast.statements[1], isA<InstanceDeclNode>());
      expect(ast.statements[2], isA<FunctionDeclNode>());

      final schemaNode = ast.statements[0] as SchemaDeclNode;
      expect(schemaNode.name, equals('Person'));
      expect(schemaNode.properties.length, equals(2));

      final instanceNode = ast.statements[1] as InstanceDeclNode;
      expect(instanceNode.name, equals('person'));
      expect(instanceNode.schemaName, equals('Person'));

      final fnNode = ast.statements[2] as FunctionDeclNode;
      expect(fnNode.name, equals('greet'));
      expect(fnNode.parameters.length, equals(1));
      expect(fnNode.returnTypeName, equals('Text'));
    });

    test('Semantic Analyzer registers schemas and properties from AST', () {
      final source = '''
      schema Entity {
        id: Text
      }

      schema Person extends Entity {
        name: Text
      }
      ''';

      final lexer = Lexer(source);
      final tokens = lexer.tokenize();
      final parser = Parser(tokens);
      final ast = parser.parse();

      final analyzer = SemanticAnalyzer();
      analyzer.analyze(ast);

      final personSchema = analyzer.registry.lookupSchema('Person');
      expect(personSchema, isNotNull);
      expect(personSchema!.parents.length, equals(1));
      expect(personSchema.parents.first.name, equals('Entity'));

      // Inherited property 'id'
      expect(personSchema.findProperty('id'), isNotNull);
      // Own property 'name'
      expect(personSchema.findProperty('name'), isNotNull);
    });
  });
}
