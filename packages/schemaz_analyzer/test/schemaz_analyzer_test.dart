import 'package:test/test.dart';
import 'package:schemaz_core/schemaz_core.dart';
import 'package:schemaz_model/schemaz_model.dart';
import 'package:schemaz_analyzer/schemaz_analyzer.dart';

void main() {
  group('SemanticAnalyzer', () {
    test('Analyzes valid declarations and populates SymbolTable', () {
      final analyzer = SemanticAnalyzer();
      const decl = SchemaDeclaration(
        name: 'Person',
        properties: [
          PropertyDefinition(
            id: 'name',
            name: 'name',
            ranges: ['String'],
          )
        ],
      );

      analyzer.analyze([decl]);

      expect(analyzer.diagnostics, isEmpty);
      expect(analyzer.symbolTable.contains('Person'), isTrue);
    });

    test('Reports diagnostic for undefined type', () {
      final analyzer = SemanticAnalyzer();
      const decl = SchemaDeclaration(
        name: 'Person',
        properties: [
          PropertyDefinition(
            id: 'address',
            name: 'address',
            ranges: ['Address'], // Address is undefined
          )
        ],
      );

      analyzer.analyze([decl]);

      expect(analyzer.diagnostics.length, equals(1));
      expect(analyzer.diagnostics.first.symbol, equals('Address'));
    });
  });
}
