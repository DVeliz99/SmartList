// Flutter & Dart packages
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:google_fonts/google_fonts.dart';
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

// Database utils
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialización de conectividad y fuentes de datos
  final networkInfo = NetworkInfoImpl(Connectivity());
  final remoteProductDataSource = ProductApiDataSource();
  final localProductDataSource = ProductLocalDatasource();

  // Repositorios
  final productRemoteRepository =
      ProductRepositoryImpl(dataSource: remoteProductDataSource);
  final productLocalRepository =
      ProductLocalRepositoryImpl(dataSource: localProductDataSource);

  // Casos de uso locales
  final getCachedProductsUseCase =
      GetCachedProductsUseCase(repository: productLocalRepository);
  final addProductUseCase =
      AddProductUseCase(repository: productLocalRepository);
  final checkProductExistsUseCase =
      CheckProductExistsUseCase(repository: productLocalRepository);
  final softDeleteLocalProductUseCase =
      SoftDeleteLocalProductUseCase(repository: productLocalRepository);
  final deleteLocalProductUseCase =
      DeleteLocalProductUseCase(repository: productLocalRepository);
  final getUnsyncedProductsUseCase =
      GetUnsyncedProductsUseCase(repository: productLocalRepository);
  final getSoftDeletedProductsUseCase =
      GetSoftDeletedProductsUseCase(repository: productLocalRepository);
  final updateLocalProductUseCase =
      UpdateLocalProductUseCase(repository: productLocalRepository);
  final cacheProductsUseCase =
      CacheProductsUseCase(repository: productLocalRepository);

  // Casos de uso remotos
  final fetchProductsUseCase =
      FetchProductsUseCase(repository: productRemoteRepository);
  final saveRemoteProductUseCase =
      SaveProductUseCase(repository: productRemoteRepository);
  final deleteRemoteProductUseCase =
      DeleteRemoteProductUseCase(repository: productRemoteRepository);
  final remoteProductExistsUseCase =
      RemoteProductExistsUseCase(repository: productRemoteRepository);
  final updateRemoteProductUseCase =
      UpdateRemoteProductUseCase(repository: productRemoteRepository);

  // Servicio de sincronización
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

  // Inicia la app inmediatamente (sin bloquear el UI thread)
  runApp(
    MyApp(
      getCachedProductsUseCase: getCachedProductsUseCase,
      addProductUseCase: addProductUseCase,
      checkProductExistsUseCase: checkProductExistsUseCase,
      softDeleteLocalProductUseCase: softDeleteLocalProductUseCase,
      deleteRemoteProductUseCase: deleteRemoteProductUseCase,
      updateLocalProductUseCase: updateLocalProductUseCase,
      syncService: syncService,
      networkInfo: networkInfo,
    ),
  );
}

/// Borra la base de datos local si es necesario (para depuración)
Future<void> deleteDatabaseIfExists() async {
  final path = join(await getDatabasesPath(), 'my_app.db');
  await deleteDatabase(path);
  // print('Base de datos eliminada');
}

/// Widget raíz de la aplicación
class MyApp extends StatefulWidget {
  final GetCachedProductsUseCase getCachedProductsUseCase;
  final AddProductUseCase addProductUseCase;
  final CheckProductExistsUseCase checkProductExistsUseCase;
  final SoftDeleteLocalProductUseCase softDeleteLocalProductUseCase;
  final DeleteRemoteProductUseCase deleteRemoteProductUseCase;
  final UpdateLocalProductUseCase updateLocalProductUseCase;
  final SyncService syncService;
  final NetworkInfo networkInfo;

  const MyApp({
    super.key,
    required this.getCachedProductsUseCase,
    required this.addProductUseCase,
    required this.checkProductExistsUseCase,
    required this.softDeleteLocalProductUseCase,
    required this.deleteRemoteProductUseCase,
    required this.updateLocalProductUseCase,
    required this.syncService,
    required this.networkInfo,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isSyncing = true;

  @override
  void initState() {
    super.initState();
    _startBackgroundSync();
  }

  /// Sincroniza los productos en segundo plano (sin bloquear el main thread)
  Future<void> _startBackgroundSync() async {
    Future.microtask(() async {
      try {
        if (await widget.networkInfo.isConnected) {
          await Future.wait([
            widget.syncService.getAndSaveProducts(),
            widget.syncService.sendProductsToApi(),
            widget.syncService.deleteProductsFromApi(),
          ]);
        }
        await widget.syncService.deleteProductsFromLocal();
      } catch (e) {
        // print('Error durante la sincronización: $e');
      } finally {
        if (mounted) {
          setState(() => _isSyncing = false);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart List',
      theme: ThemeData(
        textTheme: GoogleFonts.robotoTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: _isSyncing
          ? const SplashScreen()
          : ProductsPage(
              getCachedProductsUseCase: widget.getCachedProductsUseCase,
              addProductUseCase: widget.addProductUseCase,
              checkProductExistsUseCase: widget.checkProductExistsUseCase,
              softDeleteLocalProductUseCase:
                  widget.softDeleteLocalProductUseCase,
              deleteRemoteProductUseCase: widget.deleteRemoteProductUseCase,
              updateLocalProductUseCase: widget.updateLocalProductUseCase,
            ),
    );
  }
}

/// Pantalla temporal mientras se sincroniza
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              'Sincronizando datos...',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
