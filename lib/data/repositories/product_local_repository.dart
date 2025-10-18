
import 'package:smart_list/domain/product.dart';

abstract class ProductLocalRepository{
  Future<void> cacheProducts(List<Product> products);
}

