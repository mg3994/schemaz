# 03. Schema.org Vocabulary Model

## Overview
Schemaz dynamically imports Schema.org (v30.1+) standard vocabularies from official JSON-LD definitions without requiring hardcoded compiler schemas.

## Vocabulary Registry
1. `JSON-LD` parser processes `schemaorg-current-https.jsonld`.
2. Map `@graph` array into `Vocabulary` object containing `SchemaType` and `PropertyDefinition` instances.
3. Support graph querying and property inverse matching (`alumni` <-> `alumniOf`).
