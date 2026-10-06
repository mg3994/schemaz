import 'dart:convert';
import 'dart:io';
import 'package:args/args.dart';
import 'package:schemaz/schemaz.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addCommand('run')
    ..addCommand('inspect')
    ..addCommand('import')
    ..addCommand('compile')
    ..addCommand('diff');

  final results = parser.parse(arguments);

  if (results.command == null) {
    printUsage(parser);
    return;
  }

  final command = results.command!;
  final registry = SchemaRegistry();

  switch (command.name) {
    case 'run':
      if (command.rest.isEmpty) {
        print('Error: Missing file path for "run" command.');
        exit(1);
      }
      final filePath = command.rest.first;
      final file = File(filePath);
      if (!file.existsSync()) {
        print('Error: File not found at $filePath');
        exit(1);
      }
      final content = file.readAsStringSync();
      final lexer = Lexer(content);
      final tokens = lexer.tokenize();
      final p = Parser(tokens);
      final ast = p.parse();

      final interpreter = SchemazInterpreter(registry: registry);
      interpreter.evaluateProgram(ast);
      break;

    case 'inspect':
      if (command.rest.isEmpty) {
        print('Error: Missing schema name for "inspect" command.');
        exit(1);
      }
      final schemaName = command.rest.first;
      final schema = registry.lookupSchema(schemaName);
      if (schema == null) {
        print('Schema "$schemaName" not found in registry.');
      } else {
        print('Schema: ${schema.name}');
        if (schema.uri != null) print('URI: ${schema.uri}');
        if (schema.description != null) print('Description: ${schema.description}');
        print('Parents: ${schema.parents.map((p) => p.name).join(', ')}');
        print('Properties:');
        schema.properties.forEach((name, prop) {
          print('  - $name: ${prop.type.name}');
        });
      }
      break;

    case 'import':
      if (command.rest.isEmpty) {
        print('Error: Missing JSON-LD file or URL for "import" command.');
        exit(1);
      }
      final source = command.rest.first;
      final importer = SchemaOrgImporter(registry: registry);
      if (source.startsWith('http://') || source.startsWith('https://')) {
        print('Fetching schema vocabulary from $source...');
        await importer.importFromUrl(source);
      } else {
        final file = File(source);
        if (!file.existsSync()) {
          print('Error: File not found at $source');
          exit(1);
        }
        importer.importJsonLd(file.readAsStringSync());
      }
      print('Successfully imported vocabulary. Registered ${registry.allSchemas.length} schemas.');
      break;

    case 'compile':
      if (command.rest.isEmpty) {
        print('Error: Missing file path for "compile" command.');
        exit(1);
      }
      final filePath = command.rest.first;
      final file = File(filePath);
      if (!file.existsSync()) {
        print('Error: File not found at $filePath');
        exit(1);
      }
      final content = file.readAsStringSync();
      final lexer = Lexer(content);
      final tokens = lexer.tokenize();
      final p = Parser(tokens);
      final ast = p.parse();

      final analyzer = SemanticAnalyzer(registry: registry);
      analyzer.analyze(ast);

      final codegen = DartCodeGenerator();
      for (final schema in registry.allSchemas) {
        final code = codegen.generateDartClass(schema);
        print(code);
      }
      break;

    case 'diff':
      if (command.rest.length < 2) {
        print('Error: Missing two JSON-LD files for "diff" command.');
        exit(1);
      }
      final file1 = File(command.rest[0]);
      final file2 = File(command.rest[1]);
      if (!file1.existsSync() || !file2.existsSync()) {
        print('Error: One or both files not found.');
        exit(1);
      }
      final codec = JsonLdCodec(registry);
      final node1 = codec.decodeNode(jsonDecode(file1.readAsStringSync()));
      final node2 = codec.decodeNode(jsonDecode(file2.readAsStringSync()));
      final diffResult = SchemaDiffEngine.diffNodes(node1, node2);
      print(diffResult);
      break;

    default:
      printUsage(parser);
  }
}

void printUsage(ArgParser parser) {
  print('''
Schemaz CLI - Data-Driven Programming Language

Usage: schemaz <command> [arguments]

Commands:
  run <file.sz>              Execute a Schemaz program file
  inspect <SchemaName>       Inspect properties and parents of a Schema
  import <source.jsonld>     Import Schema.org JSON-LD vocabulary (URL or local path)
  compile <file.sz>          Compile Schemaz file to Dart classes (for Dart interop)
  diff <file1.json> <file2>  Compute structural or property diffs between two nodes
''');
}
