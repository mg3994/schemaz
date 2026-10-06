import 'package:schemaz/schemaz.dart';

void main() {
  print("=== Schemaz and Dart Interop Example ===");

  final registry = SchemaRegistry();

  // 1. Define or import a Schema in Schemaz
  final personSchema = Schema(
    name: 'Person',
    uri: 'https://schema.org/Person',
  );
  personSchema.addProperty(PropertyDefinition(
    name: 'name',
    type: PrimitiveType.text,
  ));
  personSchema.addProperty(PropertyDefinition(
    name: 'age',
    type: PrimitiveType.integer,
  ));

  registry.registerType(personSchema);

  // 2. Transpile Schemaz Schema to Dart code
  final codegen = DartCodeGenerator();
  final generatedDartCode = codegen.generateDartClass(personSchema);
  print("\nGenerated Dart Code for Person schema:\n");
  print(generatedDartCode);

  // 3. Create a Schemaz Node directly in Dart
  final szNode = Node(
    schema: personSchema,
    properties: {
      'name': 'Manish Gautam',
      'age': 30,
    },
  );

  print("Schemaz Node JSON-LD Representation:");
  print(szNode.toJson());

  // 4. Decode JSON-LD back into Schemaz Node using JsonLdCodec
  final codec = JsonLdCodec(registry);
  final nodeFromCodec = codec.decodeNode(szNode.toJson());
  print("\nDecoded Node Name property: ${nodeFromCodec.get('name')}");
}
