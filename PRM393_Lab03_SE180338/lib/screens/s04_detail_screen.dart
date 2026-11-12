import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/transaction_model.dart';
import '../viewmodels/transaction_viewmodel.dart';
import '../services/analytics_service.dart';
import '../widgets/secondary_button.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/formatters.dart';

class TransactionDetailScreen extends StatefulWidget {
  final TransactionModel transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  late TransactionModel _tx;

  @override
  void initState() {
    super.initState();
    _tx = widget.transaction;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalyticsService>().logViewTransaction(
        id: _tx.id,
        name: '${_tx.categoryName} - ${Formatters.formatCurrency(_tx.amount)}',
      );
    });
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Xác nhận xóa giao dịch',
            style: AppTextStyles.groupTitle,
          ),
          content: Text(
            'Bạn có chắc chắn muốn xóa giao dịch ${_tx.categoryName} (${Formatters.formatCurrency(_tx.amount)}) không? Hành động này không thể hoàn tác.',
            style: AppTextStyles.body,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Hủy',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Xóa', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      final success = await context
          .read<TransactionViewModel>()
          .deleteTransaction(_tx.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa giao dịch thành công.')),
        );
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _handleEditNote() async {
    final noteController = TextEditingController(text: _tx.note);
    final newNote = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Chỉnh sửa ghi chú',
            style: AppTextStyles.groupTitle,
          ),
          content: TextField(
            controller: noteController,
            decoration: const InputDecoration(hintText: 'Nhập ghi chú mới'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).pop(noteController.text.trim()),
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );

    if (newNote != null && mounted) {
      final updated = _tx.copyWith(note: newNote);
      final success = await context
          .read<TransactionViewModel>()
          .updateTransaction(updated);
      if (success && mounted) {
        setState(() {
          _tx = updated;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã cập nhật giao dịch.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = _tx.isIncome;
    final amountColor = isIncome ? AppColors.income : AppColors.expense;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết giao dịch'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          children: [
            // Amount Card Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: isIncome
                    ? const Color(0xFFDCFCE7)
                    : AppColors.primaryTint,
                borderRadius: AppSpacing.cardRadius,
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  Text(
                    isIncome ? 'Khoản thu nhập' : 'Khoản chi tiêu',
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    Formatters.formatTransactionAmount(
                      _tx.amount,
                      isIncome: isIncome,
                    ),
                    style: AppTextStyles.prominentAmount.copyWith(
                      color: amountColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    Formatters.formatDateTime(_tx.date),
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s24),

            // Details Group Box
            Container(
              padding: AppSpacing.cardPadding,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppSpacing.cardRadius,
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    icon: Icons.category_outlined,
                    label: 'Danh mục',
                    value: _tx.categoryName,
                  ),
                  const Divider(height: 24, color: AppColors.divider),
                  _buildDetailRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Ngày thực hiện',
                    value: Formatters.formatDate(_tx.date),
                  ),
                  const Divider(height: 24, color: AppColors.divider),
                  _buildDetailRow(
                    icon: Icons.notes_outlined,
                    label: 'Ghi chú',
                    value: _tx.note.isNotEmpty ? _tx.note : 'Không có ghi chú',
                  ),
                  const Divider(height: 24, color: AppColors.divider),
                  _buildDetailRow(
                    icon: Icons.tag,
                    label: 'Mã giao dịch',
                    value: _tx.id.isNotEmpty ? _tx.id : 'Mẫu thử',
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s32),

            // Actions
            SecondaryButton(
              label: 'Chỉnh sửa ghi chú',
              icon: Icons.edit_outlined,
              onPressed: _handleEditNote,
            ),
            const SizedBox(height: AppSpacing.s12),
            SizedBox(
              height: AppSpacing.inputHeight,
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error, width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppSpacing.buttonRadius,
                  ),
                ),
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                label: const Text(
                  'Xóa giao dịch này',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                onPressed: _handleDelete,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.s12),
        Text(
          label,
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
