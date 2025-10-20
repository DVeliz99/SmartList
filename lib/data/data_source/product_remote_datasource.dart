import '../../domain/product.dart';

abstract class ProductRemoteDataSource {
  Future<List<Product>> fetchProducts();
  Future<List<Product>> saveProducts(List<Product> products);
}
