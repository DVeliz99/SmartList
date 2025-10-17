import 'package:smart_list/data/api_datasource/product_api_datasource.dart';
import 'package:smart_list/data/implements/product_repository_implement.dart';
import 'package:smart_list/use_cases/product_use_cases.dart';

void main() async {
  final dataSource = ProductApiDataSource();
  final repository = ProductRepositoryImpl(dataSource: dataSource);
  final fetchProductsUseCase = FetchProductsUseCase(repository: repository);

  final result = await fetchProductsUseCase();
}

