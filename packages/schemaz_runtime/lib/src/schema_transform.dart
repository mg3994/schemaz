class SchemaTransform {
  final Map<String, String> fieldMappings; // e.g. {'fullName': 'name', 'mail': 'email'}

  const SchemaTransform([this.fieldMappings = const {}]);

  Map<String, dynamic> transform(Map<String, dynamic> sourceData) {
    final result = <String, dynamic>{};
    sourceData.forEach((key, value) {
      final targetKey = fieldMappings[key] ?? key;
      result[targetKey] = value;
    });
    return result;
  }
}
