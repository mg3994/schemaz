# Schemaz Schema.org Integration

Schemaz imports standard Schema.org JSON-LD vocabularies into its `SchemaRegistry`.

```bash
schemaz import https://schema.org/version/latest/schemaorg-current-https.jsonld
```

## Schema Mapping Rules
- `rdfs:Class` / `schema:Class` -> `Schema`
- `rdfs:subClassOf` -> `schema.parents`
- `rdf:Property` / `schema:Property` -> `PropertyDefinition`
- `schema:domainIncludes` -> Domain `Schema` attachment
- `schema:rangeIncludes` -> Property `SchemazType` resolution
