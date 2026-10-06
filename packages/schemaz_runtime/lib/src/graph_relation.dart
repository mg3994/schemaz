import 'package:schemaz_core/schemaz_core.dart';

class GraphRelationLinker {
  final SchemaGraph schemaGraph;

  GraphRelationLinker(this.schemaGraph);

  /// Automatically connects inverse properties between two object maps.
  void linkInverseRelation({
    required Map<String, dynamic> source,
    required String sourceProperty,
    required Map<String, dynamic> target,
  }) {
    final propDef = PropertyDefinition(id: sourceProperty, name: sourceProperty, inverseOf: null);
    final inverseProp = schemaGraph.getInverseProperty(propDef);

    source[sourceProperty] = target;
    if (inverseProp != null) {
      target[inverseProp.name] = source;
    }
  }
}
