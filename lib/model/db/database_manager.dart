import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseManager {
  static final DatabaseManager shared = DatabaseManager._();
  late Future<Database> database;

  DatabaseManager._();

  Future<void> openDB() async {
    database = openDatabase(
      join(await getDatabasesPath(), 'sof_user_database.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE users(id INTEGER PRIMARY KEY, user_id INTEGER, display_name TEXT, profile_image TEXT, reputation INTEGER, location TEXT, creation_date INTEGER)",
        );
      },
      version: 1,
    );
  }
}
