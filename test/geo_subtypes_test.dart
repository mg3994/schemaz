import 'package:test/test.dart';
import 'package:schemaz/schemaz.dart';

void main() {
  group('Geo Subtypes and Subtype Casting Tests', () {
    test('StandardVocabularies registers GeoCoordinates, GeoShape, GeoCircle, and Place', () {
      final registry = SchemaRegistry();
      StandardVocabularies.registerStandardSchemaOrgTypes(registry);

      final geoCircle = registry.lookupSchema('GeoCircle');
      expect(geoCircle, isNotNull);
      expect(geoCircle!.parents.length, equals(1));
      expect(geoCircle.parents.first.name, equals('GeoShape'));

      final geoShape = registry.lookupSchema('GeoShape');
      expect(geoCircle.inheritsFrom(geoShape!), isTrue);

      final place = registry.lookupSchema('Place');
      expect(place, isNotNull);
    });

    test('Evaluates GeoCircle node instantiation and subtype casting "as GeoShape"', () {
      final registry = SchemaRegistry();
      StandardVocabularies.registerStandardSchemaOrgTypes(registry);

      final source = '''
      center GeoCoordinates {
        latitude: 37.7749
        longitude: -122.4194
      }

      zone GeoCircle {
        geoMidpoint: center
        geoRadius: 5000.0
      }

      let shape = zone as GeoShape
      let radius = zone.geoRadius
      ''';

      final lexer = Lexer(source);
      final tokens = lexer.tokenize();
      final parser = Parser(tokens);
      final ast = parser.parse();

      final interpreter = SchemazInterpreter(registry: registry);
      interpreter.evaluateProgram(ast);

      final zoneNode = interpreter.globalEnv.get('zone') as Node;
      expect(zoneNode.schema.name, equals('GeoCircle'));

      final shapeVal = interpreter.globalEnv.get('shape') as Node;
      expect(shapeVal, equals(zoneNode));

      final radiusVal = interpreter.globalEnv.get('radius');
      expect(radiusVal, equals(5000.0));
    });
  });
}
