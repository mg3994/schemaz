import 'package:schemaz_core/schemaz_core.dart';

class SchemazRuntime {
  /// Validates an object against its SchemaDescriptor constraints.
  static bool validate(SchemaDescriptor descriptor, Map<String, dynamic> data) {
    for (final prop in descriptor.properties) {
      if (!prop.isNullable && (!data.containsKey(prop.name) || data[prop.name] == null)) {
        return false;
      }
    }
    return true;
  }
}
