import 'dart:async';
import '../models/task.dart';

// IMPORTANT: This class is a mock implementation of a database helper
// (like MyDatabaseHelper.java) using an in-memory list, as real SQLite
// cannot be used in this environment.
class DatabaseHelper {
  // Private static list to hold task data (simulates the database table)
  static final List<Task> _tasks = [];
  static int _nextId = 1; // Counter for primary key simulation

  // Singleton setup
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper _instance = DatabaseHelper._privateConstructor();

  factory DatabaseHelper() {
    return _instance;
  }

  // Utility to simulate network/database delay
  Future<void> _simulateDelay() async {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  // --- CRUD Operations ---

  /// CREATE: Inserts a new task into the "database".
  Future<int> insertTask(Task task) async {
    await _simulateDelay();
    // Assign new ID
    final newId = _nextId++;
    final newTask = Task(
      id: newId,
      title: task.title,
      deadline: task.deadline,
      description: task.description,
      color: task.color,
      imagePath: task.imagePath,
    );
    _tasks.add(newTask);
    return newId;
  }

  /// READ: Fetches all tasks from the "database".
  Future<List<Task>> getAllTasks() async {
    await _simulateDelay();
    // Return a copy of the list
    return List.from(_tasks);
  }

  /// UPDATE: Updates an existing task by ID.
  Future<int> updateTask(Task task) async {
    await _simulateDelay();
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      return 1; // Success
    }
    return 0; // Failure
  }

  /// DELETE: Deletes a task by ID.
  Future<int> deleteTask(int id) async {
    await _simulateDelay();
    final initialLength = _tasks.length;
    _tasks.removeWhere((t) => t.id == id);
    return initialLength > _tasks.length ? 1 : 0; // 1 if removed, 0 otherwise
  }
}