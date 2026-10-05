import 'package:schemaz_core/schemaz_core.dart';
import 'package:schemaz_lexer/schemaz_lexer.dart';
import 'package:schemaz_model/schemaz_model.dart';

class Parser {
  final List<Token> tokens;
  int _current = 0;

  Parser(this.tokens);

  List<Declaration> parse() {
    final declarations = <Declaration>[];
    while (!_isAtEnd()) {
      if (_match([TokenType.importKw])) {
        _parseImport();
      } else {
        final decl = _parseDeclaration();
        if (decl != null) {
          declarations.add(decl);
        }
      }
    }
    return declarations;
  }

  void _parseImport() {
    _consume(TokenType.stringLiteral, 'Expected string literal after import');
    _consume(TokenType.semicolon, 'Expected ";" after import statement');
  }

  Declaration? _parseDeclaration() {
    String? schemaUri;
    if (_match([TokenType.at])) {
      if (_check(TokenType.identifier) || _check(TokenType.schemaKw)) {
        _advance();
      } else {
        throw FormatException('Expected annotation name after @');
      }

      if (_match([TokenType.openParen])) {
        final uriToken = _consume(
            TokenType.stringLiteral, 'Expected string literal in annotation');
        schemaUri = uriToken.lexeme;
        _consume(
            TokenType.closeParen, 'Expected ")" after annotation argument');
      }
    }

    if (_match([TokenType.schemaKw])) {
      return _parseSchemaDeclaration(schemaUri);
    } else if (_match([TokenType.fnKw])) {
      return _parseFunctionDeclaration();
    }

    _advance(); // Skip unknown/unsupported token
    return null;
  }

  SchemaDeclaration _parseSchemaDeclaration(String? schemaUri) {
    final nameToken =
        _consume(TokenType.identifier, 'Expected schema name identifier');
    String? supertype;

    if (_match([TokenType.extendsKw])) {
      final superToken =
          _consume(TokenType.identifier, 'Expected supertype identifier');
      supertype = superToken.lexeme;
    }

    _consume(TokenType.openBrace, 'Expected "{" before schema body');

    final properties = <PropertyDefinition>[];
    while (!_check(TokenType.closeBrace) && !_isAtEnd()) {
      final propNameToken =
          _consume(TokenType.identifier, 'Expected property name');
      _consume(TokenType.colon, 'Expected ":" after property name');
      final typeName = _parseTypeAnnotation();

      bool isNullable = false;
      if (_match([TokenType.question])) {
        isNullable = true;
      }

      if (_check(TokenType.semicolon)) {
        _advance();
      }

      properties.add(PropertyDefinition(
        id: propNameToken.lexeme,
        name: propNameToken.lexeme,
        ranges: [typeName],
        isNullable: isNullable,
      ));
    }

    _consume(TokenType.closeBrace, 'Expected "}" after schema body');

    return SchemaDeclaration(
      name: nameToken.lexeme,
      schemaUri: schemaUri,
      supertype: supertype,
      properties: properties,
    );
  }

  FunctionDeclaration _parseFunctionDeclaration() {
    final nameToken =
        _consume(TokenType.identifier, 'Expected function name');
    _consume(TokenType.openParen, 'Expected "(" after function name');

    final parameters = <String, String>{};
    if (!_check(TokenType.closeParen)) {
      do {
        final typeName = _parseTypeAnnotation();
        final paramNameToken =
            _consume(TokenType.identifier, 'Expected parameter name');
        parameters[paramNameToken.lexeme] = typeName;
      } while (_match([TokenType.comma]));
    }

    _consume(TokenType.closeParen, 'Expected ")" after parameters');

    String? returnType;
    if (_match([TokenType.arrow])) {
      returnType = _parseTypeAnnotation();
    }

    _consume(TokenType.openBrace, 'Expected "{" before function body');
    int braceDepth = 1;
    while (braceDepth > 0 && !_isAtEnd()) {
      if (_check(TokenType.openBrace)) braceDepth++;
      if (_check(TokenType.closeBrace)) braceDepth--;
      _advance();
    }

    return FunctionDeclaration(
      name: nameToken.lexeme,
      returnType: returnType,
      parameters: parameters,
    );
  }

  String _parseTypeAnnotation() {
    final baseTypeToken =
        _consume(TokenType.identifier, 'Expected type identifier');
    final buffer = StringBuffer(baseTypeToken.lexeme);

    if (_match([TokenType.openAngle])) {
      buffer.write('<');
      buffer.write(_parseTypeAnnotation());
      while (_match([TokenType.comma])) {
        buffer.write(', ');
        buffer.write(_parseTypeAnnotation());
      }
      _consume(TokenType.closeAngle, 'Expected ">" after generic arguments');
      buffer.write('>');
    }

    return buffer.toString();
  }

  bool _check(TokenType type) {
    if (_isAtEnd()) return false;
    return _peek().type == type;
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

  Token _consume(TokenType type, String message) {
    if (_check(type)) return _advance();
    throw FormatException('$message at ${_peek().lexeme}');
  }

  Token _advance() {
    if (!_isAtEnd()) _current++;
    return _previous();
  }

  bool _isAtEnd() => _peek().type == TokenType.eof;
  Token _peek() => tokens[_current];
  Token _previous() => tokens[_current - 1];
}
