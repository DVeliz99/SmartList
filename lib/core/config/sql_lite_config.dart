import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// configuración de la base de datos SQLite
class SqliteConfig {
  static final SqliteConfig _instance = SqliteConfig._internal();
  factory SqliteConfig() => _instance;
  SqliteConfig._internal();

  static Database? _database;
  // Obtener la instancia de la base de datos
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Inicializar la base de datos
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'my_app.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  // Crear la tabla products al crear la base de datos
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE products(
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      data TEXT,
      is_synced INTEGER NOT NULL DEFAULT 1,
      is_deleted INTEGER NOT NULL DEFAULT 0
    )
  ''');
  }
}
