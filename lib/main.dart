import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:task_10/model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(CurrencyAdapter());
  Hive.registerAdapter(AccountBalanceAdapter());
  Hive.registerAdapter(TransactionTypeAdapter());
  Hive.registerAdapter(TransactionAdapter());

  await Hive.openBox<AccountBalance>('balances');
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

class TransactionListPage extends StatefulWidget {
  const TransactionListPage({super.key});

  @override
  State<TransactionListPage> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage> {
  @override
  Widget build(BuildContext context) {
    final Box<Transaction> box = Hive.box<Transaction>('transactions');

    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<Transaction> transactions, _) {
          if (transactions.isEmpty) {
            return const Center(child: Text('No transactions'));
          }

          final list = transactions.values.toList().reversed.toList();

          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final tx = list[index];
              return ListTile(
                title: Text(
                  '${tx.type == TransactionType.income ? '+' : '-'} ${tx.amount.toStringAsFixed(2)} ${tx.currency.code}',
                  style: TextStyle(
                    color:
                        tx.type == TransactionType.income
                            ? Colors.green
                            : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(tx.description ?? ''),
                trailing: Text('${tx.date.toLocal()}'.split(' ')[0]),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTransactionDialog(BuildContext context) {
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    TransactionType selectedType = TransactionType.expense;
    bool isButtonEnabled = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            void checkButtonState() {
              setState(() {
                isButtonEnabled =
                    amountController.text.isNotEmpty &&
                    descriptionController.text.isNotEmpty;
              });
            }

            amountController.addListener(checkButtonState);
            descriptionController.addListener(checkButtonState);

            return AlertDialog(
              title: const Text('New transactions'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<TransactionType>(
                    value: selectedType,
                    items:
                        TransactionType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(
                              type == TransactionType.income
                                  ? 'Income'
                                  : 'Expense',
                            ),
                          );
                        }).toList(),
                    onChanged: (type) {
                      if (type != null) {
                        setState(() {
                          selectedType = type;
                        });
                      }
                    },
                  ),
                  TextField(
                    controller: amountController,
                    decoration: const InputDecoration(labelText: 'Amount'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Describe'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed:
                      isButtonEnabled
                          ? () {
                            final amount = double.tryParse(
                              amountController.text,
                            );
                            if (amount != null) {
                              final currency = Currency(
                                code: 'USD',
                                symbol: '\$',
                              );
                              final transaction = Transaction(
                                id:
                                    DateTime.now().millisecondsSinceEpoch
                                        .toString(),
                                type: selectedType,
                                currency: currency,
                                amount: amount,
                                description: descriptionController.text,
                              );
                              Hive.box<Transaction>(
                                'transactions',
                              ).add(transaction);
                              Navigator.pop(context);
                            }
                          }
                          : null,
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
