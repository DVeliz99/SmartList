import '../repositories/product_remote_repository.dart';
import '../../domain/product.dart';
import '../data_source/product_remote_datasource.dart';

class ProductRepositoryImpl implements ProductRemoteRepository {
  final ProductRemoteDataSource dataSource;
  ProductRepositoryImpl({required this.dataSource});

  @override
  Future<List<Product>> fetchProducts() async {
    return await dataSource.fetchProducts();
  }

  @override
  Future<Product> saveProduct(Product product) async {
    return await dataSource.saveProduct(product);
  }

  @override
  Future<Product> deleteProduct(String id) async {
    return await dataSource.deleteProduct(id);
  }

  @override
  Future<Product> productExists(Product product) async {
    return await dataSource.productExists(product);
  }

  @override
  Future<Product> updateProduct(Product product) async {
    return await dataSource.updateProduct(product);
  }
}
