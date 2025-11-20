class Task {
  // Database ID (nullable for new tasks before insertion)
  final int? id;
  final String title;
  final String deadline;
  final String description;
  final String color;
  final String imagePath; // Path or URI for image (from original code, kept for schema completeness)

  Task({
    this.id,
    required this.title,
    required this.deadline,
    this.description = '',
    this.color = '#FF5722', // Default color
    this.imagePath = '',
  });

  // Convert Task object to a Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'deadline': deadline,
      'description': description,
      'color': color,
      'imagePath': imagePath,
    };
  }

  // Convert a Map (from database) to a Task object
  static Task fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      deadline: map['deadline'] as String,
      description: map['description'] as String,
      color: map['color'] as String,
      imagePath: map['imagePath'] as String,
    );
  }
}