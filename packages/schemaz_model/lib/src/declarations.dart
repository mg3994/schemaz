import 'package:schemaz_core/schemaz_core.dart';
import 'source_location.dart';

abstract class Declaration {
  final String name;
  final SourceLocation? location;

  const Declaration(this.name, {this.location});
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
    SourceLocation? location,
  }) : super(name, location: location);
}

class FunctionDeclaration extends Declaration {
  final String? returnType;
  final Map<String, String> parameters;

  const FunctionDeclaration({
    required String name,
    this.returnType,
    this.parameters = const {},
    SourceLocation? location,
  }) : super(name, location: location);
}
