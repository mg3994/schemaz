/// Primitive for handling multi-language localized text values.
class LocalizedString {
  final Map<String, String> values; // e.g. {'en': 'Manish', 'hi': 'मनीष', 'ml': 'മനീഷ്'}
  final String defaultLanguage;

  const LocalizedString(this.values, {this.defaultLanguage = 'en'});

  factory LocalizedString.fromJsonLd(dynamic json) {
    if (json is String) {
      return LocalizedString({'en': json});
    } else if (json is List) {
      final map = <String, String>{};
      for (final item in json) {
        if (item is Map) {
          final lang = item['@language'] ?? 'en';
          final val = item['@value'] ?? '';
          map[lang.toString()] = val.toString();
        }
      }
      return LocalizedString(map);
    } else if (json is Map) {
      final map = <String, String>{};
      json.forEach((key, val) {
        map[key.toString()] = val.toString();
      });
      return LocalizedString(map);
    }
    return const LocalizedString({});
  }

  String getValue([String? lang]) {
    final targetLang = lang ?? defaultLanguage;
    return values[targetLang] ?? values[defaultLanguage] ?? values.values.firstOrNull ?? '';
  }

  List<Map<String, String>> toJsonLd() {
    return values.entries.map((e) => {'@value': e.value, '@language': e.key}).toList();
  }

  @override
  String toString() => getValue();
}
