import 'package:test/test.dart';
import 'package:schemaz_core/schemaz_core.dart';
import 'package:schemaz_runtime/schemaz_runtime.dart';

void main() {
  group('SchemazRuntime advanced features', () {
    test('diff calculates property changes', () {
      final oldProduct = {'name': 'Laptop', 'price': 1000};
      final newProduct = {'name': 'Laptop', 'price': 1200};

      final changes = SchemazRuntime.diff(oldProduct, newProduct);

      expect(changes.containsKey('price'), isTrue);
      expect(changes['price']!['old'], equals(1000));
      expect(changes['price']!['new'], equals(1200));
    });

    test('describe formats schema descriptor', () {
      const descriptor = SchemaDescriptor(
        id: 'https://schema.org/Person',
        name: 'Person',
        properties: [
          PropertyDefinition(id: 'name', name: 'name'),
        ],
      );

      final output = SchemazRuntime.describe(descriptor);

      expect(output, contains('Schema: Person'));
      expect(output, contains('- name'));
    });
  });
}
