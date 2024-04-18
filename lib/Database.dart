import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqlite_api.dart';

class Event
{
  String title_;
  DateTime dt_;
  bool complite_;
  Event(this.title_, this.dt_, this.complite_);
}

class DBProvider {

  DBProvider._();

  static final DBProvider db = DBProvider._();

  // late Database _database;

  // Future<Database> get database async {
  //   if (_database != null) return _database;
  //   _database = await initDB();
  //   return _database;
  //   // // if _database is null we instantiate it
  //   // _database = await initDB();
  //   // return _database;
  // }

  // initDB() async {
  //   Directory documentsDirectory = await getApplicationDocumentsDirectory();
  //   String path = join(documentsDirectory.path, "internal.db");
  //   print("init start");
  //   return await openDatabase(path, version: 1, onOpen: (db) {},
  //       onCreate: (Database db, int version) async {
  //     await db.execute("CREATE TABLE Events ("
  //         "event_id_ INTEGER PRIMARY KEY,"
  //         "title_ TEXT,"
  //         "year_ INTEGER,"
  //         "month_ INTEGER,"
  //         "day_ INTEGER,"
  //         "complite_ INTEGER"
  //         ")");
  //   });
  // }

  Future<Database> initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, "internal.db");
    final exist = await databaseExists(path);

    if (exist) {
      print("Exist");
    }else{
      print("Not exist");

      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String path = join(documentsDirectory.path, "internal.db");
      print("init start");
      return await openDatabase(path, version: 1, onOpen: (db) {},
          onCreate: (Database db, int version) async {
        await db.execute("CREATE TABLE Events ("
            "title TEXT,"
            "year INTEGER,"
            "month INTEGER,"
            "day INTEGER,"
            "complite INTEGER"
            ")");
      });

      // try {
      //   await Directory(dirname(path)).create(recursive: true);
      // } catch (e) {
      //   ByteData data = await rootBundle.load(join("assets", "internal.db"));
      //   List<int> bytes = data.buffer.asInt8List(data.offsetInBytes, data.lengthInBytes);

      //   await File(path).writeAsBytes(bytes, flush: true);
      //   print("copied!");
      // }
    }
    Database db = await openDatabase(path);
    print(db.isOpen.toString());
    return db;
  }

  Future<void> addTask(DateTime dt, String title) async {
    final db = await initDB();
    db.execute(
      "INSERT INTO Events(title,year,month,day,complite) VALUES("
      "\"$title\","
      "${dt.year},"
      "${dt.month},"
      "${dt.day},"
      "0);"
    );
  }
  
  Future<List<Map<String, Object?>>> getEvents(DateTime dt) async {
    final db = await initDB();
    var an = await db.rawQuery("SELECT * FROM Events WHERE day=${dt.day} AND month=${dt.month} AND year=${dt.year};");
    return an.toList();
  }

  Future<void> setState(DateTime dt, String title, int currentState) async {
    final db = await initDB();
    db.execute("UPDATE Events SET complite=$currentState WHERE day=${dt.day} AND month=${dt.month} AND year=${dt.year} AND title=\"$title\";");
  }
}