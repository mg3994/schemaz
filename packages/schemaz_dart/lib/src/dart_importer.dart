import 'package:schemaz_core/schemaz_core.dart';

class DartClassModel {
  final String className;
  final String packageUri;
  final List<String> methods;
  final List<String> fields;

  const DartClassModel({
    required this.className,
    required this.packageUri,
    this.methods = const [],
    this.fields = const [],
  });

  DartType toDartType() {
    return DartType(
      '$packageUri#$className',
      className,
      packageUri: packageUri,
    );
  }
}

class DartApiImporter {
  final Map<String, DartClassModel> _importedClasses = {};

  void importClass(DartClassModel model) {
    _importedClasses[model.className] = model;
  }

  DartClassModel? getClass(String className) => _importedClasses[className];

  List<DartType> toDartTypes() {
    return _importedClasses.values.map((model) => model.toDartType()).toList();
  }
}
