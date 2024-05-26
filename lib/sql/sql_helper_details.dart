import 'package:sql_data_fatch/sql/sql_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SQLHelperDetails {
  // static Future<void> createTables(sql.Database database) async {
  //   await database.execute("""
  //     CREATE TABLE IF NOT EXISTS details(
  //       id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  //       department TEXT,
  //       role TEXT,
  //       salary TEXT,
  //       createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  //       item_id INTEGER,
  //       FOREIGN KEY (item_id) REFERENCES items (id)
  //     )
  //   """);
  // }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'database',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await SQLHelper.createTables(database);
      },
    );
  }

  static Future<int> createItem(
      String department, String? role, String? salary, int itemId) async {
    final db = await SQLHelperDetails.db();
    final data = {
      'department': department,
      'role': role,
      'salary': salary,
      'item_id': itemId
    };
    final id = await db.insert('details', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<int> updateItem(
      int id, String department, String? role, String? salary) async {
    final db = await SQLHelperDetails.db();
    final data = {
      'department': department,
      'role': role,
      'salary': salary,
      'createdAt': DateTime.now().toString()
    };
    final result =
        await db.update('details', data, where: "item_id = ?", whereArgs: [id]);
    return result;
  }

  static Future<void> deleteItem(int id) async {
    final db = await SQLHelperDetails.db();
    try {
      await db.delete("details", where: "item_id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }

  static Future<void> deleteAllDetails() async {
    final db = await SQLHelperDetails.db();
    try {
      await db.delete("details");
    } catch (err) {
      debugPrint("Something went wrong when deleting all details: $err");
    }
  }
}
