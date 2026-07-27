import 'package:flutter/material.dart';
import 'package:my_app/models/transaction_model.dart';
import 'package:my_app/screens/transaction_form_screen.dart';
import 'package:my_app/utils/app_api.dart';
import 'package:my_app/widgets/empty_state.dart';
import 'package:my_app/widgets/transaction_card.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  bool _loading = true;
  List<TransactionModel> _items = [];
  String? _type;
  int? _month;
  int? _year;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    try {
      final query = <String, String>{};

      if (_type != null) {
        query['type'] = _type!;
      }

      if (_month != null) {
        query['month'] = '$_month';
      }

      if (_year != null) {
        query['year'] = '$_year';
      }

      final data =
          (await AppApi.get('/transactions', query: query))['data'] as List;

      _items = data
          .map(
            (e) => TransactionModel.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList();
    } on ApiException catch (e) {
      _message(e.message);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _openForm([TransactionModel? item]) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => TransactionFormScreen(
          transaction: item,
        ),
      ),
    );

    if (changed == true) {
      _load();
    }
  }

  Future<void> _delete(TransactionModel item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete transaction?'),
        content: const Text(
          'Are you sure you want to delete this transaction?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) {
      return;
    }

    try {
      await AppApi.delete('/transactions/${item.id}');
      _message('Transaction deleted successfully.');
      _load();
    } on ApiException catch (e) {
      _message(e.message);
    }
  }

  void _message(String value) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(value),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                DropdownButton<String>(
                  value: _type,
                  hint: const Text('All types'),
                  items: const [
                    DropdownMenuItem(
                      value: 'deposit',
                      child: Text('Deposit'),
                    ),
                    DropdownMenuItem(
                      value: 'withdraw',
                      child: Text('Withdrawal'),
                    ),
                  ],
                  onChanged: (v) {
                    setState(() => _type = v);
                    _load();
                  },
                ),
                DropdownButton<int>(
                  value: _month,
                  hint: const Text('All months'),
                  items: List.generate(
                    12,
                    (i) => DropdownMenuItem(
                      value: i + 1,
                      child: Text('Month ${i + 1}'),
                    ),
                  ),
                  onChanged: (v) {
                    setState(() => _month = v);
                    _load();
                  },
                ),
                DropdownButton<int>(
                  value: _year,
                  hint: const Text('All years'),
                  items: List.generate(
                    6,
                    (i) => DropdownMenuItem(
                      value: now.year - i,
                      child: Text('${now.year - i}'),
                    ),
                  ),
                  onChanged: (v) {
                    setState(() => _year = v);
                    _load();
                  },
                ),
                if (_type != null || _month != null || _year != null)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _type = null;
                        _month = null;
                        _year = null;
                      });

                      _load();
                    },
                    child: const Text('Clear'),
                  ),
              ],
            ),
          ),

          // Transaction list
          Expanded(
            child: RefreshIndicator(
              onRefresh: _load,
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : _items.isEmpty
                      ? ListView(
                          children: const [
                            EmptyState(
                              title: 'No transactions found',
                              message:
                                  'Try changing the filters or add a transaction.',
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(
                            12,
                            8,
                            12,
                            88,
                          ),
                          itemCount: _items.length,
                          itemBuilder: (_, index) {
                            return TransactionCard(
                              item: _items[index],
                              onTap: () => _openForm(_items[index]),
                              onDelete: () => _delete(_items[index]),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}