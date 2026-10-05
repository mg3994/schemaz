import 'package:test/test.dart';
import 'package:schemaz_core/schemaz_core.dart';
import 'package:schemaz_schema_org/schemaz_schema_org.dart';

void main() {
  group('VocabularyRegistry', () {
    test('Registers and queries SchemaTypes', () {
      final registry = VocabularyRegistry();
      const person = SchemaType(
        'https://schema.org/Person',
        'Person',
      );

      registry.registerAll([person]);

      expect(registry.getType('Person'), equals(person));
      expect(registry.getType('https://schema.org/Person'), equals(person));
    });
  });
}
