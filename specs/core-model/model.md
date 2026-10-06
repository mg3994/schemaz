# Schemaz Core Model Specification

Schemaz is a data-driven programming language where all constructs (data, types, schemas, functions, modules) are inspectable nodes.

## Fundamental Primitives

1. **SchemazType**
   - `PrimitiveType`: Text, Integer, Float, Boolean, DateTime, Any
   - `ListType<T>`: Heterogeneous or homogenous list of types
   - `MapType<K, V>`: Key-value mapped schema types

2. **Schema**
   - Contains property definitions (`PropertyDefinition`), parental inheritances (`parents`), URI annotations, and documentation comments.

3. **Node**
   - The fundamental runtime object representing instantiated data bound to a `Schema`.
   - Serializes natively to standard JSON-LD with `@context`, `@type`, and `@id`.
