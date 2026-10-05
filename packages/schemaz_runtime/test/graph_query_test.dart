import 'package:test/test.dart';
import 'package:schemaz_runtime/schemaz_runtime.dart';

class TestPerson {
  final String name;
  final String city;
  TestPerson(this.name, this.city);
}

void main() {
  group('GraphQuery', () {
    test('Filters items by property predicate', () {
      final people = [
        TestPerson('Manish', 'San Francisco'),
        TestPerson('Alice', 'London'),
        TestPerson('Bob', 'San Francisco'),
      ];

      final query = GraphQuery(people);
      final sfPeople = query.whereProperty((p) => p.city, (city) => city == 'San Francisco').toList();

      expect(sfPeople.length, equals(2));
      expect(sfPeople.first.name, equals('Manish'));
    });
  });
}
