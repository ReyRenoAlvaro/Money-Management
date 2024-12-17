import 'package:expenseapp/model/category.dart';
import 'package:expenseapp/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:expenseapp/model/transactions.dart';
import '../widgets/sidebar.dart';

class ExpenseScreen extends StatefulWidget {
  @override
  _ExpenseScreenState createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  late Future<List<Expense>> futureExpenses;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    futureExpenses = apiService.fetchExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _showExpenseForm(context);
            },
          ),
        ],
      ),
      drawer: SideBar(),
      body: FutureBuilder<List<Expense>>(
        future: futureExpenses,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data?.length ?? 0,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(snapshot.data![index].description),
                  subtitle: Text(snapshot.data![index].amount),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _showExpenseForm(context,
                              expense: snapshot.data![index]);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _deleteExpense(snapshot.data![index].id);
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load expenses'));
          }

          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Future<void> _deleteExpense(int id) async {
    await apiService.deleteExpense(id);
    setState(() {
      futureExpenses = apiService.fetchExpenses();
    });
  }

  Future<void> _showExpenseForm(BuildContext context,
      {Expense? expense}) async {
    await showDialog(
      context: context,
      builder: (context) {
        return ExpenseForm(
          expense: expense,
          onSave: (newExpense) {
            setState(() {
              futureExpenses = apiService.fetchExpenses();
            });
          },
        );
      },
    );
  }
}

class ExpenseForm extends StatefulWidget {
  final Expense? expense;
  final Function(Expense) onSave;

  ExpenseForm({this.expense, required this.onSave});

  @override
  _ExpenseFormState createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  late String description;
  late String entryDate;
  late String amount;
  late int expenseCategoryId;
  late Future<List<ExpenseCategory>> futureExpenseCategories;

  @override
  void initState() {
    super.initState();
    futureExpenseCategories =
        ApiService().fetchExpenseCategories(); // Ambil kategori dari API
    if (widget.expense != null) {
      description = widget.expense!.description;
      entryDate = widget.expense!.entryDate;
      amount = widget.expense!.amount;
      expenseCategoryId = widget.expense!.expenseCategoryId;
    } else {
      description = '';
      entryDate = '';
      amount = '';
      expenseCategoryId = 0; // Asumsikan ini adalah 'Select Category'
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.expense == null ? 'Add Expense' : 'Edit Expense'),
      content: FutureBuilder<List<ExpenseCategory>>(
        future: futureExpenseCategories,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var categories = snapshot.data!;
            return SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextFormField(
                      initialValue: description,
                      decoration: InputDecoration(labelText: 'Description'),
                      onSaved: (value) => description = value!,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: entryDate,
                      decoration: InputDecoration(labelText: 'Entry Date'),
                      onSaved: (value) => entryDate = value!,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an entry date';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: amount,
                      decoration: InputDecoration(labelText: 'Amount'),
                      onSaved: (value) => amount = value!,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an amount';
                        }
                        return null;
                      },
                    ),
                    DropdownButtonFormField<int>(
                      value: expenseCategoryId != 0 ? expenseCategoryId : null,
                      onChanged: (int? newValue) {
                        if (newValue != null) {
                          setState(() {
                            expenseCategoryId = newValue;
                          });
                        }
                      },
                      items: [
                        DropdownMenuItem<int>(
                          value: 0,
                          child: Text("Select Category"),
                        ),
                        ...categories
                            .map((category) => DropdownMenuItem<int>(
                                  value: category.id,
                                  child: Text(category.name),
                                ))
                            .toList(),
                      ],
                      decoration: InputDecoration(labelText: 'Category'),
                    ),
                    ElevatedButton(
                      onPressed: _saveForm,
                      child: Text('Save'),
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Text('Error loading categories');
          }
          return CircularProgressIndicator();
        },
      ),
    );
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Expense newExpense = Expense(
        description: description,
        entryDate: entryDate,
        amount: amount,
        expenseCategoryId: expenseCategoryId,
        id: 0, // Biasanya, ID disetel di server
        userId: 3, // Asumsikan user ID diperoleh dari sesi atau konfigurasi
        currencyId: 2, // Contoh currency ID
        createdAt: DateTime.now().toString(),
        updatedAt: DateTime.now().toString(),
      );
      widget.onSave(newExpense);
      Navigator.of(context).pop();
    }
  }
}
