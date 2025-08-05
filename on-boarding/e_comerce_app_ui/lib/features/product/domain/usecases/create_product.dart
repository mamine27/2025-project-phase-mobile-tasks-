import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';
import 'usecase.dart';

class CreateProduct implements UseCase<Product, Product> {
  final ProductRepository repository;

  CreateProduct(this.repository);

  Future<Either<Failure, Product>> call(Product product) async {
    return await repository.createProduct(product);
  }
}
