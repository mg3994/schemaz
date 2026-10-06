import 'schema.dart';
import 'type.dart';

/// Central registry managing all Schemaz schemas, primitive types, and vocabularies.
class SchemaRegistry {
  final Map<String, SchemazType> _types = {};
  final Map<String, String> _contexts = {};

  SchemaRegistry() {
    _registerPrimitives();
  }

  void _registerPrimitives() {
    registerType(PrimitiveType.text);
    registerType(PrimitiveType.integer);
    registerType(PrimitiveType.float);
    registerType(PrimitiveType.boolean);
    registerType(PrimitiveType.dateTime);
    registerType(PrimitiveType.any);
  }

  void registerType(SchemazType type) {
    _types[type.name] = type;
    if (type is Schema && type.uri != null) {
      _types[type.uri!] = type;
    }
  }

  void registerContext(String prefix, String url) {
    _contexts[prefix] = url;
  }

  Map<String, String> get contexts => Map.unmodifiable(_contexts);

  SchemazType? lookup(String nameOrUri) {
    if (_types.containsKey(nameOrUri)) {
      return _types[nameOrUri];
    }
    // Check if prefixed, e.g., schema:Person
    if (nameOrUri.contains(':')) {
      final parts = nameOrUri.split(':');
      final prefix = parts[0];
      final localName = parts.sublist(1).join(':');
      if (_contexts.containsKey(prefix)) {
        final fullUri = _contexts[prefix]! + localName;
        return _types[fullUri] ?? _types[localName];
      }
    }
    return null;
  }

  Schema? lookupSchema(String nameOrUri) {
    final type = lookup(nameOrUri);
    return type is Schema ? type : null;
  }

  List<Schema> get allSchemas => _types.values.whereType<Schema>().toList();
}
