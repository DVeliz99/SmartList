import '../../domain/product.dart';
abstract class ProductRemoteRepository{
  Future<List<Product>> fetchProducts();
   Future<List<Product>> saveProducts(List<Product> products);
}

