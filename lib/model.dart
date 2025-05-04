class Currency {
  final String code;
  final String symbol;

  Currency({required this.code, required this.symbol});
}

class AccountBalance {
  final Currency currency;
  double amount;

  AccountBalance({required this.currency, this.amount = 0.0});
}

enum TransactionType { income, expense }

class Transaction {
  String id;
  TransactionType type;
  Currency currency;
  double amount;
  DateTime date;
  String? description;

  Currency? targetCurrency;
  double? targetAmount;

  Transaction({
    required this.id,
    required this.type,
    required this.currency,
    required this.amount,
    DateTime? date,
    this.description,
    this.targetCurrency,
    this.targetAmount,
  }) : date = date ?? DateTime.now();
}
