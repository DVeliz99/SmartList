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
          'is_deleted': 0,
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
      final List<Map<String, dynamic>> maps = await db.query(
        'products',
        where: 'is_deleted = ?',
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
    } catch (error) {
      throw DatabaseFailure('Error al obtener productos de la cache: $error');
    }
  }

  @override
  Future<List<Product>> getSoftDeletedProducts() async {
    final db = await _sqliteConfig.database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'products',
        where: 'is_deleted = ?',
        whereArgs: [1],
      );

      final products = maps.map((map) {
        return Product(
          id: map['id'],
          name: map['name'],
          data: map['data'] != null ? jsonDecode(map['data']) : null,
        );
      }).toList();
      return products;
    } catch (error) {
      throw DatabaseFailure(
        'Error al obtener productos eliminados de la cache: $error',
      );
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
        'is_deleted': 0,
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

  @override
  Future<bool> productExists(String id) async {
    final db = await _sqliteConfig.database;

    try {
      final List<Map<String, dynamic>> product = await db.query(
        'products',
        where: 'id = ?',
        whereArgs: [id],
      );

      return product.isNotEmpty;
    } catch (error) {
      throw DatabaseFailure(
        'Error al verificar existencia del producto: $error',
      );
    }
  }

  @override
  Future<Product> softDeleteProduct(String id) async {
    final db = await _sqliteConfig.database;

    // Verifica que el producto exista
    final resultProductExists = await productExists(id);
    if (!resultProductExists) {
      throw DatabaseFailure('Producto con id $id no encontrado');
    }

    try {
      // Actualiza el campo is_deleted a 1
      await db.update(
        'products',
        {'is_deleted': 1},
        where: 'id = ?',
        whereArgs: [id],
      );

      // Retorna el producto actualizado
      final List<Map<String, dynamic>> maps = await db.query(
        'products',
        where: 'id = ?',
        whereArgs: [id],
      );

      final productMap = maps.first;
      return Product(
        id: productMap['id'],
        name: productMap['name'],
        data: productMap['data'] != null
            ? jsonDecode(productMap['data'])
            : null,
      );
    } catch (error) {
      throw DatabaseFailure('Error al eliminar producto: $error');
    }
  }

  @override
  Future<Product> deleteProduct(Product product) async {
    final db = await _sqliteConfig.database;

    try {
      // Usamos batch para eliminar
      final batch = db.batch();

      batch.delete('products', where: 'id = ?', whereArgs: [product.id]);

      await batch.commit(noResult: true);

      return product;
    } catch (e) {
      throw DatabaseFailure('Error al eliminar productos: $e');
    }
  }

  @override
  Future<Product> updateProduct(Product product) async {
    final db = await _sqliteConfig.database;
    try {
      await db.update(
        'products',
        {
          'name': product.name,
          'data': jsonEncode(product.data), // se guarda como JSON
          'is_synced': 0, 
        },
        where: 'id = ?',
        whereArgs: [product.id],
      );

      final List<Map<String, dynamic>> maps = await db.query(
        'products',
        where: 'id = ?',
        whereArgs: [product.id],
        limit: 1,
      );

      if (maps.isNotEmpty) {
        final updated = maps.first;
        return Product(
          id: updated['id'],
          name: updated['name'],
          data: updated['data'] != null ? jsonDecode(updated['data']) : null,
        );
      } else {
        throw DatabaseFailure(
          'Producto no encontrado después de la actualización',
        );
      }
    } catch (e) {
      throw DatabaseFailure('Error al actualizar producto: $e');
    }
  }
}
