
import 'package:smart_list/domain/product.dart';

abstract class ProductSqLiteDataSource {
  Future<void> cacheProducts(List<Product> products);
}