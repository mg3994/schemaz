# Schemaz

> **A data-driven programming language built around schemas, semantic graphs, and Schema.org interoperability.**

Schemaz is a programming language designed from scratch around one fundamental idea: **everything in Schemaz is describable as data**.

Instead of traditional class hierarchies, Schemaz uses schemas as the core representation for data, types, relationships, reflection, and behavior. Schema.org serves as a standard vocabulary rather than a restrictive language specification.

---

## Key Features

- **Schema-First Data Model**: Built-in primitives (`Text`, `Integer`, `Float`, `Boolean`, `DateTime`, `LocalizedText`, `List<T>`, `Map<K, V>`, `Any`).
- **Schema.org Integration**: Import JSON-LD vocabularies (`@context`, `@graph`, `rdfs:subClassOf`, `schema:domainIncludes`, `schema:rangeIncludes`).
- **Polymorphic Subtypes**: Usable directly as values without manual wrapper conversions (e.g., `GeoCoordinates`, `GeoCircle`, `GeoShape`, `Place`).
- **Multi-Language & Localized Text**: Express localized string representations (`"Name"@en`, `"नाम"@hi`) and multi-language property arrays (`["Name"@en, "नाम"@hi]`).
- **Kotlin/Java Style Dart Interoperability**: Transpile Schemaz schemas directly into strongly typed Dart classes equipped with `fromNode` and `toNode` methods.
- **Semantic Graphs & Diffing**: Query semantic node graphs (`NodeGraph`) and compute property/structural diffs (`SchemaDiffEngine`).

---

## Schemaz Syntax Example

```schemaz
schema Person {
    name: Text
    age: Integer
    email: Text
}

person Person {
    name: "Manish Gautam"
    age: 30
    email: "manish@example.com"
}

function introduce(p: Person) -> Text {
    return "Hi, my name is " + p.name + " and I am " + p.age.toString() + " years old."
}

let intro = introduce(person)
print(intro)
```

### Localized Text & Subtypes

```schemaz
center GeoCoordinates {
    latitude: 37.7749
    longitude: -122.4194
}

parkZone GeoCircle {
    geoMidpoint: center
    geoRadius: 1500.0
}

centralPark Place {
    name: ["Central Park"@en, "सेंट्रल पार्क"@hi, "സെൻട്രൽ പാർക്ക്"@ml]
    address: "New York, NY"
    geo: parkZone
}
```

---

## CLI Usage

```bash
# Run a Schemaz script
schemaz run example/example.sz

# Inspect a schema structure
schemaz inspect Person

# Import Schema.org JSON-LD vocabulary
schemaz import https://schema.org/version/latest/schemaorg-current-https.jsonld

# Compile Schemaz schema to Dart code
schemaz compile example/example.sz

# Diff two JSON-LD nodes
schemaz diff node1.json node2.json
```

---

## Dart Interoperability Example

```dart
import 'package:schemaz/schemaz.dart';

void main() {
  final registry = SchemaRegistry();
  StandardVocabularies.registerStandardSchemaOrgTypes(registry);

  final personSchema = registry.lookupSchema('Person')!;

  final codegen = DartCodeGenerator();
  final dartClassCode = codegen.generateDartClass(personSchema);
  print(dartClassCode);
}
```

---

## Running Tests

```bash
dart test
```
