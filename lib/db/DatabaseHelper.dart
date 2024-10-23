import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:proyeksregep/models/ImagesData.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;

  DatabaseHelper._();

  factory DatabaseHelper() => instance; // Return the existing instance

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'images.db');
    return openDatabase(
      path,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE images(id INTEGER PRIMARY KEY AUTOINCREMENT, imagePath TEXT, usia TEXT, jenisKulit TEXT, kandungan TEXT)',
        );
      },
      version: 1,
    );
  }

  // Insert image data
  Future<void> insertImageData(ImageData imageData) async {
    final db = await database;
    await db.insert('images', imageData.toMap());
  }

  // Retrieve all images
  Future<List<ImageData>> getAllImages() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('images');
    return List.generate(maps.length, (i) {
      return ImageData.fromMap(maps[i]);
    });
  }
}
