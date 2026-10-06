/// Represents a localized string value with language/locale tag.
class LocalizedText {
  final String text;
  final String language; // e.g. "en", "fr", "es", "ja", "zh-CN"

  const LocalizedText(this.text, this.language);

  Map<String, dynamic> toJson() => {
        '@value': text,
        '@language': language,
      };

  @override
  String toString() => '"$text"@$language';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalizedText &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          language == other.language;

  @override
  int get hashCode => text.hashCode ^ language.hashCode;
}

/// The fundamental type system for Schemaz.
abstract class SchemazType {
  final String name;
  final String? description;

  const SchemazType(this.name, {this.description});

  bool isAssignableTo(SchemazType other);

  Map<String, dynamic> toJson();
}

/// Primitive types supported out of the box in Schemaz.
class PrimitiveType extends SchemazType {
  static const PrimitiveType text = PrimitiveType._('Text');
  static const PrimitiveType localizedText = PrimitiveType._('LocalizedText');
  static const PrimitiveType integer = PrimitiveType._('Integer');
  static const PrimitiveType float = PrimitiveType._('Float');
  static const PrimitiveType boolean = PrimitiveType._('Boolean');
  static const PrimitiveType dateTime = PrimitiveType._('DateTime');
  static const PrimitiveType any = PrimitiveType._('Any');

  const PrimitiveType._(super.name, {super.description});

  @override
  bool isAssignableTo(SchemazType other) {
    if (other == PrimitiveType.any || this == other) return true;
    if (this == PrimitiveType.localizedText && other == PrimitiveType.text) return true;
    if (this == PrimitiveType.text && other == PrimitiveType.localizedText) return true;
    if (this == PrimitiveType.integer && other == PrimitiveType.float) return true;
    return false;
  }

  @override
  Map<String, dynamic> toJson() => {'type': 'PrimitiveType', 'name': name};

  @override
  String toString() => name;
}

/// Generic List type in Schemaz (e.g. List<Text>).
class ListType extends SchemazType {
  final SchemazType elementType;

  ListType(this.elementType)
      : super('List<${elementType.name}>',
            description: 'List of ${elementType.name}');

  @override
  bool isAssignableTo(SchemazType other) {
    if (other == PrimitiveType.any) return true;
    if (other is ListType) {
      return elementType.isAssignableTo(other.elementType);
    }
    return false;
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': 'ListType',
        'elementType': elementType.toJson(),
      };

  @override
  String toString() => 'List<${elementType.name}>';
}

/// Generic Map type in Schemaz (e.g. Map<Text, Any>).
class MapType extends SchemazType {
  final SchemazType keyType;
  final SchemazType valueType;

  MapType(this.keyType, this.valueType)
      : super('Map<${keyType.name}, ${valueType.name}>');

  @override
  bool isAssignableTo(SchemazType other) {
    if (other == PrimitiveType.any) return true;
    if (other is MapType) {
      return keyType.isAssignableTo(other.keyType) &&
          valueType.isAssignableTo(other.valueType);
    }
    return false;
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': 'MapType',
        'keyType': keyType.toJson(),
        'valueType': valueType.toJson(),
      };

  @override
  String toString() => 'Map<${keyType.name}, ${valueType.name}>';
}
