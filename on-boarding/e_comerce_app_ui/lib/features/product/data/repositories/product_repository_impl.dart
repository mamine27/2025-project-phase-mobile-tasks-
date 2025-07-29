import '/features/product/domain/entities/product.dart';
import '/features/product/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final Map<String, Product> _productStore = {};

  @override
  Future<void> insertProduct(Product product) async {
    _productStore[product.id] = product;
  }

  @override
  Future<void> updateProduct(Product product) async {
    if (_productStore.containsKey(product.id)) {
      _productStore[product.id] = product;
    } else {
      throw Exception('Product not found');
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    _productStore.remove(id);
  }

  @override
  Future<Product?> getProduct(String id) async {
    return _productStore[id];
  }
}
