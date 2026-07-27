import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/utils/app_api.dart';

class MonthlySummaryScreen extends StatefulWidget {
  const MonthlySummaryScreen({super.key});

  @override
  State<MonthlySummaryScreen> createState() => _MonthlySummaryScreenState();
}

class _MonthlySummaryScreenState
    extends State<MonthlySummaryScreen> {
  late int _month;
  late int _year;

  bool _loading = true;
  Map<String, dynamic> _data = {};

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    _month = now.month;
    _year = now.year;

    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    try {
      _data = (await AppApi.get(
        '/summary/monthly',
        query: {
          'month': '$_month',
          'year': '$_year',
        },
      ))['data'] as Map<String, dynamic>;
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  String _money(dynamic value) {
    return NumberFormat.currency(
      symbol: '฿',
    ).format((value as num?)?.toDouble() ?? 0);
  }

  Widget _card(
    String title,
    dynamic amount,
    Color color,
    IconData icon,
  ) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: .14),
          child: Icon(
            icon,
            color: color,
          ),
        ),
        title: Text(title),
        trailing: Text(
          _money(amount),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final years = List.generate(
      6,
      (i) => DateTime.now().year - i,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly summary'),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _month,
                    decoration: const InputDecoration(
                      labelText: 'Month',
                      border: OutlineInputBorder(),
                    ),
                    items: List.generate(
                      12,
                      (i) => DropdownMenuItem(
                        value: i + 1,
                        child: Text(
                          DateFormat.MMMM().format(
                            DateTime(2000, i + 1),
                          ),
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _month = value);
                        _load();
                      }
                    },
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _year,
                    decoration: const InputDecoration(
                      labelText: 'Year',
                      border: OutlineInputBorder(),
                    ),
                    items: years
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text('$value'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _year = value);
                        _load();
                      }
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            if (_loading)
              const Padding(
                padding: EdgeInsets.all(36),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else ...[
              _card(
                'Monthly deposit',
                _data['totalDeposit'],
                Colors.green,
                Icons.south_west,
              ),

              _card(
                'Monthly withdrawal',
                _data['totalWithdraw'],
                Colors.red,
                Icons.north_east,
              ),

              const SizedBox(height: 12),

              Card(
                color: const Color(0xFF00695C),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Monthly balance',
                        style: TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _money(_data['balance']),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}