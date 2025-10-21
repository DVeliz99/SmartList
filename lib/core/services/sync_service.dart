import 'package:smart_list/core/network/network_info.dart';
import 'package:smart_list/domain/product.dart';
import 'package:smart_list/use_cases/product_use_cases.dart';

class SyncService {
  final NetworkInfo networkInfo;
  final CacheProductsUseCase cacheProductsUseCase;
  final FetchProductsUseCase fetchProductsUseCase;
  final SaveProductUseCase saveProductUseCase;
  final GetUnsyncedProductsUseCase getUnsyncedProductsUseCase;
  final GetSoftDeletedProductsUseCase getSoftDeletedProductsUseCase;
  final DeleteRemoteProductUseCase deleteRemoteProductUseCase;
  final DeleteLocalProductUseCase deleteLocalProductUseCase;

  SyncService({
    required this.networkInfo,
    required this.cacheProductsUseCase,
    required this.fetchProductsUseCase,
    required this.getSoftDeletedProductsUseCase,
    required this.deleteRemoteProductUseCase,
    required this.deleteLocalProductUseCase,
    required this.getUnsyncedProductsUseCase,
    required this.saveProductUseCase,
  });

  Future<void> getAndSaveProducts() async {
    try {
      //verificar conexión

      final isConnected = await networkInfo.isConnected;

      if (!isConnected) {
        print(
          'No hay conexión a Internet. Solo se puede trabajar con cache local.',
        );
        return;
      }

      //obtener productos del remoto
      final result = await fetchProductsUseCase();
      if (result.isSuccess && result.data != null) {
        final products = result.data!;

        //guardar productos en cache
        final cacheResult = await cacheProductsUseCase(products);
        if (cacheResult.isSuccess) {
          print('Productos guardados en cache correctamente.');
        } else {
          print(
            'Error al guardar productos en cache: ${cacheResult.failure?.message}',
          );
        }
      } else {
        print(
          'Error al obtener productos desde la API: ${result.failure?.message}',
        );
      }
    } catch (error) {
      print('Error en getAndSaveProducts: $error');
    }
  }

  Future<List<Product>> sendProductsToApi() async {
    List<Product> savedProducts = [];
    try {
      final result = await getUnsyncedProductsUseCase();
      if (result.isSuccess && result.data != null) {
        final unsyncedProducts = result.data!;
        if (unsyncedProducts.isNotEmpty) {
          for (var p in unsyncedProducts) {
            dynamic resultSaveProducts = await saveProductUseCase(p);
            if (resultSaveProducts.isSuccess) {
              savedProducts.add(resultSaveProducts);
            }
          }
        }
        return savedProducts;
      } else {
        print('Error al enviar productos a la API: ${result.failure?.message}');
        return [];
      }
    } catch (error) {
      print('Error en sendProductsToApi: $error');
      return [];
    }
  }

  Future<List<Product>> deleteProductsFromApi() async {
    try {
      final result = await getSoftDeletedProductsUseCase();
      if (result.isSuccess && result.data != null) {
        final softDeletedProducts = result.data!;
        for (var p in softDeletedProducts) {
          final deleteRemoteProductResult = await deleteRemoteProductUseCase(
            p.id,
          );
          if (deleteRemoteProductResult.isSuccess) {
            print('Product con id: $p.id eliminado');
          } else {
            print('El producto con id: $p.id no se pudo eliminar');
          }
        }

        return softDeletedProducts;
      } else {
        print('No se pudieron obtener los productos eliminados desde local');
        return [];
      }
    } catch (e) {
      print('Error en deleteProductsFromApi: $e');
      return [];
    }
  }

  Future<List<Product>> deleteProductsFromLocal() async {
    try {
      final productsResult = await getSoftDeletedProductsUseCase();
      List<Product> deletedProducts = [];

      if (productsResult.isSuccess && productsResult.data != null) {
        final products = productsResult.data!;
        for (var p in products) {
          final result = await deleteLocalProductUseCase(p);

          if (result.isSuccess) {
            deletedProducts.add(p);
            print('Product con id: ${p.id} eliminado');
          } else {
            print('El producto con id: ${p.id} no se pudo eliminar');
          }
        }
      } else {
        print('No se pudieron obtener los productos eliminados desde local');
      }

      return deletedProducts;
    } catch (e) {
      print('Error en deleteProductsFromLocal: $e');
      return [];
    }
  }
}
