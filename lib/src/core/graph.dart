import 'node.dart';
import 'schema.dart';

class SchemaDiffItem {
  final String path;
  final String type; // 'added', 'removed', 'modified'
  final dynamic oldValue;
  final dynamic newValue;

  SchemaDiffItem({
    required this.path,
    required this.type,
    this.oldValue,
    this.newValue,
  });

  @override
  String toString() => 'DiffItem($type at "$path": old=$oldValue, new=$newValue)';
}

class SchemaDiffResult {
  final List<SchemaDiffItem> items;

  SchemaDiffResult(this.items);

  bool get hasChanges => items.isNotEmpty;

  @override
  String toString() {
    if (!hasChanges) return 'No diffs detected.';
    return 'Diff Result:\n' + items.map((i) => ' - $i').join('\n');
  }
}

class SchemaDiffEngine {
  static SchemaDiffResult diffNodes(Node nodeA, Node nodeB, {String path = ''}) {
    final diffs = <SchemaDiffItem>[];
    final currentPath = path.isEmpty ? (nodeA.id ?? nodeA.schema.name) : path;

    if (nodeA.schema.name != nodeB.schema.name) {
      diffs.add(SchemaDiffItem(
        path: '$currentPath.@type',
        type: 'modified',
        oldValue: nodeA.schema.name,
        newValue: nodeB.schema.name,
      ));
    }

    final allKeys = {...nodeA.properties.keys, ...nodeB.properties.keys};

    for (final key in allKeys) {
      final keyPath = '$currentPath.$key';
      final valA = nodeA.get(key);
      final valB = nodeB.get(key);

      if (valA != null && valB == null) {
        diffs.add(SchemaDiffItem(path: keyPath, type: 'removed', oldValue: valA));
      } else if (valA == null && valB != null) {
        diffs.add(SchemaDiffItem(path: keyPath, type: 'added', newValue: valB));
      } else if (valA != null && valB != null) {
        if (valA is Node && valB is Node) {
          final nested = diffNodes(valA, valB, path: keyPath);
          diffs.addAll(nested.items);
        } else if (valA != valB) {
          diffs.add(SchemaDiffItem(
            path: keyPath,
            type: 'modified',
            oldValue: valA,
            newValue: valB,
          ));
        }
      }
    }

    return SchemaDiffResult(diffs);
  }
}

class NodeGraph {
  final Map<String, Node> _nodes = {};

  void addNode(Node node) {
    final key = node.id ?? 'node_${_nodes.length + 1}';
    _nodes[key] = node;
  }

  Node? getNode(String id) => _nodes[id];

  List<Node> get allNodes => _nodes.values.toList();

  List<Node> queryBySchema(String schemaName) {
    return _nodes.values.where((n) => n.schema.name == schemaName || n.schema.inheritsFrom(Schema(name: schemaName))).toList();
  }

  List<Node> queryByProperty(String propertyName, dynamic expectedValue) {
    return _nodes.values.where((n) {
      final val = n.get(propertyName);
      return val == expectedValue;
    }).toList();
  }
}
