import '../repositories/product_local_repository.dart';
import '../../domain/product.dart';
import '../data_source/product_local_datasource.dart';

//Implementación de recursos locales
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

  @override
  Future<bool> productExists(String id) async {
    return await dataSource.productExists(id);
  }

  @override
  Future<Product> softDeleteProduct(String id) async {
    return await dataSource.softDeleteProduct(id);
  }

  @override
  Future<List<Product>> getSoftDeletedProducts() async {
    return await dataSource.getSoftDeletedProducts();
  }

  @override
  Future<Product> deleteProduct(Product product) async {
    return await dataSource.deleteProduct(product);
  }

  @override
  Future<Product> updateProduct(Product product) async {
    return await dataSource.updateProduct(product);
  }
}
