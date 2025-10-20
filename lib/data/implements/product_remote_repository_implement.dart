import '../repositories/product_remote_repository.dart';
import '../../domain/product.dart';
import '../data_source/product_remote_datasource.dart';

class ProductRepositoryImpl implements ProductRemoteRepository{
  final ProductRemoteDataSource dataSource;
  ProductRepositoryImpl({required this.dataSource});

  @override
  Future<List<Product>> fetchProducts() async{
    return await dataSource.fetchProducts();
  }

  @override
  Future<List<Product>>saveProducts(List<Product> products) async{
    return await dataSource.saveProducts(products);
  }

}


