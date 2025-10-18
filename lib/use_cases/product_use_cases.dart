import 'package:smart_list/core/error/failure.dart';
import 'package:smart_list/core/error/result.dart';
import 'package:smart_list/data/repositories/product_local_repository.dart';
import 'package:smart_list/data/repositories/product_remote_repository.dart';
import 'package:smart_list/domain/product.dart';

//Caso para obtener productos desde el repositorio remoto
class FetchProductsUseCase {
  final ProductRemoteRepository repository;

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

//Caso para guardar productos en cache
class CacheProductsUseCase {
  final ProductLocalRepository repository;
  CacheProductsUseCase({required this.repository});

  Future<Result<void>> call(List<Product> products) async {
    try {
      await repository.cacheProducts(products);
      return Result.success(
        null,
      ); // Se retorna null ya que la operación es de tipo void
    } catch (error) {
      return Result.failure(
        DatabaseFailure('Error al guardar productos en cache: $error'),
      );
    }
  }
}

class GetCachedProductsUseCase {
  final ProductLocalRepository repository;
  GetCachedProductsUseCase({required this.repository});

  Future<Result<List<Product>>> call() async {
    try {
      return Result.success(await repository.getCachedProducts());
    } catch (error) {
      return Result.failure(
        DatabaseFailure('Error al obtener productos de la cache: $error'),
      );
    }
  }
}
