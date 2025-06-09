import 'dart:developer';
import 'dart:io';

import 'package:note_keeper/models/note_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper = DatabaseHelper._createInstance();
  static Database? _database;

  String tableName = "note_table";
  String colId = "id";
  String colTitle = "title";
  String colDescription = "description";
  String colPriority = "priority";
  String colDate = "date";

  DatabaseHelper._createInstance();

  // factory constructor to return the instance
  factory DatabaseHelper() {
    _databaseHelper = DatabaseHelper._createInstance();
    return _databaseHelper;
  }

  // getter function for database
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    } else {
      _database = await initializeDb();
      return _database!;
    }
  }

  // create function that creates database
  void _createDb(Database db, int newVersion) async {
    await db.execute(
      "CREATE TABLE $tableName ($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colDescription TEXT, $colPriority INTEGER, $colDate TEXT)",
    );
  }

  // function that initialize database by taking the path form the directory of the device and open database then return it ;
  Future<Database> initializeDb() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = "${directory.path}note.db";
    log(path);
    var noteDatabase = await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
    return noteDatabase;
  }

  // function that fetches all datas from the database
  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db = await database;

    final result = await db.query(tableName, orderBy: "$colPriority ASC");
    return result;
  }

  // function that insert data to the database
  Future<int> insertNote(NoteModel note) async {
    Database db = await database;
    final result = await db.insert(tableName, note.toMap());
    return result;
  }

  // function that delete a data by its id from the database
  Future<int> deleteNote(int? id) async {
    Database db = await database;
    final result = await db.delete(
      tableName,
      where: "$colId = ?",
      whereArgs: [id],
    );
    return result;
  }

  // update function to update the db
  Future<int> updataNote(NoteModel note) async {
    Database db = await database;
    final result = await db.update(
      tableName,
      note.toMap(),
      where: "$colId = ?",
      whereArgs: [note.id],
    );
    return result;
  }

  // function that read only one by its id
  Future<NoteModel?> getNoteById(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: "$colId = ?",
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      log("${NoteModel.fromMap(maps.first)}");
      return NoteModel.fromMap(maps.first);
    } else {
      return null;
    }
  }

  // get the number of objects in database
  Future<int?> getCount() async {
    Database db = await database;
    List<Map<String, dynamic>> x = await db.rawQuery(
      "SELECT COUNT (*) FROM $tableName",
    );
    int? result = Sqflite.firstIntValue(x);

    return result;
  }
}
