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

  /// Obtiene la lista de productos almacenados en la base de datos local
  @override
  Future<List<Product>> getCachedProducts() async {
    final db = await _sqliteConfig.database;
    try {
      final List<Map<String, dynamic>> maps = await db.query('products');

      final products = maps.map((map) {
        return Product(
          id: map['id'],
          name: map['name'],
          data: map['data'] != null ? jsonDecode(map['data']) : null,
        );
      }).toList();
      return products;
    } catch (error) {
      throw DatabaseFailure('Error al obtener productos de la cache: $error');
    }
  }

  @override
  Future<Product> addProduct(Product product) async {
    final db = await _sqliteConfig.database;

    try {
      await db.insert('products', {
        'id': product.id.toString(),
        'name': product.name,
        'data': product.data != null ? jsonEncode(product.data) : null,
        'is_synced': 0,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
      return product;
    } catch (e) {
      throw DatabaseFailure('Error al agregar producto: $e');
    }
  }

  @override
  Future<List<Product>> getUnsyncedProducts() async {
    final db = await _sqliteConfig.database;

    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'products',
        where: 'is_synced = ?',
        whereArgs: [0],
      );

      final products = maps.map((map) {
        return Product(
          id: map['id'],
          name: map['name'],
          data: map['data'] != null ? jsonDecode(map['data']) : null,
        );
      }).toList();
      return products;
    } catch (e) {
      throw DatabaseFailure('Error al obtener productos no sincronizados: $e');
    }
  }
}
