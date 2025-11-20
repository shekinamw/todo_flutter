// lib/services/database_helper.dart

import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task.dart';

/// This class handles all SQLite database operations (CRUD).
/// It replaces the functionality found in MyDatabaseHelper.java [cite: uploaded file: MyDatabaseHelper.java].
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;
  static const String _tableName = 'my_tasks';
  // Database version matches the one in MyDatabaseHelper.java [cite: uploaded file: MyDatabaseHelper.java]
  static const int _databaseVersion = 2;

  // Column constants, mirroring MyDatabaseHelper.java [cite: uploaded file: MyDatabaseHelper.java]
  static const String _columnId = 'id';
  static const String _columnTitle = 'title';
  static const String _columnDescription = 'description';
  static const String _columnDeadline = 'deadline';
  static const String _columnColor = 'color';
  static const String _columnImage = 'imagePath'; // Mirrors COLUMN_IMAGE

  /// Initializes and returns the database instance.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Opens the database and creates the table if it doesn't exist.
  Future<Database> _initDatabase() async {
    // Get the path to the database file (replaces Context in native Android)
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'TaskList.db'); // Same name as in MyDatabaseHelper.java [cite: uploaded file: MyDatabaseHelper.java]

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Called when the database is created for the first time.
  void _onCreate(Database db, int version) async {
    final String createTableQuery = '''
      CREATE TABLE $_tableName (
        $_columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $_columnTitle TEXT NOT NULL,
        $_columnDescription TEXT,
        $_columnDeadline TEXT,
        $_columnColor TEXT,
        $_columnImage TEXT
      )
    ''';
    await db.execute(createTableQuery);
  }

  /// Handles database schema upgrades (e.g., adding the image column).
  /// Mirrors the onUpgrade logic in MyDatabaseHelper.java [cite: uploaded file: MyDatabaseHelper.java].
  void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add the new image column (COLUMN_IMAGE / imagePath)
      await db.execute('ALTER TABLE $_tableName ADD COLUMN $_columnImage TEXT');
    }
  }

  // --- CRUD OPERATIONS ---

  /// INSERT - Adds a new task to the database.
  Future<int> addTask(Task task) async {
    final db = await database;
    // Uses the task.toMap() from the Task model
    return await db.insert(_tableName, task.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// READ - Retrieves all tasks from the database.
  Future<List<Task>> getAllTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_tableName, orderBy: '$_columnId DESC');

    // Convert the List<Map> into a List<Task>
    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }

  /// UPDATE - Updates an existing task.
  Future<int> updateTask(Task task) async {
    final db = await database;
    // We update using the task's existing ID
    return await db.update(
      _tableName,
      task.toMap(),
      where: '$_columnId = ?',
      whereArgs: [task.id],
    );
  }

  /// DELETE - Deletes a single task by ID.
  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete(
      _tableName,
      where: '$_columnId = ?',
      whereArgs: [id],
    );
  }

  /// DELETE - Deletes all tasks (mirrors deleteAllTasks in MyDatabaseHelper.java) [cite: uploaded file: MyDatabaseHelper.java].
  Future<int> deleteAllTasks() async {
    final db = await database;
    return await db.delete(_tableName);
  }
}