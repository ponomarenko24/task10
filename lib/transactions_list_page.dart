import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:task_10/model.dart';

class TransactionListPage extends StatefulWidget {
  const TransactionListPage({super.key});

  @override
  State<TransactionListPage> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage> {
  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Transaction>('transactions');

    return Scaffold(
      appBar: AppBar(title: const Text('Finances')),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<Transaction> transactions, _) {
          final list = transactions.values.toList().reversed.toList();

          final balances = <Currency, double>{
            Currency.uah: 1000,
            Currency.usd: 1000,
            Currency.eur: 1000,
          };

          for (final tx in list) {
            balances[tx.currency] = (balances[tx.currency] ?? 0) +
                (tx.type == TransactionType.income ? tx.amount : -tx.amount);
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: Currency.values.map((currency) {
                    final balance = balances[currency]!;
                    return Column(
                      children: [
                        Text('${currency.code}:',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          '${balance.toStringAsFixed(2)} ${currency.symbol}',
                          style: TextStyle(
                            color: balance >= 0 ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
              const Divider(),
              Expanded(
                child: list.isEmpty
                    ? const Center(child: Text('No transactions'))
                    : ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final tx = list[index];
                          return ListTile(
                            title: Text(
                              '${tx.type == TransactionType.income ? '+' : '-'} ${tx.amount.toStringAsFixed(2)} ${tx.currency.code}',
                              style: TextStyle(
                                color: tx.type == TransactionType.income
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(tx.description ?? ''),
                            trailing:
                                Text('${tx.date.toLocal()}'.split(' ')[0]),
                          );
                        },
                      ),
              ),
            ],
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
    Currency selectedCurrency = Currency.uah;
    bool isButtonEnabled = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            void checkButtonState() {
              setState(() {
                isButtonEnabled = amountController.text.isNotEmpty &&
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
                    items: TransactionType.values.map((type) {
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
                        setState(() => selectedType = type);
                      }
                    },
                  ),
                  DropdownButton<Currency>(
                    value: selectedCurrency,
                    items: Currency.values.map((currency) {
                      return DropdownMenuItem(
                        value: currency,
                        child: Text(currency.code),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedCurrency = value);
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
                  onPressed: isButtonEnabled
                      ? () {
                          final amount =
                              double.tryParse(amountController.text);
                          if (amount != null) {
                            final tx = Transaction(
                              id: DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString(),
                              type: selectedType,
                              currency: selectedCurrency,
                              amount: amount,
                              description: descriptionController.text,
                            );
                            Hive.box<Transaction>('transactions').add(tx);
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
