import 'package:smart_list/core/network/network_info.dart';
import 'package:smart_list/domain/product.dart';
import 'package:smart_list/use_cases/product_use_cases.dart';


class SyncService {
  final NetworkInfo networkInfo;
  final CacheProductsUseCase cacheProductsUseCase;
  final FetchProductsUseCase fetchProductsUseCase;

  SyncService({
    required this.networkInfo,
    required this.cacheProductsUseCase,
    required this.fetchProductsUseCase,
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

  Future<List<Product>> sendProductsToApi(List<Product> products) async {
    try {
      final result = await fetchProductsUseCase();
      if (result.isSuccess && result.data != null) {
        return result.data!;
      } else {
        print(
          'Error al enviar productos a la API: ${result.failure?.message}',
        );
        return [];
      }
    } catch (error) {
      print('Error en sendProductsToApi: $error');
      return [];
    }
  }

  
}
