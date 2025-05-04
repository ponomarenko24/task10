import 'package:hive/hive.dart';

part 'model.g.dart';

@HiveType(typeId: 0)
enum Currency {
  @HiveField(0)
  uah,

  @HiveField(1)
  eur,

  @HiveField(2)
  usd,
}

extension CurrencyExtension on Currency {
  String get code {
    switch (this) {
      case Currency.uah:
        return 'UAH';
      case Currency.eur:
        return 'EUR';
      case Currency.usd:
        return 'USD';
    }
  }

  String get symbol {
    switch (this) {
      case Currency.usd:
        return '\$';
      case Currency.eur:
        return '€';
      case Currency.uah:
        return '₴';
    }
  }
}

@HiveType(typeId: 1)
enum TransactionType {
  @HiveField(0)
  income,

  @HiveField(1)
  expense,
}

@HiveType(typeId: 2)
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
  String? description;

  @HiveField(5)
  DateTime date;

  Transaction({
    required this.id,
    required this.type,
    required this.currency,
    required this.amount,
    this.description,
    DateTime? date,
  }) : date = date ?? DateTime.now();
}
