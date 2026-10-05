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
