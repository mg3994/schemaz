import 'package:test/test.dart';
import 'package:schemaz_lexer/schemaz_lexer.dart';

void main() {
  group('Schemaz Lexer', () {
    test('Tokenizes schema declaration', () {
      const source = '''
      @schema('https://schema.org/Person')
      schema Person extends Thing {
        name: String;
        email: String?;
      }
      ''';

      final lexer = Lexer(source);
      final tokens = lexer.tokenize();

      expect(tokens.any((t) => t.type == TokenType.at), isTrue);
      expect(tokens.any((t) => t.type == TokenType.schemaKw), isTrue);
      expect(tokens.any((t) => t.type == TokenType.extendsKw), isTrue);
      expect(tokens.any((t) => t.type == TokenType.question), isTrue);
    });

    test('Tokenizes function declaration', () {
      const source = '''
      fn greet(Person person) -> String {
        return "Hello";
      }
      ''';

      final lexer = Lexer(source);
      final tokens = lexer.tokenize();

      expect(tokens.any((t) => t.type == TokenType.fnKw), isTrue);
      expect(tokens.any((t) => t.type == TokenType.arrow), isTrue);
    });
  });
}
