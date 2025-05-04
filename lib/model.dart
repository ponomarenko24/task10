import 'package:hive/hive.dart';

part 'model.g.dart';

@HiveType(typeId: 0)
class Currency extends HiveObject {
  @HiveField(0)
  String code;
  @HiveField(1)
  String symbol;

  Currency({required this.code, required this.symbol});
}

@HiveType(typeId: 1)
class AccountBalance extends HiveObject {
  @HiveField(0)
  Currency currency;
  @HiveField(1)
  double amount;

  AccountBalance({required this.currency, this.amount = 0.0});
}

@HiveType(typeId: 2)
enum TransactionType {
  @HiveField(0)
  income,
  @HiveField(1)
  expense,
}

@HiveType(typeId: 3)
class Transaction extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  TransactionType type;
  @HiveField(2)
  Currency currency;
  @HiveField(3)
  double amount;
  @HiveField(4)
  DateTime date;
  @HiveField(5)
  String? description;

  @HiveField(6)
  Currency? targetCurrency;
  @HiveField(7)
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
