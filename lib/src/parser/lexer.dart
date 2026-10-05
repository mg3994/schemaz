enum TokenType {
  // Keywords
  kwSchema,
  kwExtends,
  kwImport,
  kwFunction,
  kwLet,
  kwReturn,
  kwIf,
  kwElse,
  kwTrue,
  kwFalse,
  kwNull,
  kwDart,
  kwAs,

  // Literals & Identifiers
  identifier,
  stringLiteral,
  numberLiteral,

  // Symbols
  leftBrace, // {
  rightBrace, // }
  leftParen, // (
  rightParen, // )
  leftBracket, // [
  rightBracket, // ]
  colon, // :
  comma, // ,
  dot, // .
  arrow, // ->
  assign, // =
  plus, // +
  minus, // -
  star, // *
  slash, // /
  equals, // ==
  notEquals, // !=
  greater, // >
  greaterEquals, // >=
  less, // <
  lessEquals, // <=

  eof,
}

class Token {
  final TokenType type;
  final String text;
  final Object? value;
  final int line;
  final int column;

  Token(this.type, this.text, this.value, this.line, this.column);

  @override
  String toString() => 'Token($type, "$text", line: $line, col: $column)';
}

class Lexer {
  final String source;
  int _position = 0;
  int _line = 1;
  int _column = 1;

  Lexer(this.source);

  static const Map<String, TokenType> _keywords = {
    'schema': TokenType.kwSchema,
    'extends': TokenType.kwExtends,
    'import': TokenType.kwImport,
    'function': TokenType.kwFunction,
    'let': TokenType.kwLet,
    'return': TokenType.kwReturn,
    'if': TokenType.kwIf,
    'else': TokenType.kwElse,
    'true': TokenType.kwTrue,
    'false': TokenType.kwFalse,
    'null': TokenType.kwNull,
    'dart': TokenType.kwDart,
    'as': TokenType.kwAs,
  };

  List<Token> tokenize() {
    final tokens = <Token>[];
    while (_position < source.length) {
      final ch = source[_position];

      if (_isWhitespace(ch)) {
        _advanceChar(ch);
        continue;
      }

      if (ch == '/' && _peek(1) == '/') {
        // Skip comment
        while (_position < source.length && source[_position] != '\n') {
          _advanceChar(source[_position]);
        }
        continue;
      }

      final startLine = _line;
      final startCol = _column;

      if (ch == '{') {
        tokens.add(Token(TokenType.leftBrace, '{', null, startLine, startCol));
        _advanceChar(ch);
      } else if (ch == '}') {
        tokens.add(Token(TokenType.rightBrace, '}', null, startLine, startCol));
        _advanceChar(ch);
      } else if (ch == '(') {
        tokens.add(Token(TokenType.leftParen, '(', null, startLine, startCol));
        _advanceChar(ch);
      } else if (ch == ')') {
        tokens.add(Token(TokenType.rightParen, ')', null, startLine, startCol));
        _advanceChar(ch);
      } else if (ch == '[') {
        tokens.add(Token(TokenType.leftBracket, '[', null, startLine, startCol));
        _advanceChar(ch);
      } else if (ch == ']') {
        tokens.add(Token(TokenType.rightBracket, ']', null, startLine, startCol));
        _advanceChar(ch);
      } else if (ch == ':') {
        tokens.add(Token(TokenType.colon, ':', null, startLine, startCol));
        _advanceChar(ch);
      } else if (ch == ',') {
        tokens.add(Token(TokenType.comma, ',', null, startLine, startCol));
        _advanceChar(ch);
      } else if (ch == '.') {
        tokens.add(Token(TokenType.dot, '.', null, startLine, startCol));
        _advanceChar(ch);
      } else if (ch == '-' && _peek(1) == '>') {
        tokens.add(Token(TokenType.arrow, '->', null, startLine, startCol));
        _advanceChar(ch);
        _advanceChar('>');
      } else if (ch == '=') {
        if (_peek(1) == '=') {
          tokens.add(Token(TokenType.equals, '==', null, startLine, startCol));
          _advanceChar(ch);
          _advanceChar('=');
        } else {
          tokens.add(Token(TokenType.assign, '=', null, startLine, startCol));
          _advanceChar(ch);
        }
      } else if (ch == '!') {
        if (_peek(1) == '=') {
          tokens.add(Token(TokenType.notEquals, '!=', null, startLine, startCol));
          _advanceChar(ch);
          _advanceChar('=');
        } else {
          throw FormatException('Unexpected character ! at line $_line, col $_column');
        }
      } else if (ch == '>') {
        if (_peek(1) == '=') {
          tokens.add(Token(TokenType.greaterEquals, '>=', null, startLine, startCol));
          _advanceChar(ch);
          _advanceChar('=');
        } else {
          tokens.add(Token(TokenType.greater, '>', null, startLine, startCol));
          _advanceChar(ch);
        }
      } else if (ch == '<') {
        if (_peek(1) == '=') {
          tokens.add(Token(TokenType.lessEquals, '<=', null, startLine, startCol));
          _advanceChar(ch);
          _advanceChar('=');
        } else {
          tokens.add(Token(TokenType.less, '<', null, startLine, startCol));
          _advanceChar(ch);
        }
      } else if (ch == '+') {
        tokens.add(Token(TokenType.plus, '+', null, startLine, startCol));
        _advanceChar(ch);
      } else if (ch == '-') {
        tokens.add(Token(TokenType.minus, '-', null, startLine, startCol));
        _advanceChar(ch);
      } else if (ch == '*') {
        tokens.add(Token(TokenType.star, '*', null, startLine, startCol));
        _advanceChar(ch);
      } else if (ch == '/') {
        tokens.add(Token(TokenType.slash, '/', null, startLine, startCol));
        _advanceChar(ch);
      } else if (ch == '"' || ch == "'") {
        tokens.add(_readString(ch, startLine, startCol));
      } else if (_isDigit(ch)) {
        tokens.add(_readNumber(startLine, startCol));
      } else if (_isAlpha(ch)) {
        tokens.add(_readIdentifierOrKeyword(startLine, startCol));
      } else {
        throw FormatException('Unexpected character "$ch" at line $_line, col $_column');
      }
    }

    tokens.add(Token(TokenType.eof, '', null, _line, _column));
    return tokens;
  }

  Token _readString(String quote, int startLine, int startCol) {
    _advanceChar(quote);
    final sb = StringBuffer();
    while (_position < source.length && source[_position] != quote) {
      if (source[_position] == '\\' && _position + 1 < source.length) {
        _advanceChar('\\');
        final escaped = source[_position];
        if (escaped == 'n') sb.write('\n');
        else if (escaped == 't') sb.write('\t');
        else if (escaped == 'r') sb.write('\r');
        else sb.write(escaped);
        _advanceChar(escaped);
      } else {
        sb.write(source[_position]);
        _advanceChar(source[_position]);
      }
    }
    if (_position >= source.length) {
      throw FormatException('Unterminated string literal starting at line $startLine, col $startCol');
    }
    _advanceChar(quote);
    final strVal = sb.toString();
    return Token(TokenType.stringLiteral, strVal, strVal, startLine, startCol);
  }

  Token _readNumber(int startLine, int startCol) {
    final sb = StringBuffer();
    bool isFloat = false;
    while (_position < source.length && (_isDigit(source[_position]) || source[_position] == '.')) {
      if (source[_position] == '.') {
        if (isFloat) break;
        if (_position + 1 < source.length && !_isDigit(source[_position + 1])) {
          break; // property access e.g. 10.toString()
        }
        isFloat = true;
      }
      sb.write(source[_position]);
      _advanceChar(source[_position]);
    }
    final text = sb.toString();
    final value = isFloat ? double.parse(text) : int.parse(text);
    return Token(TokenType.numberLiteral, text, value, startLine, startCol);
  }

  Token _readIdentifierOrKeyword(int startLine, int startCol) {
    final sb = StringBuffer();
    while (_position < source.length && (_isAlphaNumeric(source[_position]))) {
      sb.write(source[_position]);
      _advanceChar(source[_position]);
    }
    final text = sb.toString();
    final type = _keywords[text] ?? TokenType.identifier;
    return Token(type, text, text, startLine, startCol);
  }

  void _advanceChar(String ch) {
    _position++;
    if (ch == '\n') {
      _line++;
      _column = 1;
    } else {
      _column++;
    }
  }

  String _peek(int offset) {
    if (_position + offset < source.length) {
      return source[_position + offset];
    }
    return '';
  }

  bool _isWhitespace(String ch) => ch == ' ' || ch == '\t' || ch == '\r' || ch == '\n';
  bool _isDigit(String ch) => ch.codeUnitAt(0) >= '0'.codeUnitAt(0) && ch.codeUnitAt(0) <= '9'.codeUnitAt(0);
  bool _isAlpha(String ch) {
    final code = ch.codeUnitAt(0);
    return (code >= 'a'.codeUnitAt(0) && code <= 'z'.codeUnitAt(0)) ||
        (code >= 'A'.codeUnitAt(0) && code <= 'Z'.codeUnitAt(0)) ||
        ch == '_' || ch == '@';
  }

  bool _isAlphaNumeric(String ch) => _isAlpha(ch) || _isDigit(ch);
}
