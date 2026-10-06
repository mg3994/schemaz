import 'package:test/test.dart';
import 'package:schemaz_runtime/schemaz_runtime.dart';

void main() {
  group('SchemaTransform', () {
    test('Maps source properties to target property schema', () {
      const transform = SchemaTransform({'fullName': 'name', 'mail': 'email'});
      final userMap = {'fullName': 'Manish Gautam', 'mail': 'manish@example.com', 'age': 30};

      final personMap = transform.transform(userMap);

      expect(personMap['name'], equals('Manish Gautam'));
      expect(personMap['email'], equals('manish@example.com'));
      expect(personMap['age'], equals(30));
    });
  });
}
