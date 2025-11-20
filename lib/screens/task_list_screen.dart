import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/database_helper.dart';
import 'new_task_screen.dart';
import '../widgets/task_card.dart';

/// Main task list screen with modern UI and search functionality
/// Manages task display, filtering, and user interactions
class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  // Database helper instance (singleton)
  final dbHelper = DatabaseHelper();

  // Task data management
  List<Task> _allTasks = []; // Complete list from database
  List<Task> _displayedTasks = []; // Filtered list shown in UI
  String _searchQuery = ''; // Current search query

  // Loading state for better UX
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  /// Fetches all tasks from the database and updates the UI
  void _loadTasks() async {
    setState(() => _isLoading = true);

    final tasks = await dbHelper.getAllTasks();

    if (mounted) {
      setState(() {
        _allTasks = tasks;
        _filterTasks(_searchQuery); // Apply current filter
        _isLoading = false;
      });
    }
  }

  /// Filters displayed tasks based on search query (searches in titles)
  void _filterTasks(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _displayedTasks = _allTasks;
    } else {
      final lowerCaseQuery = query.toLowerCase();
      _displayedTasks = _allTasks
          .where((task) => task.title.toLowerCase().contains(lowerCaseQuery))
          .toList();
    }

    if (mounted && _allTasks.isNotEmpty) {
      setState(() {});
    }
  }

  /// Navigates to the task creation/editing screen
  void _openNewTaskScreen({Task? task}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewTaskScreen(task: task),
      ),
    );

    // Reload list if task was added or updated
    if (result == true) {
      _loadTasks();
    }
  }

  /// Deletes a task after user confirmation
  void _deleteTask(int id) async {
    // Show modern confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Confirm Deletion'),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete this task? This action cannot be undone.',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          // Cancel button
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          // Delete button with emphasis
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    // Perform deletion if confirmed
    if (confirm == true) {
      await dbHelper.deleteTask(id);
      _loadTasks();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Task deleted successfully'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Light background for better contrast
      backgroundColor: Colors.grey[50],

      // Modern app bar with search functionality
      appBar: AppBar(
        title: const Text(
          'My To-Do List',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        // Search bar integrated into app bar
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70.0),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
            // Modern search field with glass-morphism effect
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() => _filterTasks(value));
                },
                style: TextStyle(color: Colors.grey[800]),
                decoration: InputDecoration(
                  hintText: 'Search tasks by title...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                  // Clear search button (appears when text is entered)
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.grey[600]),
                    onPressed: () {
                      setState(() => _filterTasks(''));
                    },
                  )
                      : null,
                  filled: true,
                  fillColor: Colors.transparent,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14.0,
                    horizontal: 16.0,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),

      // Main content area with loading and empty states
      body: _isLoading
          ? Center(
        // Loading indicator
        child: CircularProgressIndicator(
          color: Theme.of(context).primaryColor,
        ),
      )
          : _buildContent(),

      // Modern floating action button for adding tasks
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openNewTaskScreen(),
        icon: const Icon(Icons.add_rounded, size: 24),
        label: const Text(
          'New Task',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        elevation: 4,
        // Button uses theme color
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      // Add some padding to ensure FAB doesn't overlap content
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  /// Builds the main content area (task list or empty states)
  Widget _buildContent() {
    // Empty state: No tasks at all
    if (_displayedTasks.isEmpty && _searchQuery.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty state illustration
            Icon(
              Icons.task_alt,
              size: 100,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No tasks yet!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the button below to create your first task',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[400],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Empty state: Search returned no results
    if (_displayedTasks.isEmpty && _searchQuery.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Search empty state illustration
            Icon(
              Icons.search_off,
              size: 100,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No tasks found',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No tasks match "$_searchQuery"',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[400],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Clear search button
            OutlinedButton.icon(
              onPressed: () {
                setState(() => _filterTasks(''));
              },
              icon: const Icon(Icons.clear),
              label: const Text('Clear Search'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Task list with modern styling
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 80), // Bottom padding for FAB
      itemCount: _displayedTasks.length,
      itemBuilder: (context, index) {
        final task = _displayedTasks[index];
        // Add subtle animation to list items
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Padding(
            key: ValueKey(task.id),
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: TaskCard(
              task: task,
              onEdit: () => _openNewTaskScreen(task: task),
              onDelete: () => _deleteTask(task.id!),
            ),
          ),
        );
      },
    );
  }
}