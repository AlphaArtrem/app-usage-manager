import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class TrackedAppsDatabase {

  static final _databaseName = "TrackedApps.db";
  static final _databaseVersion = 1;
  static final table = 'TrackingData';
  static final columnId = 'id';
  static final columnPackage = 'package';
  static final columnTime = 'time';

  // make it the only class
  TrackedAppsDatabase._privateConstructor();
  static final TrackedAppsDatabase instance = TrackedAppsDatabase._privateConstructor();

  // Create a reference to the database
  static Database _database;
  Future<Database> get database async {
    if (_database != null){
      return _database;
    }
    else{
      _database = await _initDatabase();
      return _database;
    }
  }

  // open database if it exists otherwise create a new one
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path, version: _databaseVersion, onCreate: _createTable);
  }

  // Creating new table
  Future _createTable(Database db, int version) async {
    await db.execute('''CREATE TABLE $table ($columnId INTEGER PRIMARY KEY, $columnPackage TEXT NOT NULL, $columnTime REAL NOT NULL)''');
  }

  // Create a new entry in table
  Future<int> addEntry(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  // Get all rows
  Future<List<Map<String, dynamic>>> getAllRows() async {
    Database db = await instance.database;
    return await db.query(table);
  }

  // Update a row with given column id
  Future<int> updateEntry(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[columnId];
    return await db.update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }

  // Delete a row with given column id
  Future<int> deleteRow(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }
}