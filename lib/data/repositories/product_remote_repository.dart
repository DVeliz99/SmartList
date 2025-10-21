import '../../domain/product.dart';

abstract class ProductRemoteRepository {
  Future<List<Product>> fetchProducts();
  Future<Product> saveProduct(Product product);
  Future<Product> deleteProduct(String id);
  Future<Product> productExists(Product product);
  Future<Product> updateProduct(Product product);
  
}
