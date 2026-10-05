import 'dart:io';
import 'package:test/test.dart';

void main() {
  group('Schemaz CLI', () {
    test('Compiles .sz file to .sz.dart', () {
      final tempDir = Directory.systemTemp.createTempSync('schemaz_cli_test');
      final szFile = File('${tempDir.path}/person.sz');
      szFile.writeAsStringSync('''
      @schema('https://schema.org/Person')
      schema Person {
        name: String;
      }
      ''');

      final result = Process.runSync(
        'dart',
        ['run', 'bin/schemaz.dart', 'compile', szFile.path],
        workingDirectory: Directory.current.path,
      );

      expect(result.exitCode, equals(0));
      final generatedFile = File('${szFile.path}.dart');
      expect(generatedFile.existsSync(), isTrue);
      expect(generatedFile.readAsStringSync(), contains('class Person'));

      tempDir.deleteSync(recursive: true);
    });
  });
}
