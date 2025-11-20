import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/database_helper.dart';

class NewTaskScreen extends StatefulWidget {
  final Task? task; // Null if creating, non-null if editing

  const NewTaskScreen({super.key, this.task});

  @override
  State<NewTaskScreen> createState() => _NewTaskScreenState();
}

class _NewTaskScreenState extends State<NewTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final dbHelper = DatabaseHelper();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  String _deadline = '';
  String _selectedColor = '#FF5722'; // Default color: Orange

  @override
  void initState() {
    super.initState();
    final task = widget.task;

    // Initialize controllers based on whether we are editing an existing task
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(text: task?.description ?? '');

    if (task != null) {
      _deadline = task.deadline;
      _selectedColor = task.color;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Converts hex color string to Flutter Color
  Color _hexToColor(String hexColor) {
    hexColor = hexColor.replaceAll('#', 'FF');
    return Color(int.parse(hexColor, radix: 16));
  }

  /// Formats a DateTime object to 'MM/dd/yyyy' string without using 'intl'.
  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$month/$day/$year';
  }

  /// Modern date picker with enhanced styling
  void _selectDate(BuildContext context) async {
    DateTime initialDate;
    if (_deadline.isNotEmpty) {
      try {
        final parts = _deadline.split('/');
        final month = int.parse(parts[0]);
        final day = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        initialDate = DateTime(year, month, day);
      } catch (e) {
        initialDate = DateTime.now();
      }
    } else {
      initialDate = DateTime.now();
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime(2050),
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            colorScheme: ColorScheme.light(
              primary: _hexToColor(_selectedColor),
            ),
            useMaterial3: true,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _deadline = _formatDate(picked);
      });
    }
  }

  /// Saves the task (inserts new or updates existing)
  void _saveTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_deadline.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a deadline', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    // Build the task object
    final Task taskToSave = Task(
      id: widget.task?.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      deadline: _deadline,
      color: _selectedColor,
      imagePath: widget.task?.imagePath ?? '',
    );

    try {
      if (widget.task == null) {
        await dbHelper.insertTask(taskToSave);
      } else {
        await dbHelper.updateTask(taskToSave);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving task: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Modern color palette with additional options
  final List<String> _colorOptions = const [
    '#FF5722', // Deep Orange
    '#4CAF50', // Green
    '#2196F3', // Blue
    '#FFC107', // Amber
    '#9C27B0', // Purple
    '#E91E63', // Pink
  ];

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final isEditing = widget.task != null;

    return Scaffold(
      // Modern gradient background
      backgroundColor: Colors.grey[50],

      // Clean app bar with elevation
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Task' : 'Create New Task',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // --- TITLE INPUT SECTION ---
              // Modern card-style container for better visual hierarchy
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section label with icon
                    Row(
                      children: [
                        Icon(Icons.title, color: primaryColor, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Task Title',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        const Text(
                          ' *',
                          style: TextStyle(color: Colors.red, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Title input field with modern styling
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'Enter task title',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[200]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primaryColor, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Title is required';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // --- DEADLINE PICKER SECTION ---
              // Modern card with deadline selection
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _deadline.isEmpty ? Colors.red.shade200 : Colors.grey[200]!,
                    width: _deadline.isEmpty ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section label
                    Row(
                      children: [
                        Icon(Icons.calendar_today, color: primaryColor, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Deadline',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        const Text(
                          ' *',
                          style: TextStyle(color: Colors.red, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Date display and picker button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Display selected date or prompt
                        Expanded(
                          child: Text(
                            _deadline.isEmpty ? 'No date selected' : _deadline,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: _deadline.isEmpty ? Colors.grey[400] : Colors.grey[800],
                            ),
                          ),
                        ),
                        // Modern date picker button with fixed primary color
                        ElevatedButton.icon(
                          onPressed: () => _selectDate(context),
                          icon: Icon(_deadline.isEmpty ? Icons.add : Icons.edit, size: 18),
                          label: Text(_deadline.isEmpty ? 'Pick Date' : 'Change'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // --- DESCRIPTION INPUT SECTION ---
              // Optional description field with modern styling
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section label
                    Row(
                      children: [
                        Icon(Icons.description, color: primaryColor, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(Optional)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Multi-line description input
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Add details about your task...',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[200]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primaryColor, width: 2),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // --- COLOR TAG SELECTION SECTION ---
              // Modern color picker with visual feedback
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section label with palette icon
                    Row(
                      children: [
                        Icon(Icons.palette, color: primaryColor, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Task Color Tag',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Color options grid with modern touch feedback
                    Wrap(
                      spacing: 12.0,
                      runSpacing: 12.0,
                      children: _colorOptions.map((colorHex) {
                        final bool isSelected = colorHex == _selectedColor;
                        final color = _hexToColor(colorHex);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedColor = colorHex;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(color: Colors.white, width: 3)
                                  : null,
                              boxShadow: [
                                BoxShadow(
                                  color: isSelected
                                      ? color.withOpacity(0.5)
                                      : Colors.black.withOpacity(0.1),
                                  blurRadius: isSelected ? 8 : 4,
                                  spreadRadius: isSelected ? 2 : 0,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            // Checkmark for selected color
                            child: isSelected
                                ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 28,
                            )
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // --- SAVE/UPDATE BUTTON ---
              // Modern elevated button with fixed primary color
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _saveTask,
                  icon: Icon(isEditing ? Icons.check_circle : Icons.add_task, size: 24),
                  label: Text(
                    isEditing ? 'Update Task' : 'Create Task',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 58),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}