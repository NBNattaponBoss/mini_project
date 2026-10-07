// ==============================================================================
// TransactionCard Widget: การ์ดแสดงผลรายการธุรกรรม (ฝากเงิน / ถอนเงิน)
// ==============================================================================
// แสดงประเภทรายการ (ฝาก: เขียว, ถอน: แดง), วันที่, รายละเอียด, จำนวนเงิน
// และปุ่มลบรายการ (ถ้ามี)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/models/transaction_model.dart';
import 'package:my_app/theme/app_colors.dart';

/// Card แสดงรายการธุรกรรม 1 รายการ
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
    final bool isDeposit = item.type == 'deposit';
    final Color badgeColor = isDeposit ? AppColors.deposit : AppColors.withdrawal;
    final Color badgeBg = isDeposit ? AppColors.depositLight : AppColors.withdrawalLight;
    final String typeLabel = isDeposit ? 'ฝากเงิน' : 'ถอนเงิน';

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: AppColors.cardBorder,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Type Icon Badge
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isDeposit ? Icons.south_west_rounded : Icons.north_east_rounded,
                  color: badgeColor,
                  size: 22,
                ),
              ),

              const SizedBox(width: 14),

              // Title and Date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.description.isNotEmpty ? item.description : typeLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$typeLabel • ${DateFormat('d MMM yyyy').format(item.transactionDate)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Amount & Delete
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${isDeposit ? '+' : '-'}${NumberFormat.currency(symbol: '฿', decimalDigits: 2).format(item.amount)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: badgeColor,
                    ),
                  ),
                  if (onDelete != null) ...[
                    const SizedBox(width: 4),
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.textMuted,
                        size: 20,
                      ),
                      tooltip: 'ลบรายการ',
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}