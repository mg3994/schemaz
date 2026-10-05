class JsonLdContext {
  final Map<String, String> mappings;

  const JsonLdContext([this.mappings = const {'@vocab': 'https://schema.org/'}]);

  factory JsonLdContext.fromJson(dynamic json) {
    if (json is String) {
      return JsonLdContext({'@vocab': json});
    } else if (json is Map) {
      final map = <String, String>{};
      json.forEach((k, v) {
        if (v is String) {
          map[k.toString()] = v;
        } else if (v is Map && v['@id'] != null) {
          map[k.toString()] = v['@id'].toString();
        }
      });
      return JsonLdContext(map);
    }
    return const JsonLdContext();
  }

  String expandTerm(String term) {
    if (mappings.containsKey(term)) {
      return mappings[term]!;
    }
    final vocab = mappings['@vocab'] ?? 'https://schema.org/';
    if (term.startsWith('http://') || term.startsWith('https://')) {
      return term;
    }
    return '$vocab$term';
  }

  Map<String, dynamic> toJson() => mappings;
}
