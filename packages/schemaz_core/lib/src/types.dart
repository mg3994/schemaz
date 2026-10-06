import 'property.dart';

/// Representation of types within Schemaz.
sealed class SchemazType {
  final String id;
  final String name;

  const SchemazType(this.id, this.name);
}

/// A standard scalar primitive type.
final class PrimitiveType extends SchemazType {
  const PrimitiveType(super.id, super.name);
}

/// A Schema-native type definition.
final class SchemaType extends SchemazType {
  final List<String> supertypes;
  final List<PropertyDefinition> properties;

  const SchemaType(
    super.id,
    super.name, {
    this.supertypes = const [],
    this.properties = const [],
  });
}

/// A surface reference to a Dart runtime type.
final class DartType extends SchemazType {
  final String packageUri;

  const DartType(
    super.id,
    super.name, {
    required this.packageUri,
  });
}
