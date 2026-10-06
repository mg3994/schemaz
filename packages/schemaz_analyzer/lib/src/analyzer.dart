import 'package:schemaz_core/schemaz_core.dart';
import 'package:schemaz_model/schemaz_model.dart';
import 'symbol_table.dart';

class AnalysisDiagnostic {
  final String message;
  final String? symbol;

  AnalysisDiagnostic(this.message, {this.symbol});

  @override
  String toString() => 'Diagnostic: $message ${symbol != null ? "($symbol)" : ""}';
}

class SemanticAnalyzer {
  final SymbolTable symbolTable = SymbolTable();
  final List<AnalysisDiagnostic> diagnostics = [];

  SemanticAnalyzer() {
    // Register built-in primitive types
    symbolTable.define('String', const PrimitiveType('schema:Text', 'String'));
    symbolTable.define('int', const PrimitiveType('schema:Integer', 'int'));
    symbolTable.define('double', const PrimitiveType('schema:Float', 'double'));
    symbolTable.define('bool', const PrimitiveType('schema:Boolean', 'bool'));
  }

  void analyze(List<Declaration> declarations) {
    // First pass: register all schema types
    for (final decl in declarations) {
      if (decl is SchemaDeclaration) {
        final schemaType = SchemaType(
          decl.schemaUri ?? decl.name,
          decl.name,
          supertypes: decl.supertype != null ? [decl.supertype!] : [],
          properties: decl.properties,
        );
        symbolTable.define(decl.name, schemaType);
      }
    }

    // Second pass: validate supertypes and property types
    for (final decl in declarations) {
      if (decl is SchemaDeclaration) {
        if (decl.supertype != null && !symbolTable.contains(decl.supertype!)) {
          diagnostics.add(AnalysisDiagnostic(
            'Undefined supertype',
            symbol: decl.supertype,
          ));
        }

        for (final prop in decl.properties) {
          for (final rangeType in prop.ranges) {
            if (!symbolTable.contains(rangeType)) {
              diagnostics.add(AnalysisDiagnostic(
                'Undefined property type',
                symbol: rangeType,
              ));
            }
          }
        }
      } else if (decl is FunctionDeclaration) {
        if (decl.returnType != null &&
            decl.returnType != 'void' &&
            !symbolTable.contains(decl.returnType!)) {
          diagnostics.add(AnalysisDiagnostic(
            'Undefined function return type',
            symbol: decl.returnType,
          ));
        }
      }
    }
  }
}
