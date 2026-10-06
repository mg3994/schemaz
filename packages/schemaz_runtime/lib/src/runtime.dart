import 'package:schemaz_core/schemaz_core.dart';

class SchemazRuntime {
  /// Validates an object map against a SchemaDescriptor.
  static bool validate(SchemaDescriptor descriptor, Map<String, dynamic> data) {
    for (final prop in descriptor.properties) {
      if (!prop.isNullable && (!data.containsKey(prop.name) || data[prop.name] == null)) {
        return false;
      }
    }
    return true;
  }

  /// Calculates diff between two property maps.
  static Map<String, Map<String, dynamic>> diff(
      Map<String, dynamic> oldData, Map<String, dynamic> newData) {
    final changes = <String, Map<String, dynamic>>{};
    final allKeys = {...oldData.keys, ...newData.keys};

    for (final key in allKeys) {
      final oldVal = oldData[key];
      final newVal = newData[key];
      if (oldVal != newVal) {
        changes[key] = {'old': oldVal, 'new': newVal};
      }
    }

    return changes;
  }

  /// Returns textual representation of schema metadata.
  static String describe(SchemaDescriptor descriptor) {
    final buffer = StringBuffer();
    buffer.writeln('Schema: ${descriptor.name} (${descriptor.id})');
    buffer.writeln('Properties:');
    for (final prop in descriptor.properties) {
      buffer.writeln('  - ${prop.name} (nullable: ${prop.isNullable})');
    }
    return buffer.toString();
  }
}
