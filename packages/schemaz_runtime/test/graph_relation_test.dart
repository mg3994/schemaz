import 'package:test/test.dart';
import 'package:schemaz_core/schemaz_core.dart';
import 'package:schemaz_runtime/schemaz_runtime.dart';

void main() {
  group('GraphRelationLinker', () {
    test('Links inverse relations bidirectionally', () {
      const alumniProp = PropertyDefinition(
        id: 'alumni',
        name: 'alumni',
        inverseOf: 'alumniOf',
      );
      const alumniOfProp = PropertyDefinition(
        id: 'alumniOf',
        name: 'alumniOf',
        inverseOf: 'alumni',
      );

      final graph = SchemaGraph();
      graph.addType(const SchemaType('Org', 'Org', properties: [alumniProp]));
      graph.addType(const SchemaType('Person', 'Person', properties: [alumniOfProp]));

      final linker = GraphRelationLinker(graph);
      final orgMap = <String, dynamic>{'name': 'University'};
      final personMap = <String, dynamic>{'name': 'Manish'};

      linker.linkInverseRelation(
        source: orgMap,
        sourceProperty: 'alumni',
        target: personMap,
      );

      expect(orgMap['alumni'], equals(personMap));
      expect(personMap['alumniOf'], equals(orgMap));
    });
  });
}
