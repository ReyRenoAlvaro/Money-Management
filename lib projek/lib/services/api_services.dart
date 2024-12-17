import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:expenseapp/model/category.dart';
import 'package:expenseapp/model/transactions.dart';

class ApiService {
  final String baseUrl = 'http://192.168.43.169:8000/api';

  Future<List<Income>> fetchIncomes() async {
    final response = await http.get(Uri.parse('$baseUrl/transactions'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> incomeJson = data['incomes'];
      return incomeJson.map((json) => Income.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load incomes: ${response.body}');
    }
  }

  Future<List<Expense>> fetchExpenses() async {
    final response = await http.get(Uri.parse('$baseUrl/transactions'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> expenseJson = data['expenses'];
      return expenseJson.map((json) => Expense.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load expenses: ${response.body}');
    }
  }

  Future<List<IncomeCategory>> fetchIncomeCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/category?type=income'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> incomeCategoryJson = data['categories']['income'];
      return incomeCategoryJson
          .map((json) => IncomeCategory.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load income categories: ${response.body}');
    }
  }

  Future<List<ExpenseCategory>> fetchExpenseCategories() async {
    final response =
        await http.get(Uri.parse('$baseUrl/category?type=expense'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> expenseCategoryJson = data['categories']['expense'];
      return expenseCategoryJson
          .map((json) => ExpenseCategory.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load expense categories: ${response.body}');
    }
  }

  Future<void> addIncome(Income income) async {
    final response = await http.post(
      Uri.parse('$baseUrl/transactions/${income.id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'type': 'income',
        'Description': income.description,
        'Entry Date': income.entryDate,
        'Amount': income.amount
      }),
    );
    print(response.statusCode);
    if (response.statusCode != 201) {
      throw Exception('Failed to add income: ${response.body}');
    }
  }

  Future<void> updateIncome(int id, Income income) async {
    final response = await http.put(
      Uri.parse('$baseUrl/transactions/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'type': 'income', ...income.toJson()}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update income: ${response.body}');
    }
  }

  Future<void> deleteIncome(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/transactions/$id?type=income'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete income: ${response.body}');
    }
  }

  Future<void> addExpense(Expense expense) async {
    final response = await http.post(
      Uri.parse('$baseUrl/transactions'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'type': 'expense', ...expense.toJson()}),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add expense: ${response.body}');
    }
  }

  Future<void> updateExpense(int id, Expense expense) async {
    final response = await http.put(
      Uri.parse('$baseUrl/transactions/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'type': 'expense', ...expense.toJson()}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update expense: ${response.body}');
    }
  }

  Future<void> deleteExpense(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/transactions/$id?type=expense'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete expense: ${response.body}');
    }
  }

  Future<void> addIncomeCategory(IncomeCategory category) async {
    final response = await http.post(
      Uri.parse('$baseUrl/category'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'type': 'income', ...category.toJson()}),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add income category: ${response.body}');
    }
  }

  Future<void> updateIncomeCategory(int id, IncomeCategory category) async {
    final response = await http.put(
      Uri.parse('$baseUrl/category/$id?type=income'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(category.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update income category: ${response.body}');
    }
  }

  Future<void> deleteIncomeCategory(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/category/$id?type=income'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete income category: ${response.body}');
    }
  }

  Future<void> addExpenseCategory(ExpenseCategory category) async {
    final response = await http.post(
      Uri.parse('$baseUrl/category'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'type': 'expense', ...category.toJson()}),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add expense category: ${response.body}');
    }
  }

  Future<void> updateExpenseCategory(int id, ExpenseCategory category) async {
    final response = await http.put(
      Uri.parse('$baseUrl/category/$id?type=expense'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(category.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update expense category: ${response.body}');
    }
  }

  Future<void> deleteExpenseCategory(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/category/$id?type=expense'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete expense category: ${response.body}');
    }
  }

  Future<Map<String, double>> fetchExchangeRates() async {
    final response = await http
        .get(Uri.parse('https://api.exchangerate-api.com/v4/latest/IDR'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Exchange rates: $data');
      return {
        'USD': data['rates']['USD'],
        'GBP': data['rates']['GBP'],
      };
    } else {
      throw Exception('Failed to load exchange rates');
    }
  }
}
