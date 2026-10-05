# SCHEMAZ LANGUAGE SPECIFICATION v0.1

> **Schemaz is a Dart-compatible programming language whose type system and data model are deeply integrated with Schema.org.**

---

## Overview

Schemaz is designed around a fundamental architecture where schemas, types, and data share a common semantic representation. It is not merely a DSL or a JSON-LD parser; it is a statically typed, null-safe language targeting Dart, seamlessly coexisting in Dart projects while enriching Dart's programming model with Schema.org semantic metadata and graph capabilities.

---

## 1. Core Semantic Model

The kernel of Schemaz is built upon small, abstract primitives that represent both programming declarations and semantic metadata:

- **Identifier**: Uniform Resource Identifiers (URIs) or local names uniquely identifying types, properties, and symbols.
- **Value**: Primitive runtime constants or object instances.
- **Type**:
  - `DartType`: References Dart runtime surface classes (e.g. `String`, `int`, `Future<T>`, `package:custom/Type`).
  - `SchemaType`: Semantic type definitions containing properties, supertypes, and vocabulary associations.
  - `PrimitiveType`: Basic scalar primitives (`String`, `int`, `double`, `bool`, `DateTime`).
- **Property**: Declarations defining name, domains, ranges, inverse relationships (`inverseOf`), and nullability/cardinality.
- **Relation**: Direct semantic relationships (e.g. inverse property linking `alumni` and `alumniOf`).
- **Schema**: An aggregated collection of properties, constraints, metadata, and vocabulary identities.
- **Expression**: Executable constructs within Schemaz functions and pipelines.
- **Declaration**: Top-level language definitions (`schema`, `fn`, `let`, `import`).

### Introspection Primitive
Every Schemaz type exposes `.schema`, yielding a `SchemaDescriptor`:
```schemaz
final descriptor = Person.schema;
print(descriptor.name);
for (final prop in descriptor.properties) {
    print(prop.name);
}
```

---

## 2. Dart ↔ Schemaz Interoperability Model

Schemaz compiles directly to ordinary Dart code (`.sz` -> `.sz.dart`). There is no separate VM required.

### Interoperability Contract

#### Schemaz MUST be able to:
1. Import standard and package Dart libraries (`import 'package:foo/bar.dart';`).
2. Instantiate Dart classes natively.
3. Extend/implement supported Dart types.
4. Call Dart methods/functions without reflection wrappers or RPC.
5. Read/write Dart properties.
6. Support Dart generic types and async features (`Future`, `Stream`).
7. Expose Schemaz types and functions back to Dart seamlessly.

#### Dart MUST be able to:
1. Import generated Schemaz libraries (`import 'package:app/models/person.sz.dart';`).
2. Instantiate Schemaz types using standard Dart constructors.
3. Call Schemaz functions directly.
4. Access intrinsic Schema metadata via `.schema` or generated descriptors.

### Multi-Supertypes & Dart Inheritance
Schema.org allows multiple inheritance (e.g., `LocalBusiness` inherits from both `Organization` and `Place`). Schemaz distinguishes **semantic extension** from **Dart implementation inheritance**:
- Dart single-class inheritance is preserved for the primary supertype.
- Additional supertypes are generated as Dart `abstract interface class`es / mixins to maintain clean Dart ABI.

---

## 3. Schema.org Vocabulary Model

Schema.org is loaded dynamically as a vocabulary model rather than hardcoded into compiler internals.

### Vocabulary Architecture
```text
Schema.org JSON-LD (e.g., release 30.1)
          │
          ▼
   JSON-LD Parser
          │
          ▼
  Schemaz Vocabulary Model
          │
          ▼
  Schema Registry
```

### Vocabulary Mapping
- `rdfs:Class` / `schema:Type` -> `SchemaType`
- `rdf:Property` -> `PropertyDefinition`
- `schema:domainIncludes` -> `domains`
- `schema:rangeIncludes` -> `ranges`
- `schema:inverseOf` -> `inverseOf`

Schema.org constraints (such as `rangeIncludes`) remain semantic rules separate from Dart constructor nullability/typing.

---

## 4. Schemaz Grammar v0.1

### Top-Level Declarations

```antlr
CompilationUnit ::= ImportDirective* Declaration*

ImportDirective ::= 'import' StringLiteral ';'

Declaration ::= SchemaDeclaration | FunctionDeclaration | LetDeclaration

SchemaDeclaration ::= '@schema' '(' StringLiteral ')'? 'schema' Identifier ('extends' Identifier)? '{' PropertyDeclaration* '}'

PropertyDeclaration ::= Identifier ':' TypeAnnotation ('?')? ';'

FunctionDeclaration ::= 'fn' Identifier '(' ParameterList ')' ('->' TypeAnnotation)? Block

ParameterList ::= (Parameter (',' Parameter)*)?
Parameter ::= TypeAnnotation Identifier

TypeAnnotation ::= Identifier ('<' TypeAnnotation '>')?

Block ::= '{' Statement* '}'
```

### Example

```schemaz
import 'schema:org';
import 'package:shop/payment_service.dart';

@schema('https://schema.org/Person')
schema Person {
    name: String;
    email: String?;
}

fn greet(Person person) -> String {
    return 'Hello ${person.name}';
}
```

---

## Detailed Specifications
Detailed modular specifications are located in the `spec/` directory:
- `spec/schema-model/01_core_semantic_model.md`
- `spec/interop/02_dart_schemaz_interop.md`
- `spec/schema-org/03_schema_org_vocabulary.md`
- `spec/grammar/04_schemaz_grammar.md`
