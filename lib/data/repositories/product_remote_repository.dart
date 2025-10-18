import '../../domain/product.dart';
abstract class ProductRemoteRepository{
  Future<List<Product>> fetchProducts();
}

