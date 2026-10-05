import 'ast.dart';
import 'lexer.dart';

class Parser {
  final List<Token> tokens;
  int _current = 0;

  Parser(this.tokens);

  ProgramNode parse() {
    final statements = <ASTNode>[];
    while (!_isAtEnd()) {
      statements.add(_parseStatement());
    }
    return ProgramNode(statements);
  }

  ASTNode _parseStatement() {
    if (_match([TokenType.kwImport])) {
      return _parseImport();
    }
    if (_match([TokenType.kwSchema])) {
      return _parseSchemaDecl();
    }
    if (_match([TokenType.kwFunction])) {
      return _parseFunctionDecl();
    }
    if (_match([TokenType.kwLet])) {
      return _parseLetDecl();
    }
    if (_match([TokenType.kwReturn])) {
      final expr = _isAtEnd() || _check(TokenType.rightBrace) ? null : _parseExpression();
      return ReturnNode(expr);
    }
    if (_check(TokenType.identifier) && _peek(1).type == TokenType.identifier) {
      // Instance declaration e.g.: person Person { ... }
      return _parseInstanceDecl();
    }

    // Default to expression statement
    return _parseExpression();
  }

  ASTNode _parseImport() {
    bool isDart = false;
    if (_match([TokenType.kwDart])) {
      isDart = true;
    }
    final pathToken = _consume(TokenType.stringLiteral, 'Expected import path string.');
    return ImportNode(pathToken.value.toString(), isDart: isDart);
  }

  ASTNode _parseSchemaDecl() {
    final nameToken = _consume(TokenType.identifier, 'Expected schema name.');
    String? parentName;
    if (_match([TokenType.kwExtends])) {
      parentName = _consume(TokenType.identifier, 'Expected parent schema name.').text;
    }

    _consume(TokenType.leftBrace, 'Expected "{" before schema body.');
    final properties = <SchemaPropertyNode>[];

    while (!_check(TokenType.rightBrace) && !_isAtEnd()) {
      final propName = _consume(TokenType.identifier, 'Expected property name.').text;
      _consume(TokenType.colon, 'Expected ":" after property name.');
      final typeName = _consume(TokenType.identifier, 'Expected property type.').text;
      properties.add(SchemaPropertyNode(propName, typeName));
    }

    _consume(TokenType.rightBrace, 'Expected "}" after schema body.');
    return SchemaDeclNode(nameToken.text, properties, parentName: parentName);
  }

  ASTNode _parseInstanceDecl() {
    final instName = _consume(TokenType.identifier, 'Expected instance variable name.').text;
    final schemaName = _consume(TokenType.identifier, 'Expected schema type for instance.').text;

    _consume(TokenType.leftBrace, 'Expected "{" before instance properties.');
    final properties = <String, ExpressionNode>{};

    while (!_check(TokenType.rightBrace) && !_isAtEnd()) {
      final propName = _consume(TokenType.identifier, 'Expected property name.').text;
      _consume(TokenType.colon, 'Expected ":" after property name.');
      final valExpr = _parseExpression();
      properties[propName] = valExpr;

      _match([TokenType.comma]);
    }

    _consume(TokenType.rightBrace, 'Expected "}" after instance properties.');
    return InstanceDeclNode(instName, schemaName, properties);
  }

  ASTNode _parseFunctionDecl() {
    final fnName = _consume(TokenType.identifier, 'Expected function name.').text;
    _consume(TokenType.leftParen, 'Expected "(" after function name.');

    final params = <ParameterNode>[];
    if (!_check(TokenType.rightParen)) {
      do {
        final pName = _consume(TokenType.identifier, 'Expected parameter name.').text;
        _consume(TokenType.colon, 'Expected ":" after parameter name.');
        final pType = _consume(TokenType.identifier, 'Expected parameter type.').text;
        params.add(ParameterNode(pName, pType));
      } while (_match([TokenType.comma]));
    }
    _consume(TokenType.rightParen, 'Expected ")" after parameters.');

    String? returnType;
    if (_match([TokenType.arrow])) {
      returnType = _consume(TokenType.identifier, 'Expected return type after ->.').text;
    }

    _consume(TokenType.leftBrace, 'Expected "{" before function body.');
    final body = <ASTNode>[];
    while (!_check(TokenType.rightBrace) && !_isAtEnd()) {
      body.add(_parseStatement());
    }
    _consume(TokenType.rightBrace, 'Expected "}" after function body.');

    return FunctionDeclNode(fnName, params, returnType, body);
  }

  ASTNode _parseLetDecl() {
    final varName = _consume(TokenType.identifier, 'Expected variable name after let.').text;
    _consume(TokenType.assign, 'Expected "=" after variable name.');
    final expr = _parseExpression();
    return LetDeclNode(varName, expr);
  }

  ExpressionNode _parseExpression() {
    return _parseEquality();
  }

  ExpressionNode _parseEquality() {
    var expr = _parseComparison();

    while (_match([TokenType.equals, TokenType.notEquals])) {
      final op = _previous().text;
      final right = _parseComparison();
      expr = BinaryOpNode(expr, op, right);
    }

    return expr;
  }

  ExpressionNode _parseComparison() {
    var expr = _parseAdditive();

    while (_match([TokenType.greater, TokenType.greaterEquals, TokenType.less, TokenType.lessEquals])) {
      final op = _previous().text;
      final right = _parseAdditive();
      expr = BinaryOpNode(expr, op, right);
    }

    return expr;
  }

  ExpressionNode _parseAdditive() {
    var expr = _parseMultiplicative();

    while (_match([TokenType.plus, TokenType.minus])) {
      final op = _previous().text;
      final right = _parseMultiplicative();
      expr = BinaryOpNode(expr, op, right);
    }

    return expr;
  }

  ExpressionNode _parseMultiplicative() {
    var expr = _parseCallOrAccess();

    while (_match([TokenType.star, TokenType.slash])) {
      final op = _previous().text;
      final right = _parseCallOrAccess();
      expr = BinaryOpNode(expr, op, right);
    }

    return expr;
  }

  ExpressionNode _parseCallOrAccess() {
    var expr = _parsePrimary();

    while (true) {
      if (_match([TokenType.dot])) {
        final member = _consume(TokenType.identifier, 'Expected property or method name after "."').text;
        if (_match([TokenType.leftParen])) {
          final args = <ExpressionNode>[];
          if (!_check(TokenType.rightParen)) {
            do {
              args.add(_parseExpression());
            } while (_match([TokenType.comma]));
          }
          _consume(TokenType.rightParen, 'Expected ")" after method arguments.');
          expr = MethodCallNode(expr, member, args);
        } else {
          expr = PropertyAccessNode(expr, member);
        }
      } else if (_match([TokenType.leftParen])) {
        if (expr is IdentifierNode) {
          final args = <ExpressionNode>[];
          if (!_check(TokenType.rightParen)) {
            do {
              args.add(_parseExpression());
            } while (_match([TokenType.comma]));
          }
          _consume(TokenType.rightParen, 'Expected ")" after function arguments.');
          expr = FunctionCallNode(expr.name, args);
        } else {
          throw FormatException('Expression is not a function that can be called.');
        }
      } else {
        break;
      }
    }

    return expr;
  }

  ExpressionNode _parsePrimary() {
    if (_match([TokenType.kwTrue])) return LiteralNode(true);
    if (_match([TokenType.kwFalse])) return LiteralNode(false);
    if (_match([TokenType.kwNull])) return LiteralNode(null);

    if (_match([TokenType.stringLiteral, TokenType.numberLiteral])) {
      return LiteralNode(_previous().value);
    }

    if (_match([TokenType.identifier])) {
      return IdentifierNode(_previous().text);
    }

    if (_match([TokenType.leftParen])) {
      final expr = _parseExpression();
      _consume(TokenType.rightParen, 'Expected ")" after expression.');
      return expr;
    }

    throw FormatException('Unexpected token "${_peek().text}" at line ${_peek().line}');
  }

  bool _match(List<TokenType> types) {
    for (final type in types) {
      if (_check(type)) {
        _advance();
        return true;
      }
    }
    return false;
  }

  bool _check(TokenType type) {
    if (_isAtEnd()) return false;
    return _peek().type == type;
  }

  Token _advance() {
    if (!_isAtEnd()) _current++;
    return _previous();
  }

  bool _isAtEnd() => _peek().type == TokenType.eof;
  Token _peek([int offset = 0]) => tokens[_current + offset];
  Token _previous() => tokens[_current - 1];

  Token _consume(TokenType type, String message) {
    if (_check(type)) return _advance();
    throw FormatException('$message (Got "${_peek().text}" at line ${_peek().line}, col ${_peek().column})');
  }
}
