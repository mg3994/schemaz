/// Primitive for handling multi-language localized text values.
class LocalizedString {
  final Map<String, String> values; // e.g. {'en': 'Hello', 'es': 'Hola'}
  final String defaultLanguage;

  const LocalizedString(this.values, {this.defaultLanguage = 'en'});

  String getValue([String? lang]) {
    final targetLang = lang ?? defaultLanguage;
    return values[targetLang] ?? values[defaultLanguage] ?? values.values.firstOrNull ?? '';
  }

  List<Map<String, String>> toJsonLd() {
    return values.entries.map((e) => {'@language': e.key, '@value': e.value}).toList();
  }

  @override
  String toString() => getValue();
}
