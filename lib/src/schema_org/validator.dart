import '../core/node.dart';
import '../core/registry.dart';
import '../core/schema.dart';
import '../core/type.dart';

class ValidationError {
  final String path;
  final String message;

  ValidationError(this.path, this.message);

  @override
  String toString() => 'ValidationError at "$path": $message';
}

class ValidationResult {
  final List<ValidationError> errors;

  ValidationResult(this.errors);

  bool get isValid => errors.isEmpty;

  @override
  String toString() {
    if (isValid) return 'ValidationResult: Valid';
    return 'ValidationResult: ${errors.length} errors:\n${errors.map((e) => ' - $e').join('\n')}';
  }
}

class SchemaValidator {
  final SchemaRegistry registry;

  SchemaValidator({SchemaRegistry? registry})
      : registry = registry ?? SchemaRegistry();

  ValidationResult validateNode(Node node, {String path = ''}) {
    final errors = <ValidationError>[];
    final currentPath = path.isEmpty ? node.schema.name : path;

    for (final entry in node.schema.properties.entries) {
      final propName = entry.key;
      final propDef = entry.value;
      final val = node.get(propName);

      final fieldPath = '$currentPath.$propName';

      if (propDef.isRequired && val == null) {
        errors.add(ValidationError(fieldPath, 'Required property is missing.'));
        continue;
      }

      if (val != null) {
        _validateValueType(fieldPath, propDef.type, val, errors);
      }
    }

    return ValidationResult(errors);
  }

  void _validateValueType(String path, SchemazType expectedType, dynamic value, List<ValidationError> errors) {
    if (expectedType == PrimitiveType.any) return;

    if (expectedType == PrimitiveType.text) {
      if (value is! String && value is! LocalizedText) {
        errors.add(ValidationError(path, 'Expected String or LocalizedText, got ${value.runtimeType}'));
      }
    } else if (expectedType == PrimitiveType.localizedText) {
      if (value is! LocalizedText && value is! String) {
        errors.add(ValidationError(path, 'Expected LocalizedText or String, got ${value.runtimeType}'));
      }
    } else if (expectedType == PrimitiveType.integer && value is! int) {
      errors.add(ValidationError(path, 'Expected Integer, got ${value.runtimeType}'));
    } else if (expectedType == PrimitiveType.float && value is! double && value is! int) {
      errors.add(ValidationError(path, 'Expected Float, got ${value.runtimeType}'));
    } else if (expectedType == PrimitiveType.boolean && value is! bool) {
      errors.add(ValidationError(path, 'Expected Boolean, got ${value.runtimeType}'));
    } else if (expectedType is Schema) {
      if (value is Node) {
        if (!value.schema.inheritsFrom(expectedType)) {
          errors.add(ValidationError(path, 'Node schema ${value.schema.name} is not a valid subtype of ${expectedType.name}'));
        } else {
          final nestedResult = validateNode(value, path: path);
          errors.addAll(nestedResult.errors);
        }
      } else {
        errors.add(ValidationError(path, 'Expected Node of type or subtype of ${expectedType.name}, got ${value.runtimeType}'));
      }
    } else if (expectedType is ListType) {
      if (value is List) {
        for (int i = 0; i < value.length; i++) {
          _validateValueType('$path[$i]', expectedType.elementType, value[i], errors);
        }
      } else {
        _validateValueType(path, expectedType.elementType, value, errors);
      }
    }
  }
}
