import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../data/models/product_model.dart';
import '../entities/product.dart';

abstract class ProductRepository {
  Future<Either<Failure, Product>> updateProduct(Product product);
  Future<Either<Failure, Unit>> deleteProduct(String id);
  Future<Either<Failure, Product>> getProduct(String id);
  Future<Either<Failure, List<Product>>> getProducts();
  Future<Either<Failure, Product>> createProduct(Product product);
}
