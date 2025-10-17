import '../../domain/product.dart';
abstract class ProductRepository{
  Future<List<Product>> fetchProducts();
}