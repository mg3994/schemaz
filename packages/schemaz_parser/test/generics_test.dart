import 'package:test/test.dart';
import 'package:schemaz_lexer/schemaz_lexer.dart';
import 'package:schemaz_parser/schemaz_parser.dart';
import 'package:schemaz_model/schemaz_model.dart';

void main() {
  group('Generic Types Parsing', () {
    test('Parses generic list property', () {
      const source = '''
      schema Invoice {
        items: List<InvoiceItem>;
      }
      ''';

      final lexer = Lexer(source);
      final tokens = lexer.tokenize();
      final parser = Parser(tokens);
      final decls = parser.parse();

      expect(decls.length, equals(1));
      final schemaDecl = decls.first as SchemaDeclaration;
      expect(schemaDecl.properties.first.ranges.first, equals('List<InvoiceItem>'));
    });
  });
}
