import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/models/transaction_model.dart';

class TransactionCard extends StatelessWidget {
  const TransactionCard({
    super.key,
    required this.item,
    this.onTap,
    this.onDelete,
  });

  final TransactionModel item;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final deposit = item.type == 'deposit';
    final color = deposit ? Colors.green : Colors.red;

    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: .14),
          child: Icon(
            deposit
                ? Icons.south_west
                : Icons.north_east,
            color: color,
          ),
        ),
        title: Text(
          item.description.isEmpty
              ? (deposit
                  ? 'Deposit'
                  : 'Withdrawal')
              : item.description,
        ),
        subtitle: Text(
          '${deposit ? 'Deposit' : 'Withdrawal'} • '
          '${DateFormat.yMMMd().format(item.transactionDate)}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${deposit ? '+' : '-'}'
              '${NumberFormat.currency(symbol: '฿').format(item.amount)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            if (onDelete != null)
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete',
              ),
          ],
        ),
      ),
    );
  }
}