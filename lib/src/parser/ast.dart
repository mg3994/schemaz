abstract class ASTNode {}

class ProgramNode extends ASTNode {
  final List<ASTNode> statements;
  ProgramNode(this.statements);
}

class ImportNode extends ASTNode {
  final String path;
  final bool isDart;
  ImportNode(this.path, {this.isDart = false});
}

class SchemaPropertyNode extends ASTNode {
  final String name;
  final String typeName;
  final bool isRequired;
  SchemaPropertyNode(this.name, this.typeName, {this.isRequired = false});
}

class SchemaDeclNode extends ASTNode {
  final String name;
  final String? parentName;
  final List<SchemaPropertyNode> properties;
  SchemaDeclNode(this.name, this.properties, {this.parentName});
}

class InstanceDeclNode extends ASTNode {
  final String name;
  final String schemaName;
  final Map<String, ExpressionNode> properties;
  InstanceDeclNode(this.name, this.schemaName, this.properties);
}

class ParameterNode extends ASTNode {
  final String name;
  final String typeName;
  ParameterNode(this.name, this.typeName);
}

class FunctionDeclNode extends ASTNode {
  final String name;
  final List<ParameterNode> parameters;
  final String? returnTypeName;
  final List<ASTNode> body;
  FunctionDeclNode(this.name, this.parameters, this.returnTypeName, this.body);
}

class LetDeclNode extends ASTNode {
  final String name;
  final ExpressionNode initializer;
  LetDeclNode(this.name, this.initializer);
}

class ReturnNode extends ASTNode {
  final ExpressionNode? expression;
  ReturnNode(this.expression);
}

abstract class ExpressionNode extends ASTNode {}

class LiteralNode extends ExpressionNode {
  final dynamic value;
  LiteralNode(this.value);
}

class IdentifierNode extends ExpressionNode {
  final String name;
  IdentifierNode(this.name);
}

class BinaryOpNode extends ExpressionNode {
  final ExpressionNode left;
  final String operator;
  final ExpressionNode right;
  BinaryOpNode(this.left, this.operator, this.right);
}

class PropertyAccessNode extends ExpressionNode {
  final ExpressionNode target;
  final String propertyName;
  PropertyAccessNode(this.target, this.propertyName);
}

class FunctionCallNode extends ExpressionNode {
  final String callee;
  final List<ExpressionNode> arguments;
  FunctionCallNode(this.callee, this.arguments);
}

class MethodCallNode extends ExpressionNode {
  final ExpressionNode target;
  final String methodName;
  final List<ExpressionNode> arguments;
  MethodCallNode(this.target, this.methodName, this.arguments);
}

class MapLiteralNode extends ExpressionNode {
  final Map<String, ExpressionNode> entries;
  MapLiteralNode(this.entries);
}

class ListLiteralNode extends ExpressionNode {
  final List<ExpressionNode> elements;
  ListLiteralNode(this.elements);
}
