import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            size: 56,
            color: Colors.grey,
          ),

          const SizedBox(height: 12),

          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),

          const SizedBox(height: 4),

          Text(
            message,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}