import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:task_10/Transactions_list_page.dart';
import 'package:task_10/model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(CurrencyAdapter());
  Hive.registerAdapter(TransactionTypeAdapter());
  Hive.registerAdapter(TransactionAdapter());

  await Hive.openBox<Transaction>('transactions');

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: TransactionListPage());
  }
}

