// Flutter & Dart packages
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:smart_list/core/error/result.dart';
import 'package:smart_list/presentation/widgets/app_bar.dart';
import 'package:smart_list/presentation/widgets/form.dart';

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

// Domain models
import 'domain/product.dart';

// Presentation / Widgets
import 'presentation/widgets/product_card.dart';

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

  runApp(MyApp(getCachedProductsUseCase: getCachedProductsUseCase));
}

class MyApp extends StatelessWidget {
  final GetCachedProductsUseCase getCachedProductsUseCase;

  const MyApp({super.key, required this.getCachedProductsUseCase});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo ProductCard',
      theme: ThemeData(
        textTheme: GoogleFonts.robotoTextTheme(Theme.of(context).textTheme),
      ),
      home: Scaffold(
        appBar: CustomShoppingAppBar(),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              ProductForm(
                product: Product(
                  id: '0',
                  name: 'Producto de prueba',
                  data: {'price': 0.0},
                ),
                onSave: () {},
                actionLabel: 'Agregar',
              ),
              
              const SizedBox(height: 12),
              Expanded(
                child: FutureBuilder<Result<List<Product>>>(
                  future: getCachedProductsUseCase.call(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    final result = snapshot.data;
                    if (result == null ||
                        result.isFailure ||
                        result.data == null) {
                      return Center(
                        child: Text(
                          'No hay productos: ${result?.failure?.message ?? ''}',
                        ),
                      );
                    }
                    final products = result.data!;

                    return ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: ProductCard(
                            product: product,
                            onEdit: () {},
                            onDelete: () {},
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
