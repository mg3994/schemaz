import 'package:schemaz_core/schemaz_core.dart';

abstract class Declaration {
  final String name;
  const Declaration(this.name);
}

class SchemaDeclaration extends Declaration {
  final String? schemaUri;
  final String? supertype;
  final List<PropertyDefinition> properties;

  const SchemaDeclaration({
    required String name,
    this.schemaUri,
    this.supertype,
    this.properties = const [],
  }) : super(name);
}

class FunctionDeclaration extends Declaration {
  final String? returnType;
  final Map<String, String> parameters;

  const FunctionDeclaration({
    required String name,
    this.returnType,
    this.parameters = const {},
  }) : super(name);
}
