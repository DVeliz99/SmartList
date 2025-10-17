import '../repositories/product_repository.dart';
import '../../domain/product.dart';
import '../data_source/product_datasource.dart';

class ProductRepositoryImpl implements ProductRepository{
  final ProductDataSource dataSource;
  ProductRepositoryImpl({required this.dataSource});

  @override
  Future<List<Product>> fetchProducts() async{
    return await dataSource.fetchProducts();
  }

}