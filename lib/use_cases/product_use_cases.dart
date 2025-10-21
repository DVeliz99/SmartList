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

//Caso para obtener productos en cache
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

//Caso para añadir productos locales
class AddProductUseCase {
  final ProductLocalRepository repository;

  AddProductUseCase({required this.repository});

  Future<Result<Product>> call(Product product) async {
    try {
      final addedProduct = await repository.addProduct(product);
      return Result.success(addedProduct);
    } catch (error) {
      return Result.failure(
        DatabaseFailure('Error al agregar producto: $error'),
      );
    }
  }
}

//Caso para añadir productos remotos
class SaveProductUseCase {
  final ProductRemoteRepository repository;

  SaveProductUseCase({required this.repository});

  Future<Result<Product>> call(Product product) async {
    try {
      final addedProduct = await repository.saveProduct(product);
      return Result.success(addedProduct);
    } catch (error) {
      return Result.failure(
        ApiFailure('Error al agregar producto en remoto: $error'),
      );
    }
  }
}

//Caso para identificar productos locales
class CheckProductExistsUseCase {
  final ProductLocalRepository repository;

  CheckProductExistsUseCase({required this.repository});

  Future<Result<bool>> call(String id) async {
    try {
      final exists = await repository.productExists(id);
      return Result.success(exists);
    } catch (error) {
      return Result.failure(
        DatabaseFailure('Error al verificar existencia del producto: $error'),
      );
    }
  }
}

// Caso para eleminar productos temporalmente
class SoftDeleteLocalProductUseCase {
  final ProductLocalRepository repository;

  SoftDeleteLocalProductUseCase({required this.repository});

  Future<Result<Product>> call(String id) async {
    try {
      final deletedProduct = await repository.softDeleteProduct(id);
      return Result.success(deletedProduct);
    } catch (error) {
      return Result.failure(
        DatabaseFailure('Error al eliminar producto en local: $error'),
      );
    }
  }
}

// Caso para obtener productos eliminados temporalmente
class GetSoftDeletedProductsUseCase {
  final ProductLocalRepository repository;

  GetSoftDeletedProductsUseCase({required this.repository});

  Future<Result<List<Product>>> call() async {
    try {
      final softDeletedProducts = await repository.getSoftDeletedProducts();
      return Result.success(softDeletedProducts);
    } catch (error) {
      return Result.failure(
        DatabaseFailure('Error al obtener productos eliminados'),
      );
    }
  }
}

// Casos para eliminar productos remotos
class DeleteRemoteProductUseCase {
  final ProductRemoteRepository repository;

  DeleteRemoteProductUseCase({required this.repository});

  Future<Result<Product>> call(String id) async {
    try {
      final deletedProduct = await repository.deleteProduct(id);
      return Result.success(deletedProduct);
    } catch (error) {
      return Result.failure(
        ApiFailure('Error al eliminar producto en remoto: $error'),
      );
    }
  }
}

// casos para eliminar productos locales
class DeleteLocalProductUseCase {
  final ProductLocalRepository repository;

  DeleteLocalProductUseCase({required this.repository});

  Future<Result<Product>> call(Product product) async {
    try {
      final deletedProduct = await repository.deleteProduct(product);
      return Result.success(deletedProduct);
    } catch (error) {
      return Result.failure(
        ApiFailure(
          'Error al eliminar producto permanentemente en local: $error',
        ),
      );
    }
  }
}

//Caso para obtener productos locales no sincronizados
class GetUnsyncedProductsUseCase {
  final ProductLocalRepository repository;

  GetUnsyncedProductsUseCase({required this.repository});

  Future<Result<List<Product>>> call() async {
    try {
      final unsyncedProducts = await repository.getUnsyncedProducts();
      return Result.success(unsyncedProducts);
    } catch (error) {
      return Result.failure(
        DatabaseFailure('Error al obtener productos no sincronizados'),
      );
    }
  }
}

//caso para actualizar producto locales
class UpdateLocalProductUseCase {
  final ProductLocalRepository repository;
  UpdateLocalProductUseCase({required this.repository});

  Future<Result<Product>> call(Product product) async {
    try {
      final updatedProduct = await repository.updateProduct(product);
      return Result.success(updatedProduct);
    } catch (error) {
      return Result.failure(DatabaseFailure('Error al actualizar el producto'));
    }
  }
}

// Caso para verificar si un producto remoto existe
class RemoteProductExistsUseCase {
  final ProductRemoteRepository repository;
  RemoteProductExistsUseCase({required this.repository});

  Future<Result<Product>> call(Product product) async {
    try {
      final currentProduct = await repository.productExists(product);
      return Result.success(currentProduct);
    } catch (error) {
      return Result.failure(
        ApiFailure('Error al ecnontrar el producto en remoto: $error'),
      );
    }
  }
}

// Caso para actualizar un producto remoto
class UpdateRemoteProductUseCase {
  final ProductRemoteRepository repository;
  UpdateRemoteProductUseCase({required this.repository});

  Future<Result<Product>> call(Product product) async {
    try {
      final currentProduct = await repository.updateProduct(product);
      return Result.success(currentProduct);
    } catch (error) {
      return Result.failure(
        ApiFailure('Error al ecnontrar el producto en remoto: $error'),
      );
    }
  }
}
