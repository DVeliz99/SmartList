
import 'package:smart_list/domain/product.dart';

abstract class ProductSqLiteDataSource {
  Future<void> cacheProducts(List<Product> products);
  Future<List<Product>> getCachedProducts();
  Future<Product> addProduct(Product product);
  Future<List<Product>> getUnsyncedProducts();
}