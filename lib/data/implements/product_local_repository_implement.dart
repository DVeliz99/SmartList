import '../repositories/product_local_repository.dart';
import '../../domain/product.dart';
import '../data_source/product_local_datasource.dart';

class ProductLocalRepositoryImpl implements ProductLocalRepository{
  final ProductSqLiteDataSource dataSource;
  ProductLocalRepositoryImpl({required this.dataSource});

  @override
  Future<void> cacheProducts(List<Product> products) async{
   
    return await dataSource.cacheProducts(products);
  }

}


