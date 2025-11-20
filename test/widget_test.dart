// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:todo_flutter/main.dart'; // Imports TodoApp

void main() {
  // NOTE: This test is designed for a default counter app. Since we created
  // a To-Do app, the following test is no longer relevant, but we fix the
  // class name here to ensure the project compiles.

  testWidgets('Renders TodoApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TodoApp()); // Changed from MyApp() to TodoApp()

    // Since our app doesn't have a simple counter, we verify the main title.
    expect(find.text('My To-Do List'), findsOneWidget);

    // Tap the FAB icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle(); // Wait for navigation animation to complete

    // Verify that the New Task screen is displayed
    expect(find.text('New Task'), findsOneWidget);
  });
}