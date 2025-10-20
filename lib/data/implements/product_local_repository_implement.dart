import '../repositories/product_local_repository.dart';
import '../../domain/product.dart';
import '../data_source/product_local_datasource.dart';

class ProductLocalRepositoryImpl implements ProductLocalRepository {
  final ProductSqLiteDataSource dataSource;
  ProductLocalRepositoryImpl({required this.dataSource});

  @override
  Future<void> cacheProducts(List<Product> products) async {
    return await dataSource.cacheProducts(products);
  }

  @override
  Future<List<Product>> getCachedProducts() async {
    return await dataSource.getCachedProducts();
  }

  @override
  Future<Product> addProduct(Product product) async {
    return await dataSource.addProduct(product);
  }

  @override  
  Future<List<Product>> getUnsyncedProducts() async {
    return await dataSource.getUnsyncedProducts();
  }
}
