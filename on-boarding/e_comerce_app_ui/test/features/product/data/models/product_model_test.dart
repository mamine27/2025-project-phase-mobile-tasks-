import 'package:flutter_test/flutter_test.dart';
import 'package:e_comerce_app_ui/features/product/data/models/product_model.dart';

void main() {
  group('ProductModel (de)serialization', () {
    // 1) A "golden" JSON map
    const Map<String, dynamic> tJson = {
      'id': 42,
      'name': 'Air Max 2025',
      'description': 'Premium running shoes',
      'price': 199.99,
      'imageUrl': 'https://example.com/airmax.jpeg',
    };

    // 2) The corresponding Dart object
    final tModel = ProductModel(
      id: 42,
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

class ProductModel {
  final int id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductModel &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.price == price &&
        other.imageUrl == imageUrl;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      price.hashCode ^
      imageUrl.hashCode;
}
