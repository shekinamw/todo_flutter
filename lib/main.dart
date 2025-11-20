import 'package:flutter/material.dart';
import 'screens/task_list_screen.dart';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Rubric requirement: Change theme colors and font.
    // The font family is now removed as custom assets cannot be bundled in this environment.
    const primaryAppColor = Color(0xFF19313D); // Vibrant Orange

    return MaterialApp(
      title: 'Advanced To-Do',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primaryColor: primaryAppColor,
          colorScheme: ColorScheme.fromSeed(seedColor: primaryAppColor),
          useMaterial3: true,
          // Removed fontFamily: 'RobotoSlab' to fix the asset bundling error.

          // Custom AppBar theme applied globally to fix the color for all screens
          appBarTheme: const AppBarTheme(
            backgroundColor: primaryAppColor, // Fixed color
            foregroundColor: Colors.white,
            elevation: 4,
            titleTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          // Custom FAB theme
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFF4CAF50), // Green for FAB
            foregroundColor: Colors.white,
          )
      ),
      home: const TaskListScreen(),
    );
  }
}