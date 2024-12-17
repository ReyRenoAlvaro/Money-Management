import 'package:expenseapp/model/category.dart';
import 'package:expenseapp/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:expenseapp/model/transactions.dart';
import '../widgets/sidebar.dart';

class IncomeScreen extends StatefulWidget {
  @override
  _IncomeScreenState createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  late Future<List<Income>> futureIncomes;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    futureIncomes = apiService.fetchIncomes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Income'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _showIncomeForm(context);
            },
          ),
        ],
      ),
      drawer: SideBar(),
      body: FutureBuilder<List<Income>>(
        future: futureIncomes,
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
                          _showIncomeForm(context,
                              income: snapshot.data![index]);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _deleteIncome(snapshot.data![index].id);
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load incomes'));
          }

          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Future<void> _deleteIncome(int id) async {
    await apiService.deleteIncome(id);
    setState(() {
      futureIncomes = apiService.fetchIncomes();
    });
  }

  Future<void> _showIncomeForm(BuildContext context, {Income? income}) async {
    await showDialog(
      context: context,
      builder: (context) {
        return IncomeForm(
          income: income,
          onSave: (newIncome) {
            setState(() {
              futureIncomes = apiService.fetchIncomes();
            });
          },
        );
      },
    );
  }
}

class IncomeForm extends StatefulWidget {
  final Income? income;
  final Function(Income) onSave;

  IncomeForm({this.income, required this.onSave});

  @override
  _IncomeFormState createState() => _IncomeFormState();
}

class _IncomeFormState extends State<IncomeForm> {
  final _formKey = GlobalKey<FormState>();
  late int id;
  late int incomeCategoryId;
  late String description;
  late String entryDate;
  late String amount;
  late int currencyId;
  late int userId;
  late String createdAt;
  late String updatedAt;
  late String? deletedAt;
  late Future<List<IncomeCategory>> futureIncomeCategories;

  @override
  void initState() {
    super.initState();
    futureIncomeCategories = ApiService().fetchIncomeCategories();
    if (widget.income != null) {
      id = widget.income!.id;
      incomeCategoryId = widget.income!.incomeCategoryId;
      description = widget.income!.description;
      entryDate = widget.income!.entryDate;
      amount = widget.income!.amount;
      userId = widget.income!.userId;
      currencyId = widget.income!.currencyId;
      createdAt = widget.income!.createdAt;
      updatedAt = widget.income!.updatedAt;
      deletedAt = widget.income!.deletedAt;
    } else {
      id = 0;
      incomeCategoryId = 0;
      description = '';
      entryDate = '';
      amount = '';
      currencyId = 0;
      userId = 0;
      createdAt = '';
      updatedAt = '';
      deletedAt = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.income == null ? 'Add Income' : 'Edit Income'),
      content: FutureBuilder<List<IncomeCategory>>(
        future: futureIncomeCategories,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  DropdownButtonFormField<int>(
                    value: incomeCategoryId,
                    items: snapshot.data!.map((IncomeCategory category) {
                      return DropdownMenuItem<int>(
                        value: category.id,
                        child: Text(category.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        incomeCategoryId = value!;
                      });
                    },
                    decoration: InputDecoration(labelText: 'Category'),
                  ),
                  TextFormField(
                    initialValue: description,
                    decoration: InputDecoration(labelText: 'Description'),
                    onSaved: (value) {
                      description = value!;
                    },
                  ),
                  TextFormField(
                    initialValue: entryDate,
                    decoration: InputDecoration(labelText: 'Entry Date'),
                    onSaved: (value) {
                      entryDate = value!;
                    },
                  ),
                  TextFormField(
                    initialValue: amount,
                    decoration: InputDecoration(labelText: 'Amount'),
                    onSaved: (value) {
                      amount = value!;
                    },
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load categories'));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('Save'),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              Income newIncome = Income(
                id: id,
                incomeCategoryId: incomeCategoryId,
                currencyId: currencyId,
                description: description,
                entryDate: entryDate,
                amount: amount,
                userId: userId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              );
              if (widget.income == null) {
                ApiService().addIncome(newIncome);
              } else {
                ApiService().updateIncome(widget.income!.id, newIncome);
              }
              widget.onSave(newIncome);
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}
