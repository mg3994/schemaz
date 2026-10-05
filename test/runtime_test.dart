import 'package:test/test.dart';
import 'package:schemaz/schemaz.dart';

void main() {
  group('Runtime Interpreter Tests', () {
    test('Evaluates Schemaz program and executes print / functions', () {
      final source = '''
      schema Person {
        name: Text
        age: Integer
      }

      person Person {
        name: "Manish"
        age: 30
      }

      function getGreeting(p: Person) -> Text {
        let name = p.name
        return "Hello " + name
      }

      let msg = getGreeting(person)
      print(msg)
      ''';

      final lexer = Lexer(source);
      final tokens = lexer.tokenize();
      final parser = Parser(tokens);
      final ast = parser.parse();

      final interpreter = SchemazInterpreter();
      interpreter.evaluateProgram(ast);

      final personInst = interpreter.globalEnv.get('person');
      expect(personInst, isA<Node>());
      final node = personInst as Node;
      expect(node.get('name'), equals('Manish'));
      expect(node.get('age'), equals(30));

      final msg = interpreter.globalEnv.get('msg');
      expect(msg, equals('Hello Manish'));
    });
  });
}
