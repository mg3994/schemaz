import '../core/registry.dart';
import '../core/schema.dart';
import '../core/type.dart';

/// Preloads core Schema.org standard vocabulary types into the registry
class StandardVocabularies {
  static void registerStandardSchemaOrgTypes(SchemaRegistry registry) {
    // Thing
    final thing = Schema(
      name: 'Thing',
      uri: 'https://schema.org/Thing',
      description: 'The most generic type of item.',
    );
    thing.addProperty(PropertyDefinition(name: 'name', type: PrimitiveType.text, uri: 'https://schema.org/name'));
    thing.addProperty(PropertyDefinition(name: 'description', type: PrimitiveType.text, uri: 'https://schema.org/description'));
    thing.addProperty(PropertyDefinition(name: 'url', type: PrimitiveType.text, uri: 'https://schema.org/url'));

    registry.registerType(thing);

    // Person
    final person = Schema(
      name: 'Person',
      uri: 'https://schema.org/Person',
      parents: [thing],
      description: 'A person (alive, dead, undead, or fictional).',
    );
    person.addProperty(PropertyDefinition(name: 'givenName', type: PrimitiveType.text, uri: 'https://schema.org/givenName'));
    person.addProperty(PropertyDefinition(name: 'familyName', type: PrimitiveType.text, uri: 'https://schema.org/familyName'));
    person.addProperty(PropertyDefinition(name: 'email', type: PrimitiveType.text, uri: 'https://schema.org/email'));
    person.addProperty(PropertyDefinition(name: 'telephone', type: PrimitiveType.text, uri: 'https://schema.org/telephone'));

    registry.registerType(person);

    // Organization
    final org = Schema(
      name: 'Organization',
      uri: 'https://schema.org/Organization',
      parents: [thing],
      description: 'An organization such as a school, NGO, corporation, club, etc.',
    );
    org.addProperty(PropertyDefinition(name: 'legalName', type: PrimitiveType.text, uri: 'https://schema.org/legalName'));
    org.addProperty(PropertyDefinition(name: 'email', type: PrimitiveType.text, uri: 'https://schema.org/email'));

    registry.registerType(org);

    // Event
    final event = Schema(
      name: 'Event',
      uri: 'https://schema.org/Event',
      parents: [thing],
      description: 'An event happening at a certain time and location.',
    );
    event.addProperty(PropertyDefinition(name: 'startDate', type: PrimitiveType.dateTime, uri: 'https://schema.org/startDate'));
    event.addProperty(PropertyDefinition(name: 'endDate', type: PrimitiveType.dateTime, uri: 'https://schema.org/endDate'));
    event.addProperty(PropertyDefinition(name: 'organizer', type: org, uri: 'https://schema.org/organizer'));

    registry.registerType(event);

    // Product
    final product = Schema(
      name: 'Product',
      uri: 'https://schema.org/Product',
      parents: [thing],
      description: 'Any offered product or service.',
    );
    product.addProperty(PropertyDefinition(name: 'sku', type: PrimitiveType.text, uri: 'https://schema.org/sku'));
    product.addProperty(PropertyDefinition(name: 'price', type: PrimitiveType.float, uri: 'https://schema.org/price'));

    registry.registerType(product);
  }
}
