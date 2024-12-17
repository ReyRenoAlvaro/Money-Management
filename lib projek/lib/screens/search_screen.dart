import 'package:flutter/material.dart';
import 'package:expenseapp/services/api_services.dart';
import 'package:expenseapp/model/transactions.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  DateTime selectedDate = DateTime.now();
  bool isLoading = false;
  List<Income> searchIncomes = [];
  List<Expense> searchExpenses = [];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      _searchByDate();
    }
  }

  Future<void> _searchByDate() async {
    setState(() {
      isLoading = true;
    });

    try {
      List<Income> allIncomes = await ApiService().fetchIncomes();
      List<Expense> allExpenses = await ApiService().fetchExpenses();

      String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

      searchIncomes = allIncomes
          .where((income) => income.entryDate.startsWith(formattedDate))
          .toList();
      searchExpenses = allExpenses
          .where((expense) => expense.entryDate.startsWith(formattedDate))
          .toList();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching data: $e');
    }
  }

  String formatCurrency(double amount) {
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');
    return format.format(amount);
  }

  pw.Document generatePdfDocument() {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Search Results for ${DateFormat('yyyy-MM-dd').format(selectedDate)}',
                style: pw.TextStyle(fontSize: 24),
              ),
              pw.SizedBox(height: 16),
              pw.Text('Incomes', style: pw.TextStyle(fontSize: 20)),
              pw.Table.fromTextArray(
                headers: ['Description', 'Date', 'Amount'],
                data: searchIncomes.map((income) {
                  return [
                    income.description,
                    income.entryDate,
                    formatCurrency(double.parse(income.amount)),
                  ];
                }).toList(),
              ),
              pw.SizedBox(height: 16),
              pw.Text('Expenses', style: pw.TextStyle(fontSize: 20)),
              pw.Table.fromTextArray(
                headers: ['Description', 'Date', 'Amount'],
                data: searchExpenses.map((expense) {
                  return [
                    expense.description,
                    expense.entryDate,
                    formatCurrency(double.parse(expense.amount)),
                  ];
                }).toList(),
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  void _printSearchResults() async {
    final pdf = generatePdfDocument();

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search by Date'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _printSearchResults,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () => _selectDate(context),
              child: const Text('Select Date'),
            ),
            const SizedBox(height: 16),
            Text(
              'Selected Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: ListView(
                      children: [
                        const Text(
                          'Incomes',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        ...searchIncomes.map((income) => ListTile(
                              title: Text(income.description),
                              subtitle: Text(income.entryDate),
                              trailing: Text(
                                  formatCurrency(double.parse(income.amount))),
                            )),
                        const SizedBox(height: 16),
                        const Text(
                          'Expenses',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        ...searchExpenses.map((expense) => ListTile(
                              title: Text(expense.description),
                              subtitle: Text(expense.entryDate),
                              trailing: Text(
                                  formatCurrency(double.parse(expense.amount))),
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
