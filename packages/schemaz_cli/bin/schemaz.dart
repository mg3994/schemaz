import 'dart:convert';
import 'dart:io';
import 'package:schemaz_lexer/schemaz_lexer.dart';
import 'package:schemaz_parser/schemaz_parser.dart';
import 'package:schemaz_codegen/schemaz_codegen.dart';
import 'package:schemaz_model/schemaz_model.dart';

void main(List<String> args) {
  if (args.isEmpty) {
    print('Schemaz CLI v0.1.0');
    print('Usage: schemaz <command> [arguments]');
    print('Commands:');
    print('  compile <file.sz>               Compiles Schemaz source file to Dart (.sz.dart)');
    print('  inspect <file.sz>               Inspects schema structure and properties');
    print('  export-schema <file.sz>          Exports JSON-LD descriptor representation');
    print('  validate <file.sz> <data.json>  Validates JSON payload against schema');
    print('  doc <file.sz>                   Generates Markdown documentation for schema');
    return;
  }

  final command = args[0];
  if (command == 'compile' && args.length > 1) {
    final filePath = args[1];
    final file = File(filePath);
    if (!file.existsSync()) {
      print('Error: File $filePath not found.');
      exit(1);
    }

    final source = file.readAsStringSync();
    final declarations = _parseSource(source);
    final dartCode = DartGenerator.generate(declarations);
    final outputPath = '$filePath.dart';
    File(outputPath).writeAsStringSync(dartCode);
    print('Compiled $filePath -> $outputPath');
  } else if (command == 'inspect' && args.length > 1) {
    final filePath = args[1];
    final file = File(filePath);
    if (!file.existsSync()) {
      print('Error: File $filePath not found.');
      exit(1);
    }

    final source = file.readAsStringSync();
    final declarations = _parseSource(source);
    for (final decl in declarations) {
      if (decl is SchemaDeclaration) {
        print('Schema: ${decl.name} (${decl.schemaUri ?? "local"})');
        if (decl.supertype != null) print('  Extends: ${decl.supertype}');
        print('  Properties:');
        for (final prop in decl.properties) {
          print('    - ${prop.name}: ${prop.ranges.join(", ")} (nullable: ${prop.isNullable})');
        }
      }
    }
  } else if (command == 'doc' && args.length > 1) {
    final filePath = args[1];
    final file = File(filePath);
    if (!file.existsSync()) {
      print('Error: File $filePath not found.');
      exit(1);
    }

    final source = file.readAsStringSync();
    final declarations = _parseSource(source);
    final buffer = StringBuffer();

    buffer.writeln('# Schema Documentation');
    buffer.writeln();

    for (final decl in declarations) {
      if (decl is SchemaDeclaration) {
        buffer.writeln('## Schema `${decl.name}`');
        buffer.writeln('- **URI**: `${decl.schemaUri ?? "N/A"}`');
        if (decl.supertype != null) {
          buffer.writeln('- **Extends**: `${decl.supertype}`');
        }
        buffer.writeln();
        buffer.writeln('### Properties');
        buffer.writeln('| Property | Type | Nullable |');
        buffer.writeln('| --- | --- | --- |');
        for (final prop in decl.properties) {
          buffer.writeln('| `${prop.name}` | `${prop.ranges.join(", ")}` | `${prop.isNullable}` |');
        }
        buffer.writeln();
      }
    }

    final docPath = '$filePath.md';
    File(docPath).writeAsStringSync(buffer.toString());
    print('Generated documentation -> $docPath');
  } else if (command == 'export-schema' && args.length > 1) {
    final filePath = args[1];
    final file = File(filePath);
    if (!file.existsSync()) {
      print('Error: File $filePath not found.');
      exit(1);
    }

    final source = file.readAsStringSync();
    final declarations = _parseSource(source);
    final graph = <Map<String, dynamic>>[];

    for (final decl in declarations) {
      if (decl is SchemaDeclaration) {
        graph.add({
          '@id': decl.schemaUri ?? decl.name,
          '@type': 'rdfs:Class',
          'rdfs:label': decl.name,
          if (decl.supertype != null)
            'rdfs:subClassOf': {'@id': decl.supertype},
          'properties': decl.properties
              .map((p) => {
                    'name': p.name,
                    'isNullable': p.isNullable,
                  })
              .toList(),
        });
      }
    }

    print(const JsonEncoder.withIndent('  ').convert({'@graph': graph}));
  } else if (command == 'validate' && args.length > 2) {
    final szFilePath = args[1];
    final jsonFilePath = args[2];

    final szFile = File(szFilePath);
    final jsonFile = File(jsonFilePath);

    if (!szFile.existsSync() || !jsonFile.existsSync()) {
      print('Error: Input file(s) not found.');
      exit(1);
    }

    final declarations = _parseSource(szFile.readAsStringSync());
    final jsonData = jsonDecode(jsonFile.readAsStringSync());

    bool isValid = true;
    for (final decl in declarations) {
      if (decl is SchemaDeclaration) {
        for (final prop in decl.properties) {
          if (!prop.isNullable && (!jsonData.containsKey(prop.name) || jsonData[prop.name] == null)) {
            print('Validation Error: Missing required property "${prop.name}" for ${decl.name}');
            isValid = false;
          }
        }
      }
    }

    if (isValid) {
      print('Validation passed successfully.');
    } else {
      exit(1);
    }
  } else {
    print('Unknown command or missing arguments.');
  }
}

List<Declaration> _parseSource(String source) {
  final lexer = Lexer(source);
  final tokens = lexer.tokenize();
  final parser = Parser(tokens);
  return parser.parse();
}
