class SourceLocation {
  final int line;
  final int column;
  final String? sourceUrl;

  const SourceLocation({
    required this.line,
    required this.column,
    this.sourceUrl,
  });

  @override
  String toString() => '$line:$column${sourceUrl != null ? " ($sourceUrl)" : ""}';
}
