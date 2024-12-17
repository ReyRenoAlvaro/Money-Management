import 'package:expenseapp/screens/grafik_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expenseapp/services/api_services.dart';
import 'package:expenseapp/model/transactions.dart';
import '../widgets/sidebar.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double totalIncome = 0.0;
  double totalExpense = 0.0;
  double usdRate = 0.0;
  double gbpRate = 0.0;
  bool isLoading = true;
  List<Income> incomes = [];
  List<Expense> expenses = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      incomes = await ApiService().fetchIncomes();
      expenses = await ApiService().fetchExpenses();
      Map<String, double> rates = await ApiService().fetchExchangeRates();

      setState(() {
        usdRate = rates['USD']!;
        gbpRate = rates['GBP']!;
        totalIncome = incomes.fold(0.0,
            (sum, item) => sum + double.parse(item.amount.replaceAll(',', '')));
        totalExpense = expenses.fold(0.0,
            (sum, item) => sum + double.parse(item.amount.replaceAll(',', '')));
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching data: $e');
    }
  }

  String formatCurrency(double amount,
      {String locale = 'id_ID', String symbol = 'Rp '}) {
    final format = NumberFormat.currency(locale: locale, symbol: symbol);
    return format.format(amount);
  }

  String formatCurrencyUSD(double amount) {
    if (usdRate == 0.0) return 'Loading...';
    return formatCurrency(amount * usdRate, locale: 'en_US', symbol: '\$');
  }

  String formatCurrencyGBP(double amount) {
    if (gbpRate == 0.0) return 'Loading...';
    return formatCurrency(amount * gbpRate, locale: 'en_GB', symbol: '£');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SearchScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => GrafikScreen()));
            },
          ),
        ],
      ),
      drawer: SideBar(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Saldo Anda',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatCurrency(totalIncome - totalExpense),
                    style: const TextStyle(
                        fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'USD: ${formatCurrencyUSD(totalIncome - totalExpense)}',
                    style: const TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'GBP: ${formatCurrencyGBP(totalIncome - totalExpense)}',
                    style: const TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Flexible(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.arrow_upward, color: Colors.green),
                            const Text(
                              'Pemasukan',
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              formatCurrency(totalIncome),
                              style: const TextStyle(
                                  fontSize: 20,
                                  color:
                                      Colors.green), // Reduced font size here
                            ),
                            Text(
                              'USD: ${formatCurrencyUSD(totalIncome)}',
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue), // Reduced font size here
                            ),
                            Text(
                              'GBP: ${formatCurrencyGBP(totalIncome)}',
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue), // Reduced font size here
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.arrow_downward, color: Colors.red),
                            const Text(
                              'Pengeluaran',
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              formatCurrency(totalExpense),
                              style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.red), // Reduced font size here
                            ),
                            Text(
                              'USD: ${formatCurrencyUSD(totalExpense)}',
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue), // Reduced font size here
                            ),
                            Text(
                              'GBP: ${formatCurrencyGBP(totalExpense)}',
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue), // Reduced font size here
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      children: [
                        const Text(
                          'Incomes',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        ...incomes.map((income) => ListTile(
                              title: Text(income.description),
                              subtitle: Text(income.entryDate),
                              trailing: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(formatCurrency(
                                      double.parse(income.amount))),
                                  Text(
                                      'USD: ${formatCurrencyUSD(double.parse(income.amount))}'),
                                  Text(
                                      'GBP: ${formatCurrencyGBP(double.parse(income.amount))}'),
                                ],
                              ),
                            )),
                        const SizedBox(height: 16),
                        const Text(
                          'Expenses',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        ...expenses.map((expense) => ListTile(
                              title: Text(expense.description),
                              subtitle: Text(expense.entryDate),
                              trailing: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(formatCurrency(
                                      double.parse(expense.amount))),
                                  Text(
                                      'USD: ${formatCurrencyUSD(double.parse(expense.amount))}'),
                                  Text(
                                      'GBP: ${formatCurrencyGBP(double.parse(expense.amount))}'),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
