import 'dart:io';
import 'package:test/test.dart';

void main() {
  group('Schemaz CLI', () {
    late Directory tempDir;
    late File szFile;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('schemaz_cli_test');
      szFile = File('${tempDir.path}/person.sz');
      szFile.writeAsStringSync('''
      @schema('https://schema.org/Person')
      schema Person {
        name: String;
        email: String?;
      }
      ''');
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test('Compiles .sz file to .sz.dart', () {
      final result = Process.runSync(
        'dart',
        ['run', 'bin/schemaz.dart', 'compile', szFile.path],
        workingDirectory: Directory.current.path,
      );

      expect(result.exitCode, equals(0));
      final generatedFile = File('${szFile.path}.dart');
      expect(generatedFile.existsSync(), isTrue);
      expect(generatedFile.readAsStringSync(), contains('class Person'));
    });

    test('Inspects .sz file structure', () {
      final result = Process.runSync(
        'dart',
        ['run', 'bin/schemaz.dart', 'inspect', szFile.path],
        workingDirectory: Directory.current.path,
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), contains('Schema: Person'));
    });

    test('Exports JSON-LD descriptor representation', () {
      final result = Process.runSync(
        'dart',
        ['run', 'bin/schemaz.dart', 'export-schema', szFile.path],
        workingDirectory: Directory.current.path,
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), contains('"@graph"'));
      expect(result.stdout.toString(), contains('"https://schema.org/Person"'));
    });

    test('Validates JSON payload against .sz schema', () {
      final validJsonFile = File('${tempDir.path}/valid.json');
      validJsonFile.writeAsStringSync('{"name": "Manish"}');

      final result = Process.runSync(
        'dart',
        ['run', 'bin/schemaz.dart', 'validate', szFile.path, validJsonFile.path],
        workingDirectory: Directory.current.path,
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), contains('Validation passed successfully.'));
    });
  });
}
