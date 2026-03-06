class Expense {
  final String id;
  String title;
  double amount;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
  });

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as String,
      title: map['title'] as String,
      amount: map['amount'] as double,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'amount': amount,
      };

  @override
  String toString() => 'Expense(id: $id, title: $title, amount: $amount)';
}

/// Route argument wrapper — null expense = Add mode, non-null = Edit mode
class AddExpenseArgs {
  final Expense? expense;
  const AddExpenseArgs({this.expense});
}
