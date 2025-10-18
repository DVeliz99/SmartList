import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:smart_list/core/network/network_info.dart';
import 'package:smart_list/data/api_datasource/product_api_datasource.dart';
import 'package:smart_list/data/implements/product_local_repository_implement.dart';
import 'package:smart_list/data/implements/product_remote_repository_implement.dart';
import 'package:smart_list/data/sqlLite_datasource/product_local_datasource.dart';
import 'package:smart_list/use_cases/product_use_cases.dart';

import 'core/services/sync_service.dart';

void main() async {
  // Asegurarse de que los bindings de Flutter estén inicializados
  WidgetsFlutterBinding.ensureInitialized();

  final networkInfo = NetworkInfoImpl(Connectivity());

  // Instancia del repositorio remoto y caso de uso
  final remoteProductDataSource = ProductApiDataSource();
  final productRemoteRepository = ProductRepositoryImpl(
    dataSource: remoteProductDataSource,
  );
  final fetchProductsUseCase = FetchProductsUseCase(
    repository: productRemoteRepository,
  );

  // Instancia del repositorio local y caso de uso
  final localProductDataSource = ProductLocalDatasource();
  final productLocalRepository = ProductLocalRepositoryImpl(
    dataSource: localProductDataSource,
  );
  final cacheProductsUseCase = CacheProductsUseCase(
    repository: productLocalRepository,
  );
  final getCachedProductsUseCase = GetCachedProductsUseCase(
    repository: productLocalRepository,
  );

  //Instancia del servicio de sincronización
  final syncService = SyncService(
    networkInfo: networkInfo,
    cacheProductsUseCase: cacheProductsUseCase,
    fetchProductsUseCase: fetchProductsUseCase,
  );

  await syncService.getAndSaveProducts();

  //Obtener datos de la base de datos local
  final cachedProducts = await getCachedProductsUseCase();
  if (cachedProducts.isSuccess && cachedProducts.data != null) {
    for (final product in cachedProducts.data!) {
      print(product);
    }
  } else {
    print(
      'Error al obtener productos en cache: ${cachedProducts.failure?.message}',
    );
  }
}
