import 'package:test/test.dart';
import 'package:schemaz/schemaz.dart';

void main() {
  group('Collection and Builtin Tests', () {
    test('Parses and evaluates List literals and List methods (.length, .sum, .contains)', () {
      final source = '''
      let numbers = [10, 20, 30]
      let len = numbers.length()
      let total = numbers.sum()
      let hasTen = numbers.contains(10)
      ''';

      final lexer = Lexer(source);
      final tokens = lexer.tokenize();
      final parser = Parser(tokens);
      final ast = parser.parse();

      final interpreter = SchemazInterpreter();
      interpreter.evaluateProgram(ast);

      expect(interpreter.globalEnv.get('numbers'), equals([10, 20, 30]));
      expect(interpreter.globalEnv.get('len'), equals(3));
      expect(interpreter.globalEnv.get('total'), equals(60));
      expect(interpreter.globalEnv.get('hasTen'), equals(true));
    });
  });
}
