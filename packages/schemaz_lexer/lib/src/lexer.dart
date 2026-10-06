import 'token.dart';

class Lexer {
  final String source;
  int _position = 0;
  int _line = 1;
  int _column = 1;

  Lexer(this.source);

  List<Token> tokenize() {
    final tokens = <Token>[];
    while (!_isAtEnd()) {
      _skipWhitespaceAndComments();
      if (_isAtEnd()) break;

      final startColumn = _column;
      final char = _advance();

      switch (char) {
        case '@':
          tokens.add(Token(TokenType.at, '@', _line, startColumn));
          break;
        case ':':
          tokens.add(Token(TokenType.colon, ':', _line, startColumn));
          break;
        case ';':
          tokens.add(Token(TokenType.semicolon, ';', _line, startColumn));
          break;
        case '?':
          tokens.add(Token(TokenType.question, '?', _line, startColumn));
          break;
        case ',':
          tokens.add(Token(TokenType.comma, ',', _line, startColumn));
          break;
        case '(':
          tokens.add(Token(TokenType.openParen, '(', _line, startColumn));
          break;
        case ')':
          tokens.add(Token(TokenType.closeParen, ')', _line, startColumn));
          break;
        case '{':
          tokens.add(Token(TokenType.openBrace, '{', _line, startColumn));
          break;
        case '}':
          tokens.add(Token(TokenType.closeBrace, '}', _line, startColumn));
          break;
        case '<':
          tokens.add(Token(TokenType.openAngle, '<', _line, startColumn));
          break;
        case '>':
          tokens.add(Token(TokenType.closeAngle, '>', _line, startColumn));
          break;
        case '-':
          if (_match('>')) {
            tokens.add(Token(TokenType.arrow, '->', _line, startColumn));
          } else {
            tokens.add(Token(TokenType.unknown, '-', _line, startColumn));
          }
          break;
        case "'":
        case '"':
          tokens.add(_stringLiteral(char, startColumn));
          break;
        default:
          if (_isAlpha(char)) {
            tokens.add(_identifier(char, startColumn));
          } else {
            tokens.add(Token(TokenType.unknown, char, _line, startColumn));
          }
          break;
      }
    }
    tokens.add(Token(TokenType.eof, '', _line, _column));
    return tokens;
  }

  bool _isAtEnd() => _position >= source.length;

  String _advance() {
    final c = source[_position++];
    _column++;
    return c;
  }

  bool _match(String expected) {
    if (_isAtEnd() || source[_position] != expected) return false;
    _position++;
    _column++;
    return true;
  }

  String _peek() => _isAtEnd() ? '' : source[_position];

  void _skipWhitespaceAndComments() {
    while (!_isAtEnd()) {
      final c = _peek();
      if (c == ' ' || c == '\r' || c == '\t') {
        _advance();
      } else if (c == '\n') {
        _line++;
        _column = 1;
        _advance();
      } else if (c == '/' && _peekNext() == '/') {
        while (!_isAtEnd() && _peek() != '\n') {
          _advance();
        }
      } else {
        break;
      }
    }
  }

  String _peekNext() {
    if (_position + 1 >= source.length) return '';
    return source[_position + 1];
  }

  Token _stringLiteral(String quote, int startColumn) {
    final buffer = StringBuffer();
    while (!_isAtEnd() && _peek() != quote) {
      if (_peek() == '\n') {
        _line++;
        _column = 1;
      }
      buffer.write(_advance());
    }

    if (!_isAtEnd()) {
      _advance(); // Consume closing quote
    }

    return Token(
        TokenType.stringLiteral, buffer.toString(), _line, startColumn);
  }

  Token _identifier(String firstChar, int startColumn) {
    final buffer = StringBuffer(firstChar);
    while (!_isAtEnd() && (_isAlphaNumeric(_peek()) || _peek() == '.')) {
      buffer.write(_advance());
    }

    final lexeme = buffer.toString();
    TokenType type;
    switch (lexeme) {
      case 'schema':
        type = TokenType.schemaKw;
        break;
      case 'extends':
        type = TokenType.extendsKw;
        break;
      case 'fn':
        type = TokenType.fnKw;
        break;
      case 'return':
        type = TokenType.returnKw;
        break;
      case 'import':
        type = TokenType.importKw;
        break;
      default:
        type = TokenType.identifier;
        break;
    }

    return Token(type, lexeme, _line, startColumn);
  }

  bool _isAlpha(String c) => RegExp(r'[a-zA-Z_]').hasMatch(c);
  bool _isAlphaNumeric(String c) => RegExp(r'[a-zA-Z0-9_]').hasMatch(c);
}
