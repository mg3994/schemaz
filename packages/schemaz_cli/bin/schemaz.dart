import 'dart:io';
import 'package:schemaz_lexer/schemaz_lexer.dart';
import 'package:schemaz_parser/schemaz_parser.dart';
import 'package:schemaz_codegen/schemaz_codegen.dart';

void main(List<String> args) {
  if (args.isEmpty) {
    print('Schemaz CLI v0.1.0');
    print('Usage: schemaz <command> [arguments]');
    print('Commands:');
    print('  compile <file.sz>   Compiles Schemaz source file to Dart (.sz.dart)');
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
    final lexer = Lexer(source);
    final tokens = lexer.tokenize();
    final parser = Parser(tokens);
    final declarations = parser.parse();

    final dartCode = DartGenerator.generate(declarations);
    final outputPath = '$filePath.dart';
    File(outputPath).writeAsStringSync(dartCode);
    print('Compiled $filePath -> $outputPath');
  } else {
    print('Unknown command or missing arguments.');
  }
}
