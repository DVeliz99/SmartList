import '../../domain/product.dart';

abstract class ProductRemoteDataSource {
  Future<List<Product>> fetchProducts();
  Future<Product> saveProduct(Product product);
  Future<Product> deleteProduct(String id);
}
