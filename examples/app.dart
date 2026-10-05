import 'package:schemaz_core/schemaz_core.dart';
import 'person.sz.dart';
import 'product.sz.dart';
import 'localized_person.sz.dart';

void main() {
  print('--- Schemaz Mixed Dart App ---');

  // 1. Instantiate Schemaz types directly in Dart
  const person = Person(
    name: 'Manish Gautam',
    email: 'manish@example.com',
  );

  const product = Product(
    name: 'Schemaz Workstation',
    price: 4999.0,
  );

  const localizedPerson = LocalizedPerson(
    name: LocalizedString({'en': 'Manish Gautam', 'hi': 'मनीष गौतम'}),
  );

  print('Person: ${person.name} (${person.email})');
  print('Product: ${product.name} @ \$${product.price}');
  print('Localized Person Name (English): ${localizedPerson.name.getValue("en")}');
  print('Localized Person Name (Hindi): ${localizedPerson.name.getValue("hi")}');

  // 2. Call static schema descriptors
  print('\nSchema Descriptor: ${Person.schema.name} (${Person.schema.id})');

  // 3. Serialize to JSON-LD
  print('\nJSON-LD Representation:');
  print(person.toJsonLd());
  print(product.toJsonLd());
  print(localizedPerson.toJsonLd());
}
