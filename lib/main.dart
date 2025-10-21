// Flutter & Dart packages
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:smart_list/presentation/screens/products_page.dart';

// Core
import 'core/services/sync_service.dart';
import 'core/network/network_info.dart';

// Data sources
import 'data/sqlLite_datasource/product_local_datasource.dart';
import 'data/api_datasource/product_api_datasource.dart';

// Repository implementations
import 'data/implements/product_local_repository_implement.dart';
import 'data/implements/product_remote_repository_implement.dart';

// Use cases
import 'use_cases/product_use_cases.dart';

//fonts
import 'package:google_fonts/google_fonts.dart';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final networkInfo = NetworkInfoImpl(Connectivity());

  // --- Inicializar repositorios, usecases y SyncService ---
  final remoteProductDataSource = ProductApiDataSource();
  final productRemoteRepository = ProductRepositoryImpl(
    dataSource: remoteProductDataSource,
  );
  final fetchProductsUseCase = FetchProductsUseCase(
    repository: productRemoteRepository,
  );

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
  final addProductUseCase = AddProductUseCase(
    repository: productLocalRepository,
  );
  final checkProductExistsUseCase = CheckProductExistsUseCase(
    repository: productLocalRepository,
  );
  final deleteLocalProductUseCase = DeleteLocalProductUseCase(
    repository: productLocalRepository,
  );
  final deleteRemoteProductUseCase = DeleteRemoteProductUseCase(
    repository: productRemoteRepository,
  );
  final getSoftDeletedProductsUseCase = GetSoftDeletedProductsUseCase(
    repository: productLocalRepository,
  );
  final softDeleteLocalProductUseCase = SoftDeleteLocalProductUseCase(
    repository: productLocalRepository,
  );
  final saveRemoteProductUseCase = SaveProductUseCase(
    repository: productRemoteRepository,
  );
  final getUnsyncedProductsUseCase = GetUnsyncedProductsUseCase(
    repository: productLocalRepository,
  );
  final updateLocalProductUseCase = UpdateLocalProductUseCase(
    repository: productLocalRepository,
  );
  final remoteProductExistsUseCase = RemoteProductExistsUseCase(
    repository: productRemoteRepository,
  );
  final updateRemoteProductUseCase = UpdateRemoteProductUseCase(
    repository: productRemoteRepository,
  );

  final syncService = SyncService(
    networkInfo: networkInfo,
    cacheProductsUseCase: cacheProductsUseCase,
    fetchProductsUseCase: fetchProductsUseCase,
    getSoftDeletedProductsUseCase: getSoftDeletedProductsUseCase,
    deleteRemoteProductUseCase: deleteRemoteProductUseCase,
    deleteLocalProductUseCase: deleteLocalProductUseCase,
    saveProductUseCase: saveRemoteProductUseCase,
    getUnsyncedProductsUseCase: getUnsyncedProductsUseCase,
    remoteProductExistsUseCase: remoteProductExistsUseCase,
    updateRemoteProductUseCase: updateRemoteProductUseCase,
  );

  // --- Ejecutar sincronización ---
  await performSync(syncService, networkInfo);

  runApp(
    MyApp(
      getCachedProductsUseCase: getCachedProductsUseCase,
      addProductUseCase: addProductUseCase,
      checkProductExistsUseCase: checkProductExistsUseCase,
      softDeleteLocalProductUseCase: softDeleteLocalProductUseCase,
      deleteRemoteProductUseCase: deleteRemoteProductUseCase,
      updateLocalProductUseCase: updateLocalProductUseCase,
    ),
  );
}

Future<void> performSync(
  SyncService syncService,
  NetworkInfo networkInfo,
) async {
  if (await networkInfo.isConnected) {
    print('Sincronizando productos con la API...');
    await syncService.getAndSaveProducts();
    await syncService.sendProductsToApi();
    await syncService.deleteProductsFromApi();
  } else {
    print('No hay conexión a internet. Operaciones remotas omitidas.');
  }

  // Esto se hace siempre, no necesita internet
  await syncService.deleteProductsFromLocal();

}

void deleteDatabaseIfExists() async {
  final path = join(await getDatabasesPath(), 'my_app.db');
  await deleteDatabase(path);

  //print('base de datos eliminada');
}

class MyApp extends StatelessWidget {
  final GetCachedProductsUseCase getCachedProductsUseCase;
  final AddProductUseCase addProductUseCase;
  final CheckProductExistsUseCase checkProductExistsUseCase;
  final SoftDeleteLocalProductUseCase softDeleteLocalProductUseCase;
  final DeleteRemoteProductUseCase deleteRemoteProductUseCase;
  final UpdateLocalProductUseCase updateLocalProductUseCase;

  const MyApp({
    super.key,
    required this.getCachedProductsUseCase,
    required this.addProductUseCase,
    required this.checkProductExistsUseCase,
    required this.softDeleteLocalProductUseCase,
    required this.deleteRemoteProductUseCase,
    required this.updateLocalProductUseCase,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ProductCard',
      theme: ThemeData(
        textTheme: GoogleFonts.robotoTextTheme(Theme.of(context).textTheme),
      ),
      home: Scaffold(
        body: ProductsPage(
          getCachedProductsUseCase: getCachedProductsUseCase,
          addProductUseCase: addProductUseCase,
          checkProductExistsUseCase: checkProductExistsUseCase,
          softDeleteLocalProductUseCase: softDeleteLocalProductUseCase,
          deleteRemoteProductUseCase: deleteRemoteProductUseCase,
          updateLocalProductUseCase: updateLocalProductUseCase,
        ),
      ),
    );
  }
}
