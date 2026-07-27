import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/login_screen.dart';
import 'package:my_app/models/transaction_model.dart';
import 'package:my_app/screens/monthly_summary_screen.dart';
import 'package:my_app/screens/transaction_list_screen.dart';
import 'package:my_app/utils/app_api.dart';
import 'package:my_app/widgets/empty_state.dart';
import 'package:my_app/widgets/transaction_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = true;
  String _username = '';
  Map<String, dynamic> _data = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    try {
      _username = (await SharedPreferences.getInstance())
              .getString('username') ??
          'User';

      _data = (await AppApi.get('/dashboard'))['data']
          as Map<String, dynamic>;
    } on ApiException catch (e) {
      if (mounted) {
        _message(e.message);
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _message(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Future<void> _logout() async {
    await (await SharedPreferences.getInstance()).clear();

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
        (_) => false,
      );
    }
  }

  String _money(dynamic value) {
    return NumberFormat.currency(symbol: '฿')
        .format((value as num?)?.toDouble() ?? 0);
  }

  Widget _card(
    String label,
    dynamic value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: color,
            ),
            const SizedBox(height: 10),
            Text(label),
            const SizedBox(height: 4),
            Text(
              value.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recent = ((_data['recentTransactions'] ?? []) as List)
        .map(
          (e) => TransactionModel.fromJson(
            e as Map<String, dynamic>,
          ),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    'Hello, $_username',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 20),

                  Card(
                    color: const Color(0xFF00695C),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Current balance',
                            style: TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _money(_data['balance']),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _card(
                          'Total deposit',
                          _money(_data['totalDeposit']),
                          Icons.south_west,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _card(
                          'Total withdrawal',
                          _money(_data['totalWithdraw']),
                          Icons.north_east,
                          Colors.red,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  _card(
                    'Transactions',
                    '${_data['transactionCount'] ?? 0} records',
                    Icons.receipt_long_outlined,
                    Colors.blue,
                  ),

                  const SizedBox(height: 18),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const TransactionListScreen(),
                              ),
                            );
                            _load();
                          },
                          icon: const Icon(Icons.list_alt),
                          label: const Text('Transactions'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const MonthlySummaryScreen(),
                            ),
                          ),
                          icon: const Icon(Icons.calendar_month),
                          label:
                              const Text('Monthly summary'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Recent transactions',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),

                  const SizedBox(height: 8),

                  if (recent.isEmpty)
                    const EmptyState(
                      title: 'No transactions yet',
                      message:
                          'Add your first deposit or withdrawal from Transactions.',
                    )
                  else
                    ...recent.map(
                      (item) => TransactionCard(item: item),
                    ),
                ],
              ),
      ),
    );
  }
}