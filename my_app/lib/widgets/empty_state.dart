// ==============================================================================
// EmptyState Widget: ส่วนแสดงผลเมื่อยังไม่มีข้อมูลในรายการ (Empty Placeholder)
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:my_app/theme/app_colors.dart';

/// Widget แสดงสถานะว่างเปล่า พร้อม Icon, หัวข้อ และคำอธิบายแนะนำการใช้งาน
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.receipt_long_outlined,
  });

  final String title;
  final String message;
  final IconData icon;


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primaryLight,
                width: 1.5,
              ),
            ),
            child: Icon(
              icon,
              size: 34,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}