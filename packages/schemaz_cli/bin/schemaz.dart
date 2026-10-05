import 'dart:io';
import 'package:schemaz_lexer/schemaz_lexer.dart';
import 'package:schemaz_parser/schemaz_parser.dart';
import 'package:schemaz_codegen/schemaz_codegen.dart';
import 'package:schemaz_model/schemaz_model.dart';
import 'package:schemaz_runtime/schemaz_runtime.dart';

void main(List<String> args) {
  if (args.isEmpty) {
    print('Schemaz CLI v0.1.0');
    print('Usage: schemaz <command> [arguments]');
    print('Commands:');
    print('  compile <file.sz>   Compiles Schemaz source file to Dart (.sz.dart)');
    print('  inspect <file.sz>   Inspects schema structure and properties');
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
