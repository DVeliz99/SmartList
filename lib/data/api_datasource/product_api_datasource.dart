import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_list/data/data_source/product_datasource.dart';


import '../../domain/product.dart';
import '../../core/failure.dart';
import '../../core/api_config.dart';

class ProductApiDataSource implements ProductDataSource {
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

