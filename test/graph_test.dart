import 'package:test/test.dart';
import 'package:schemaz/schemaz.dart';

void main() {
  group('NodeGraph & SchemaDiff Tests', () {
    test('NodeGraph manages nodes and performs schema/property queries', () {
      final registry = SchemaRegistry();
      StandardVocabularies.registerStandardSchemaOrgTypes(registry);

      final personSchema = registry.lookupSchema('Person')!;
      final orgSchema = registry.lookupSchema('Organization')!;

      final p1 = Node(id: 'person:1', schema: personSchema, properties: {'name': 'Manish'});
      final p2 = Node(id: 'person:2', schema: personSchema, properties: {'name': 'Alex'});
      final o1 = Node(id: 'org:1', schema: orgSchema, properties: {'name': 'Acme Corp'});

      final graph = NodeGraph();
      graph.addNode(p1);
      graph.addNode(p2);
      graph.addNode(o1);

      expect(graph.allNodes.length, equals(3));
      final people = graph.queryBySchema('Person');
      expect(people.length, equals(2));

      final acme = graph.queryByProperty('name', 'Acme Corp');
      expect(acme.length, equals(1));
      expect(acme.first.id, equals('org:1'));
    });

    test('SchemaDiffEngine computes property and structural diffs between nodes', () {
      final registry = SchemaRegistry();
      StandardVocabularies.registerStandardSchemaOrgTypes(registry);

      final personSchema = registry.lookupSchema('Person')!;

      final nodeA = Node(
        id: 'https://example.com/person/1',
        schema: personSchema,
        properties: {
          'name': 'Manish',
          'email': 'old@example.com',
        },
      );

      final nodeB = Node(
        id: 'https://example.com/person/1',
        schema: personSchema,
        properties: {
          'name': 'Manish',
          'email': 'new@example.com',
          'telephone': '+123456789',
        },
      );

      final diff = SchemaDiffEngine.diffNodes(nodeA, nodeB);
      expect(diff.hasChanges, isTrue);
      expect(diff.items.length, equals(2));

      final modifiedItem = diff.items.firstWhere((i) => i.path.endsWith('.email'));
      expect(modifiedItem.type, equals('modified'));
      expect(modifiedItem.oldValue, equals('old@example.com'));
      expect(modifiedItem.newValue, equals('new@example.com'));

      final addedItem = diff.items.firstWhere((i) => i.path.endsWith('.telephone'));
      expect(addedItem.type, equals('added'));
      expect(addedItem.newValue, equals('+123456789'));
    });
  });
}
