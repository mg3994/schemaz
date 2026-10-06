import 'package:schemaz_core/schemaz_core.dart';

class SymbolTable {
  final Map<String, SchemazType> _symbols = {};

  void define(String name, SchemazType type) {
    _symbols[name] = type;
  }

  SchemazType? lookup(String name) => _symbols[name];

  bool contains(String name) => _symbols.containsKey(name);

  List<SchemazType> get allSymbols => _symbols.values.toList();
}
