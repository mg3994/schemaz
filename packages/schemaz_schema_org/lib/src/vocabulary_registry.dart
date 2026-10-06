import 'package:schemaz_core/schemaz_core.dart';

class VocabularyRegistry {
  final Map<String, SchemaType> _types = {};

  void registerAll(List<SchemaType> types) {
    for (final type in types) {
      _types[type.id] = type;
      _types[type.name] = type;
    }
  }

  SchemaType? getType(String idOrName) => _types[idOrName];

  List<SchemaType> get allTypes => _types.values.toSet().toList();
}
