# 02. Dart ↔ Schemaz Interoperability Model

## Principles
1. Schemaz compiles to idiomatic Dart 3.x code.
2. Dart and Schemaz share the exact same runtime ABI and memory layout.

## Interop Rules

### From Schemaz to Dart
- A `schema Person { name: String }` generates `class Person` in Dart.
- Fields generate final properties with constructor arguments.
- Schema metadata is attached via static getters and methods (e.g. `Person.schema`).

### From Dart to Schemaz
- Schemaz can import standard Dart files (`import 'package:foo/bar.dart'`).
- The Dart analyzer models the public surface area of Dart packages.
- Dart types without `@schema` annotations are wrapped in `DartType` surface nodes in the symbol table.
