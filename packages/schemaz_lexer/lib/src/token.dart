enum TokenType {
  // Keywords
  schemaKw,
  extendsKw,
  fnKw,
  returnKw,
  importKw,

  // Symbols & Identifiers
  identifier,
  stringLiteral,
  at,
  colon,
  semicolon,
  question,
  arrow,
  comma,
  openParen,
  closeParen,
  openBrace,
  closeBrace,
  openAngle,
  closeAngle,

  // Special
  eof,
  unknown,
}

class Token {
  final TokenType type;
  final String lexeme;
  final int line;
  final int column;

  const Token(this.type, this.lexeme, this.line, this.column);

  @override
  String toString() => 'Token($type, "$lexeme", $line:$column)';
}
