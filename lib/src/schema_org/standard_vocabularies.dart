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

    // Intangible
    final intangible = Schema(
      name: 'Intangible',
      uri: 'https://schema.org/Intangible',
      parents: [thing],
      description: 'A utility class that serves as the parent for specialized structural concepts.',
    );
    registry.registerType(intangible);

    // GeoCoordinates
    final geoCoordinates = Schema(
      name: 'GeoCoordinates',
      uri: 'https://schema.org/GeoCoordinates',
      parents: [intangible],
      description: 'The geographic coordinates of a place or event.',
    );
    geoCoordinates.addProperty(PropertyDefinition(name: 'latitude', type: PrimitiveType.float, uri: 'https://schema.org/latitude'));
    geoCoordinates.addProperty(PropertyDefinition(name: 'longitude', type: PrimitiveType.float, uri: 'https://schema.org/longitude'));
    geoCoordinates.addProperty(PropertyDefinition(name: 'elevation', type: PrimitiveType.float, uri: 'https://schema.org/elevation'));
    registry.registerType(geoCoordinates);

    // GeoShape
    final geoShape = Schema(
      name: 'GeoShape',
      uri: 'https://schema.org/GeoShape',
      parents: [intangible],
      description: 'The geographic shape of a place.',
    );
    geoShape.addProperty(PropertyDefinition(name: 'box', type: PrimitiveType.text, uri: 'https://schema.org/box'));
    geoShape.addProperty(PropertyDefinition(name: 'circle', type: PrimitiveType.text, uri: 'https://schema.org/circle'));
    geoShape.addProperty(PropertyDefinition(name: 'polygon', type: PrimitiveType.text, uri: 'https://schema.org/polygon'));
    geoShape.addProperty(PropertyDefinition(name: 'postalCode', type: PrimitiveType.text, uri: 'https://schema.org/postalCode'));
    registry.registerType(geoShape);

    // GeoCircle
    final geoCircle = Schema(
      name: 'GeoCircle',
      uri: 'https://schema.org/GeoCircle',
      parents: [geoShape],
      description: 'A GeoCircle is a GeoShape that represents a circular geographic area.',
    );
    geoCircle.addProperty(PropertyDefinition(name: 'geoMidpoint', type: geoCoordinates, uri: 'https://schema.org/geoMidpoint'));
    geoCircle.addProperty(PropertyDefinition(name: 'geoRadius', type: PrimitiveType.float, uri: 'https://schema.org/geoRadius'));
    registry.registerType(geoCircle);

    // Place
    final place = Schema(
      name: 'Place',
      uri: 'https://schema.org/Place',
      parents: [thing],
      description: 'Entities that have a somewhat fixed, physical extension.',
    );
    place.addProperty(PropertyDefinition(name: 'address', type: PrimitiveType.text, uri: 'https://schema.org/address'));
    place.addProperty(PropertyDefinition(name: 'geo', type: PrimitiveType.any, uri: 'https://schema.org/geo')); // GeoCoordinates or GeoShape
    registry.registerType(place);

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
    org.addProperty(PropertyDefinition(name: 'location', type: place, uri: 'https://schema.org/location'));

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
    event.addProperty(PropertyDefinition(name: 'location', type: place, uri: 'https://schema.org/location'));

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
