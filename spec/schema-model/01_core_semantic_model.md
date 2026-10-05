# 01. Core Semantic Model

## Overview
The Schemaz core semantic model forms the foundational AST and runtime model representing data, types, properties, relationships, and meta-schemas.

## Core Primitives

### 1. Identifier
Represents a global URI or local symbol.
- `uri`: String? (e.g. `https://schema.org/Person`)
- `name`: String (e.g. `Person`)

### 2. Types (`SchemazType`)
Sealed hierarchy representing type kinds:
- `PrimitiveType`: `String`, `int`, `double`, `bool`, `DateTime`
- `SchemaType`: User-defined or imported Schema.org type with properties, supertypes, and metadata.
- `DartType`: Surface representation of a Dart class/interface (`package:path/to/lib.dart#ClassName`).

### 3. Property Definition (`PropertyDefinition`)
- `id`: String (URI or identifier)
- `name`: String
- `domains`: List<String>
- `ranges`: List<String>
- `inverseOf`: String?
- `isNullable`: bool

### 4. Schema Descriptor (`SchemaDescriptor`)
Introspection object available at runtime via `.schema`:
- `id`: String
- `name`: String
- `properties`: List<PropertyDescriptor>
