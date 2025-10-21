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
      throw ApiFailure(
        'Error en la respuesta de la API: ${response.statusCode}',
      );
    }
  }

  @override
  Future<Product> saveProduct(Product product) async {
    final response = await http
        .post(
          Uri.parse(ApiConfig.baseUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(product.toJson()),
        )
        .timeout(Duration(milliseconds: ApiConfig.timeout));

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return product;
    } else {
      throw ApiFailure(
        'Error al guardar producto ${product.name}: ${response.statusCode}',
      );
    }
  }

  @override
  Future<Product> deleteProduct(String id) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/$id');

    final response = await http
        .delete(uri, headers: ApiConfig.headers)
        .timeout(Duration(milliseconds: ApiConfig.timeout));

    if (response.statusCode == 200 || response.statusCode == 204) {
      // Opcional: leer mensaje de la API para debug
      if (response.body.isNotEmpty) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print('Mensaje API: ${data['message']}');
      }

      // se retorna el id del producto eliminado
      return Product(id: id, name: '', data: {});
    } else {
      throw ApiFailure(
        'Error al eliminar producto con id $id: ${response.statusCode}',
      );
    }
  }
}
