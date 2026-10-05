import 'package:test/test.dart';
import 'package:schemaz_core/schemaz_core.dart';

void main() {
  group('LocalizedString and Subtype Matching', () {
    test('LocalizedString resolves language values with fallback', () {
      const localized = LocalizedString({
        'en': 'Hello World',
        'es': 'Hola Mundo',
      });

      expect(localized.getValue('en'), equals('Hello World'));
      expect(localized.getValue('es'), equals('Hola Mundo'));
      expect(localized.getValue('fr'), equals('Hello World')); // Default language fallback
    });

    test('LocalizedString.fromJsonLd parses JSON-LD language array', () {
      final jsonLd = [
        {'@value': 'Manish', '@language': 'en'},
        {'@value': 'मनीष', '@language': 'hi'},
        {'@value': 'മനീഷ്', '@language': 'ml'},
      ];

      final localized = LocalizedString.fromJsonLd(jsonLd);

      expect(localized.getValue('en'), equals('Manish'));
      expect(localized.getValue('hi'), equals('मनीष'));
      expect(localized.getValue('ml'), equals('മനീഷ്'));

      final outputJsonLd = localized.toJsonLd();
      expect(outputJsonLd.length, equals(3));
      expect(outputJsonLd.first['@value'], equals('Manish'));
      expect(outputJsonLd.first['@language'], equals('en'));
    });

    test('SchemaGraph handles transitive subtype matching directly', () {
      const thing = SchemaType('Thing', 'Thing');
      const place = SchemaType('Place', 'Place', supertypes: ['Thing']);
      const localBusiness = SchemaType('LocalBusiness', 'LocalBusiness', supertypes: ['Place']);

      final graph = SchemaGraph();
      graph.addType(thing);
      graph.addType(place);
      graph.addType(localBusiness);

      expect(graph.isSubtypeOf('LocalBusiness', 'Place'), isTrue);
      expect(graph.isSubtypeOf('LocalBusiness', 'Thing'), isTrue);
      expect(graph.isSubtypeOf('Place', 'LocalBusiness'), isFalse);
    });
  });
}
