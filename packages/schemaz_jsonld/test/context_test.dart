import 'package:test/test.dart';
import 'package:schemaz_jsonld/schemaz_jsonld.dart';

void main() {
  group('JsonLdContext', () {
    test('Expands relative terms using @vocab or context maps', () {
      final context = JsonLdContext.fromJson({
        '@vocab': 'https://schema.org/',
        'name': 'http://schema.org/name',
      });

      expect(context.expandTerm('name'), equals('http://schema.org/name'));
      expect(context.expandTerm('Person'), equals('https://schema.org/Person'));
    });
  });
}
