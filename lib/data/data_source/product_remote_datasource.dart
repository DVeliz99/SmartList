import '../../domain/product.dart';

abstract class ProductRemoteDataSource {
  Future<List<Product>> fetchProducts();

}
