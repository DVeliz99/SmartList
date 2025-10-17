import 'package:smart_list/core/failure.dart';
import 'package:smart_list/core/result.dart';
import 'package:smart_list/data/repositories/product_repository.dart';
import 'package:smart_list/domain/product.dart';

class FetchProductsUseCase {
  final ProductRepository repository;

  FetchProductsUseCase({required this.repository});

  Future<Result<List<Product>>> call() async {
    try {
      final product = await repository.fetchProducts();
      return Result.success(product);
    } catch (error) {
       return Result.failure(ApiFailure('Error al obtener productos: $error'));
    }
  }

  
}
