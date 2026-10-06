import 'package:test/test.dart';
import 'package:schemaz_core/schemaz_core.dart';
import 'package:schemaz_model/schemaz_model.dart';
import 'package:schemaz_codegen/schemaz_codegen.dart';

void main() {
  group('DartGenerator capabilities', () {
    test('Generates toJson, fromJson, and toJsonLd methods', () {
      const decl = SchemaDeclaration(
        name: 'Product',
        schemaUri: 'https://schema.org/Product',
        properties: [
          PropertyDefinition(
            id: 'name',
            name: 'name',
            ranges: ['String'],
            isNullable: false,
          ),
          PropertyDefinition(
            id: 'price',
            name: 'price',
            ranges: ['double'],
            isNullable: false,
          ),
        ],
      );

      final code = DartGenerator.generate([decl]);

      expect(code, contains('Map<String, dynamic> toJson()'));
      expect(code, contains('Map<String, dynamic> toJsonLd({Object? context})'));
      expect(code, contains('factory Product.fromJson'));
      expect(code, contains('"@type": "Product"'));
    });
  });
}
