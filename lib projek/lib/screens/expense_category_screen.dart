import 'package:expenseapp/model/category.dart';
import 'package:expenseapp/services/api_services.dart';
import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';

class ExpenseCategoryScreen extends StatefulWidget {
  @override
  _ExpenseCategoryScreenState createState() => _ExpenseCategoryScreenState();
}

class _ExpenseCategoryScreenState extends State<ExpenseCategoryScreen> {
  late Future<List<ExpenseCategory>> futureExpenseCategories;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    futureExpenseCategories = apiService.fetchExpenseCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Categories'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _showExpenseCategoryForm(context);
            },
          ),
        ],
      ),
      drawer: SideBar(),
      body: FutureBuilder<List<ExpenseCategory>>(
        future: futureExpenseCategories,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data?.length ?? 0,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(snapshot.data![index].name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _showExpenseCategoryForm(context,
                              category: snapshot.data![index]);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _deleteExpenseCategory(snapshot.data![index].id);
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load expense categories'));
          }

          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Future<void> _deleteExpenseCategory(int id) async {
    await apiService.deleteExpenseCategory(id);
    setState(() {
      futureExpenseCategories = apiService.fetchExpenseCategories();
    });
  }

  Future<void> _showExpenseCategoryForm(BuildContext context,
      {ExpenseCategory? category}) async {
    await showDialog(
      context: context,
      builder: (context) {
        return ExpenseCategoryForm(
          category: category,
          onSave: (newCategory) {
            setState(() {
              futureExpenseCategories = apiService.fetchExpenseCategories();
            });
          },
        );
      },
    );
  }
}

class ExpenseCategoryForm extends StatefulWidget {
  final ExpenseCategory? category;
  final Function(ExpenseCategory) onSave;

  ExpenseCategoryForm({this.category, required this.onSave});

  @override
  _ExpenseCategoryFormState createState() => _ExpenseCategoryFormState();
}

class _ExpenseCategoryFormState extends State<ExpenseCategoryForm> {
  final _formKey = GlobalKey<FormState>();
  late int id;
  late String name;
  late int userId;
  late DateTime createdAt;
  late DateTime updatedAt;

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      id = widget.category!.id;
      name = widget.category!.name;
      userId = widget.category!.userId;
      createdAt = widget.category!.createdAt;
      updatedAt = widget.category!.updatedAt;
    } else {
      id = 0;
      name = '';
      userId = 0;
      createdAt = DateTime.now();
      updatedAt = DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.category == null
          ? 'Add Expense Category'
          : 'Edit Expense Category'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              initialValue: name,
              decoration: InputDecoration(labelText: 'Name'),
              onSaved: (value) {
                name = value!;
              },
            ),
          ],
        ),
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
              ExpenseCategory newCategory = ExpenseCategory(
                id: id,
                name: name,
                userId: userId,
                createdAt: createdAt,
                updatedAt: updatedAt,
              );
              if (widget.category == null) {
                ApiService().addExpenseCategory(newCategory);
              } else {
                ApiService()
                    .updateExpenseCategory(widget.category!.id, newCategory);
              }
              widget.onSave(newCategory);
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}
