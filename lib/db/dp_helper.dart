import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '/models/task.dart';
class DBHelper {

  static Database? _db;
  static const int _version = 1;
  static const String _tableName = "tasks";

  static Future<void> initDB() async{
    if(_db != null){
      debugPrint("not null database");
      return;
    }
    else {
      try {
        String _path = await getDatabasesPath() + "task.db";
        print("in database path");
        _db = await openDatabase(_path, version: 1,
        onCreate: (Database db, int version) async {
          // When creating the db, create the table
          debugPrint("creating a new one");
          await db.execute(
              'CREATE TABLE $_tableName ('
              'id INTEGER PRIMARY KEY AUTOINCREMENT, '
              'title STRING, note TEXT, date STRING, '
              'startTime STRING, endTime STRING, '
              'remind INTEGER, repeat STRING, '
              'color INTEGER, '
              'isCompleted INTEGER)'
          );
        });
        print("database created");
      }
      catch (e){
        print(e);
      }
    }
  }

static Future<int> insert(Task? task) async{
    print("insert function called");
    return await _db!.insert(_tableName, task!.toJson());
}

  static Future<int> delete(Task? task) async{
    print("delete function called");
    return await _db!.delete(_tableName, where: 'id = ?', whereArgs: [task!.id]);
  }

  static Future<int> deleteAll() async{
    print("delete all function called");
    return await _db!.delete(_tableName);
  }

  static Future<List<Map<String, dynamic>>> query() async{
    print("query function");
    return await _db!.query(_tableName);
  }

  static Future<int> update(int? id) async{
    print("update");
    return await _db!.rawUpdate('''
    UPDATE tasks
    SET isCompleted = ?
    WHERE id = ?
     ''',[1,id!]);
  }

}