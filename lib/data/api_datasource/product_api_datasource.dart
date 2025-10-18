import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_list/data/data_source/product_remote_datasource.dart';


import '../../domain/product.dart';
import '../../core/error/failure.dart';
import '../../core/config/api_config.dart';

class ProductApiDataSource implements ProductRemoteDataSource {
  //Obtener lista de productos desde la API
  
  @override
  Future<List<Product>> fetchProducts() async {
    final response = await http
        .get(Uri.parse(ApiConfig.baseUrl), headers: ApiConfig.headers)
        .timeout(Duration(milliseconds: ApiConfig.timeout));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((e) => Product.fromJson(e)).toList();
    } else {
      throw ApiFailure('Error en la respuesta de la API: ${response.statusCode}');
    }
  }
}

