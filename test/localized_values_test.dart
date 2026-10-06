import 'package:test/test.dart';
import 'package:schemaz/schemaz.dart';

void main() {
  group('Localized Values & Polymorphic Subtype Tests', () {
    test('Evaluates localized string literal syntax "Name"@en and accesses properties', () {
      final registry = SchemaRegistry();
      StandardVocabularies.registerStandardSchemaOrgTypes(registry);

      final source = '''
      let greeting = "Hello World"@en
      let text = greeting.text
      let lang = greeting.language
      ''';

      final lexer = Lexer(source);
      final tokens = lexer.tokenize();
      final parser = Parser(tokens);
      final ast = parser.parse();

      final interpreter = SchemazInterpreter(registry: registry);
      interpreter.evaluateProgram(ast);

      final greetingVal = interpreter.globalEnv.get('greeting');
      expect(greetingVal, equals(LocalizedText("Hello World", "en")));
      expect(interpreter.globalEnv.get('text'), equals("Hello World"));
      expect(interpreter.globalEnv.get('lang'), equals("en"));
    });

    test('Decodes multi-language property list and base URL context in JSON-LD', () {
      final registry = SchemaRegistry();
      StandardVocabularies.registerStandardSchemaOrgTypes(registry);

      final jsonLd = {
        "@context": {
          "name": "http://schema.org/name",
          "@base": "https://example.com/api/"
        },
        "@id": "https://example.com/person/1",
        "@type": "Person",
        "name": [
          {"@value": "Manish", "@language": "en"},
          {"@value": "मनीष", "@language": "hi"},
          {"@value": "മനീഷ്", "@language": "ml"}
        ]
      };

      final codec = JsonLdCodec(registry);
      final node = codec.decodeNode(jsonLd);

      expect(node.schema.name, equals('Person'));
      expect(node.id, equals('https://example.com/person/1'));
      expect(node.baseUrl, equals('https://example.com/api/'));

      final names = node.get('name') as List;
      expect(names.length, equals(3));
      expect(names[0], equals(LocalizedText('Manish', 'en')));
      expect(names[1], equals(LocalizedText('मनीष', 'hi')));
      expect(names[2], equals(LocalizedText('മനീഷ്', 'ml')));

      final encoded = codec.encodeNode(node);
      expect(encoded['name'], isA<List>());
      final encodedNames = encoded['name'] as List;
      expect(encodedNames[0], equals({'@value': 'Manish', '@language': 'en'}));
      expect(encodedNames[1], equals({'@value': 'मनीष', '@language': 'hi'}));
      expect(encodedNames[2], equals({'@value': 'മനീഷ്', '@language': 'ml'}));
    });

    test('Validates polymorphic subtype assignment without requiring manual casting', () {
      final registry = SchemaRegistry();
      StandardVocabularies.registerStandardSchemaOrgTypes(registry);

      final placeSchema = registry.lookupSchema('Place')!;
      final geoCircleSchema = registry.lookupSchema('GeoCircle')!;

      final circleNode = Node(
        schema: geoCircleSchema,
        properties: {'geoRadius': 100.0},
      );

      final placeNode = Node(
        schema: placeSchema,
        properties: {
          'name': LocalizedText('Central Park', 'en'),
          'geo': circleNode, // GeoCircle assigned to Place.geo
        },
      );

      final validator = SchemaValidator(registry: registry);
      final result = validator.validateNode(placeNode);

      expect(result.isValid, isTrue);

      final codec = JsonLdCodec(registry);
      final jsonLdMap = codec.encodeNode(placeNode);

      expect(jsonLdMap['name'], equals({'@value': 'Central Park', '@language': 'en'}));
      expect(jsonLdMap['geo']['@type'], equals('GeoCircle'));

      final decoded = codec.decodeNode(jsonLdMap);
      expect(decoded.get('name'), equals(LocalizedText('Central Park', 'en')));
      final decodedGeo = decoded.get('geo') as Node;
      expect(decodedGeo.schema.name, equals('GeoCircle'));
    });
  });
}
