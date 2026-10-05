import '../core/registry.dart';
import '../core/schema.dart';
import '../core/type.dart';
import '../parser/ast.dart';

/// Semantic Analyzer that converts parsed AST into verified Schemaz Semantic Models & Registries.
class SemanticAnalyzer {
  final SchemaRegistry registry;

  SemanticAnalyzer({SchemaRegistry? registry})
      : registry = registry ?? SchemaRegistry();

  void analyze(ProgramNode program) {
    // Pass 1: Declare all Schemas
    for (final stmt in program.statements) {
      if (stmt is SchemaDeclNode) {
        final schema = Schema(
          name: stmt.name,
          parents: stmt.parentName != null ? [] : [],
        );
        registry.registerType(schema);
      }
    }

    // Pass 2: Link Parents and Properties for Schemas
    for (final stmt in program.statements) {
      if (stmt is SchemaDeclNode) {
        final schema = registry.lookupSchema(stmt.name)!;
        if (stmt.parentName != null) {
          final parent = registry.lookupSchema(stmt.parentName!);
          if (parent != null) {
            schema.parents.add(parent);
          } else {
            throw FormatException('Unknown parent schema "${stmt.parentName}" for "${stmt.name}"');
          }
        }

        for (final prop in stmt.properties) {
          final propType = registry.lookup(prop.typeName) ?? PrimitiveType.any;
          schema.addProperty(PropertyDefinition(
            name: prop.name,
            type: propType,
            isRequired: prop.isRequired,
          ));
        }
      }
    }
  }
}
