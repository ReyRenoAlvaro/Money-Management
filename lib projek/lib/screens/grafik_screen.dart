import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:expenseapp/services/api_services.dart';
import 'package:expenseapp/model/transactions.dart';

class GrafikScreen extends StatefulWidget {
  @override
  _GrafikScreenState createState() => _GrafikScreenState();
}

class _GrafikScreenState extends State<GrafikScreen> {
  List<Income> incomes = [];
  List<Expense> expenses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      incomes = await ApiService().fetchIncomes();
      expenses = await ApiService().fetchExpenses();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Grafik Keuangan', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueGrey,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Distribusi Pemasukan dan Pengeluaran',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey[900]),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      elevation: 5,
                      shadowColor: Colors.blueGrey,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Expanded(
                              child: PieChart(
                                PieChartData(
                                  sectionsSpace:
                                      2, // small space between sections
                                  centerSpaceRadius: 60,
                                  startDegreeOffset: -90,
                                  sections: _showSections(),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildLegendItem(
                                    Colors.green, 'Pemasukan', context),
                                _buildLegendItem(
                                    Colors.red, 'Pengeluaran', context),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  List<PieChartSectionData> _showSections() {
    double totalIncome =
        incomes.fold(0, (sum, item) => sum + double.parse(item.amount ?? '0'));
    double totalExpense =
        expenses.fold(0, (sum, item) => sum + double.parse(item.amount ?? '0'));
    double total = totalIncome + totalExpense;

    return List.generate(2, (i) {
      final isIncome = i == 0;
      final value = isIncome ? totalIncome : totalExpense;
      final color = isIncome ? Colors.green : Colors.red;
      final title = isIncome ? 'Pemasukan' : 'Pengeluaran';

      return PieChartSectionData(
        color: color,
        value: value,
        title: '${(value / total * 100).toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: const Color(0xffffffff),
        ),
      );
    });
  }

  Widget _buildLegendItem(Color color, String text, BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(fontSize: 16, color: Colors.blueGrey[800]),
        ),
      ],
    );
  }
}
