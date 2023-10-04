import 'package:sqflite/sqflite.dart';
import 'package:stack_overflow_users_prototype_flutter/model/db/database_manager.dart';
import 'package:stack_overflow_users_prototype_flutter/model/response/user_response.dart';

class UserManager {
  static final shared = UserManager._();

  UserManager._();

  Future<void> insertUser(UserData user) async {
    final db = await DatabaseManager.shared.database;

    await db.insert(
      'users',
      user.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserData?> user(int accountId) async {
    final db = await DatabaseManager.shared.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: "id = ?",
      whereArgs: [accountId],
    );

    if (maps.isNotEmpty) {
      return UserData.fromJson(maps.first, fromDB: true);
    }

    return null;
  }

  Future<List<UserData>> users() async {
    final db = await DatabaseManager.shared.database;

    final List<Map<String, dynamic>> maps = await db.query('users');

    return List.generate(maps.length, (i) {
      return UserData.fromJson(maps[i], fromDB: true);
    });
  }

  Future<void> deleteUser(int accountId) async {
    final db = await DatabaseManager.shared.database;

    await db.delete(
      'users',
      where: "id = ?",
      whereArgs: [accountId],
    );
  }
}
