import 'package:test/test.dart';
import 'package:schemaz_dart/schemaz_dart.dart';

void main() {
  group('DartApiImporter', () {
    test('Imports Dart class models and creates surface DartType nodes', () {
      final importer = DartApiImporter();
      const paymentService = DartClassModel(
        className: 'PaymentService',
        packageUri: 'package:shop/payment_service.dart',
        methods: ['pay'],
      );

      importer.importClass(paymentService);

      final model = importer.getClass('PaymentService');
      expect(model, isNotNull);
      expect(model!.packageUri, equals('package:shop/payment_service.dart'));

      final dartTypes = importer.toDartTypes();
      expect(dartTypes.length, equals(1));
      expect(dartTypes.first.name, equals('PaymentService'));
    });
  });
}
