import 'package:test/test.dart';
import 'package:schemaz_core/schemaz_core.dart';
import 'package:schemaz_runtime/schemaz_runtime.dart';

void main() {
  group('SchemazRuntime', () {
    test('Validates required fields against SchemaDescriptor', () {
      const descriptor = SchemaDescriptor(
        id: 'https://schema.org/Person',
        name: 'Person',
        properties: [
          PropertyDefinition(
            id: 'name',
            name: 'name',
            isNullable: false,
          ),
          PropertyDefinition(
            id: 'email',
            name: 'email',
            isNullable: true,
          ),
        ],
      );

      final validData = {'name': 'Manish'};
      final invalidData = {'email': 'test@example.com'};

      expect(SchemazRuntime.validate(descriptor, validData), isTrue);
      expect(SchemazRuntime.validate(descriptor, invalidData), isFalse);
    });
  });
}
