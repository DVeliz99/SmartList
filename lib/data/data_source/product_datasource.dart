import '../../domain/product.dart';

abstract class ProductDataSource {
  Future<List<Product>> fetchProducts();

}