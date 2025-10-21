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
  final RemoteProductExistsUseCase remoteProductExistsUseCase;
  final UpdateRemoteProductUseCase updateRemoteProductUseCase;

  SyncService({
    required this.networkInfo,
    required this.cacheProductsUseCase,
    required this.fetchProductsUseCase,
    required this.getSoftDeletedProductsUseCase,
    required this.deleteRemoteProductUseCase,
    required this.deleteLocalProductUseCase,
    required this.getUnsyncedProductsUseCase,
    required this.saveProductUseCase,
    required this.remoteProductExistsUseCase,
    required this.updateRemoteProductUseCase,
  });

  Future<void> getAndSaveProducts() async {
    try {
    

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
    List<Product> processedProducts = [];

    try {
      final result = await getUnsyncedProductsUseCase();

      if (result.isSuccess && result.data != null) {
        final unsyncedProducts = result.data!;
        if (unsyncedProducts.isNotEmpty) {
          for (var product in unsyncedProducts) {
            try {
              // Verificar si existe en remoto
              final existsResult = await remoteProductExistsUseCase(product);
              if (existsResult.isSuccess && existsResult.data == true) {
                // Actualizar producto remoto
                final updateResult = await updateRemoteProductUseCase(product);
                if (updateResult.isSuccess && updateResult.data != null) {
                  processedProducts.add(updateResult.data!);
                }
              } else {
                // Guardar como nuevo producto remoto
                final saveResult = await saveProductUseCase(product);
                if (saveResult.isSuccess && saveResult.data != null) {
                  processedProducts.add(saveResult.data!);
                }
              }
            } catch (e) {
              print('Error procesando el producto ${product.id}: $e');
            }
          }
        }
      } else {
        print(
          'Error al obtener productos no sincronizados: ${result.failure?.message}',
        );
      }
    } catch (error) {
      print('Error en sendProductsToApi: $error');
    }

    return processedProducts;
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
        print('No se pudieron obtener los productos eliminados desde API');
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
