import 'package:flutter_test/flutter_test.dart';
import 'package:e_comerce_app_ui/features/product/data/models/product_model.dart';

void main() {
  group('ProductModel (de)serialization', () {
    // 1) A "golden" JSON map
    const Map<String, dynamic> tJson = {
      'id': '42',
      'name': 'Air Max 2025',
      'description': 'Premium running shoes',
      'price': 199.99,
      'imageUrl': 'https://example.com/airmax.jpeg',
    };

    // 2) The corresponding Dart object
    final tModel = ProductModel(
      id: '42',
      name: 'Air Max 2025',
      description: 'Premium running shoes',
      price: 199.99,
      imageUrl: 'https://example.com/airmax.jpeg',
    );

    test('fromJson should create a valid model', () {
      final result = ProductModel.fromJson(tJson);
      expect(result, equals(tModel));
    });

    test('toJson should return a valid map', () {
      final result = tModel.toJson();
      expect(result, tJson);
    });
  });
}
