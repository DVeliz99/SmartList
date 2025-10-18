import 'dart:convert';
import 'package:smart_list/data/data_source/product_local_datasource.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/error/failure.dart';
import '../../domain/product.dart';
import '../../core/config/sql_lite_config.dart';

class ProductLocalDatasource implements ProductSqLiteDataSource {
  final SqliteConfig _sqliteConfig = SqliteConfig();

  /// Guarda una lista completa de productos en la base de datos
  @override
  Future<void> cacheProducts(List<Product> products) async {
    final db = await _sqliteConfig.database;

    final batch = db.batch(); // usar batch para eficiencia
    for (var product in products) {
      batch.insert(
        'products',
        {
          'id': product.id
              .toString(), // si tu id es int, conviene pasarlo a String
          'name': product.name,
          'data': product.data != null ? jsonEncode(product.data) : null,
          'is_synced': 1,
        },
        conflictAlgorithm: ConflictAlgorithm.replace, // reemplaza si ya existe
      );
    }

    try {
      await batch.commit(noResult: true);
    } catch (e) {
      throw DatabaseFailure('Error al guardar productos en cache: $e');
    }
  }
}
