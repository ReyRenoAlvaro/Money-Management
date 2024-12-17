import 'package:expenseapp/model/category.dart';
import 'package:expenseapp/services/api_services.dart';
import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';

class IncomeCategoryScreen extends StatefulWidget {
  @override
  _IncomeCategoryScreenState createState() => _IncomeCategoryScreenState();
}

class _IncomeCategoryScreenState extends State<IncomeCategoryScreen> {
  late Future<List<IncomeCategory>> futureIncomeCategories;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    futureIncomeCategories = apiService.fetchIncomeCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Income Categories'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _showIncomeCategoryForm(context);
            },
          ),
        ],
      ),
      drawer: SideBar(),
      body: FutureBuilder<List<IncomeCategory>>(
        future: futureIncomeCategories,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load income categories'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No income categories found'));
          } else {
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
                          _showIncomeCategoryForm(context,
                              category: snapshot.data![index]);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _deleteIncomeCategory(snapshot.data![index].id);
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<void> _deleteIncomeCategory(int id) async {
    try {
      await apiService.deleteIncomeCategory(id);
      setState(() {
        futureIncomeCategories = apiService.fetchIncomeCategories();
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to delete category')));
    }
  }

  Future<void> _showIncomeCategoryForm(BuildContext context,
      {IncomeCategory? category}) async {
    await showDialog(
      context: context,
      builder: (context) {
        return IncomeCategoryForm(
          category: category,
          onSave: (newCategory) {
            setState(() {
              futureIncomeCategories = apiService.fetchIncomeCategories();
            });
          },
        );
      },
    );
  }
}

class IncomeCategoryForm extends StatefulWidget {
  final IncomeCategory? category;
  final Function(IncomeCategory) onSave;

  IncomeCategoryForm({this.category, required this.onSave});

  @override
  _IncomeCategoryFormState createState() => _IncomeCategoryFormState();
}

class _IncomeCategoryFormState extends State<IncomeCategoryForm> {
  final _formKey = GlobalKey<FormState>();
  late String name;

  @override
  void initState() {
    super.initState();
    name = widget.category?.name ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.category == null
          ? 'Add Income Category'
          : 'Edit Income Category'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              initialValue: name,
              decoration: InputDecoration(labelText: 'Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
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
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              IncomeCategory newCategory = IncomeCategory(
                id: widget.category?.id ?? 0,
                name: name,
                userId: widget.category?.userId ?? 0,
                createdAt: widget.category?.createdAt ?? DateTime.now(),
                updatedAt: DateTime.now(),
              );

              try {
                if (widget.category == null) {
                  await ApiService().addIncomeCategory(newCategory);
                } else {
                  await ApiService()
                      .updateIncomeCategory(widget.category!.id, newCategory);
                }
                widget.onSave(newCategory);
                Navigator.of(context).pop();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to save category')));
              }
            }
          },
        ),
      ],
    );
  }
}
