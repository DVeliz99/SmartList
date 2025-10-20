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
  final addProductUseCase = AddProductUseCase(
    repository: productLocalRepository,
  );

  //Instancia del servicio de sincronización
  final syncService = SyncService(
    networkInfo: networkInfo,
    cacheProductsUseCase: cacheProductsUseCase,
    fetchProductsUseCase: fetchProductsUseCase,
  );

  assert(
    addProductUseCase != null,
    'addProductUseCase no se inicializó correctamente',
  );
  assert(
    getCachedProductsUseCase != null,
    'getCachedProductsUseCase no se inicializó correctamente',
  );


  await syncService.getAndSaveProducts();

  runApp(
    MyApp(
      getCachedProductsUseCase: getCachedProductsUseCase,
      addProductUseCase: addProductUseCase,
    ),
  );
}

class MyApp extends StatelessWidget {
  final GetCachedProductsUseCase getCachedProductsUseCase;
  final AddProductUseCase addProductUseCase;

  const MyApp({
    super.key,
    required this.getCachedProductsUseCase,
    required this.addProductUseCase,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo ProductCard',
      theme: ThemeData(
        textTheme: GoogleFonts.robotoTextTheme(Theme.of(context).textTheme),
      ),
      home: Scaffold(
       
        body: ProductsPage(
          getCachedProductsUseCase: getCachedProductsUseCase,
          addProductUseCase: addProductUseCase,
        ),
      ),
    );
  }
}
