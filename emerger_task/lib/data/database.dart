import 'package:emerger_task/models/photo_model.dart';
//ignore: depend_on_referenced_packages
import 'package:path/path.dart';

import 'package:sqflite/sqflite.dart';

class DatabaseManager {
  Database? _database;

  Future openDb() async {
    _database = await openDatabase(join(await getDatabasesPath(), "photos.db"),
        version: 1, onCreate: (Database db, int version) async {
      await db.execute(
        "CREATE TABLE photo (id INTEGER PRIMARY KEY, albumId INTEGER, title TEXT, url TEXT, thumbnailURL TEXT)",
      );
    });
    return _database;
  }

  Future<int?> insertData(List<PhotoModel> photoModels) async {
    int? result = 0;
    await openDb();
    for (var photoModel in photoModels) {
      result = await _database?.insert('photo', photoModel.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    return result;
  }

  Future<List<PhotoModel>> getDataList() async {
    await openDb();
    final List<Map<String, dynamic>> maps =
        await _database!.rawQuery('SELECT * FROM photo');

    return List.generate(maps.length, (i) {
      print(i);
      return PhotoModel(
          id: maps[i]['id'],
          albumId: maps[i]['albumId'],
          title: maps[i]['title'],
          url: maps[i]['url'],
          thumbnailUrl: maps[i]['thumbnailURL']);
    });
  }

  Future<void> close(Database db) async {
    await db.close();
  }
}
