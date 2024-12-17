class Currency {
  final int id;
  final String name;

  Currency({required this.id, required this.name});

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      id: json['id'],
      name: json['name'],
    );
  }
}

class Income {
  final int id;
  final int incomeCategoryId;
  final String description;
  final String entryDate;
  final String amount;
  final int userId;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final int currencyId; // Tambahkan field ini

  Income({
    required this.id,
    required this.incomeCategoryId,
    required this.description,
    required this.entryDate,
    required this.amount,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.currencyId, // Tambahkan field ini
  });

  factory Income.fromJson(Map<String, dynamic> json) {
    return Income(
      id: json['id'],
      incomeCategoryId: json['income_category_id'],
      description: json['description'],
      entryDate: json['entry_date'],
      amount: json['amount'],
      userId: json['user_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      deletedAt: json['deleted_at'],
      currencyId: json['currency_id'], // Tambahkan field ini
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'income_category_id': incomeCategoryId,
      'description': description,
      'entry_date': entryDate,
      'amount': amount,
      'user_id': userId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
      'currency_id': currencyId,
    };
  }
}

class Expense {
  final int id;
  final int expenseCategoryId;
  final String entryDate;
  final String description;
  final String amount;
  final int userId;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final int currencyId;

  Expense({
    required this.id,
    required this.expenseCategoryId,
    required this.entryDate,
    required this.description,
    required this.amount,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.currencyId,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      expenseCategoryId: json['expense_category_id'],
      entryDate: json['entry_date'],
      description: json['description'],
      amount: json['amount'],
      userId: json['user_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      deletedAt: json['deleted_at'],
      currencyId: json['currency_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'expense_category_id': expenseCategoryId,
      'entry_date': entryDate,
      'description': description,
      'amount': amount,
      'user_id': userId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
      'currency_id': currencyId,
    };
  }
}
