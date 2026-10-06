# Schemaz Examples

This directory contains sample `.sz` files demonstrating Schemaz syntax, annotations, and generated Dart interoperability.

## Example Files
- `person.sz`: Example Person schema with optional email property and function.
- `product.sz`: Example Product schema with price calculation function.

## Compiling Examples
To compile an example to Dart using `schemaz_cli`:

```bash
cd packages/schemaz_cli
dart run bin/schemaz.dart compile ../../examples/person.sz
```
