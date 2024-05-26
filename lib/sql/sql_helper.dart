import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""
      CREATE TABLE IF NOT EXISTS items(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        name TEXT,
        location TEXT,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
      """);

    await database.execute("""
      CREATE TABLE IF NOT EXISTS details(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        department TEXT,
        role TEXT,
        salary TEXT,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        item_id INTEGER,
        FOREIGN KEY (item_id) REFERENCES items (id)
      )
      """);
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'database',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  static Future<int> createItem(String name, String? location) async {
    final db = await SQLHelper.db();
    final data = {'name': name, 'location': location};
    final id = await db.insert('items', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<List<Map<String, dynamic>>> getItemsWithDetails() async {
    final db = await SQLHelper.db();
    return db.rawQuery('''
      SELECT items.id, items.name, items.location, items.createdAt as itemCreatedAt,
             details.department, details.role, details.salary, details.createdAt as detailsCreatedAt
      FROM items
      LEFT JOIN details ON items.id = details.item_id
      ORDER BY items.id
    ''');
  }

  static Future<int> updateItem(int id, String name, String? location) async {
    final db = await SQLHelper.db();
    final data = {
      'name': name,
      'location': location,
      'createdAt': DateTime.now().toString()
    };
    final result =
        await db.update('items', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  static Future<void> deleteItem(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete("items", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }

  static Future<void> deleteAllItems() async {
    final db = await SQLHelper.db();
    try {
      await db.delete("items");
    } catch (err) {
      debugPrint("Something went wrong when deleting all items: $err");
    }
  }
}
