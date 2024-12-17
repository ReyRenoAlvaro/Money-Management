import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/income_screen.dart';
import 'screens/expense_screen.dart';
import 'screens/income_category_screen.dart';
import 'screens/expense_category_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/income': (context) => IncomeScreen(),
        '/expense': (context) => ExpenseScreen(),
        '/income-category': (context) => IncomeCategoryScreen(),
        '/expense-category': (context) => ExpenseCategoryScreen(),
      },
    );
  }
}
