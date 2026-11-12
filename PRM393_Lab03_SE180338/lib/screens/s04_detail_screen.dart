import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/transaction_model.dart';
import '../viewmodels/transaction_viewmodel.dart';
import '../services/analytics_service.dart';
import '../viewmodels/budget_viewmodel.dart';
import 's07_budget_screen.dart';
import 's10_profile_screen.dart';
import '../widgets/design_widgets.dart';
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
    final budgetVm = context.watch<BudgetViewModel>();
    final transactions = context.watch<TransactionViewModel>().allTransactions;
    final month = Formatters.formatMonth(_tx.date);
    final budgets = budgetVm.allBudgets.where((b) => b.month == month).toList();
    final limit = budgets.fold(0.0, (sum, b) => sum + b.limitAmount);
    final spent = transactions
        .where(
          (t) =>
              t.isExpense &&
              Formatters.formatMonth(t.date) == month &&
              budgets.any((b) => b.categoryId == t.categoryId),
        )
        .fold(0.0, (sum, t) => sum + t.amount);
    final today = DateUtils.isSameDay(_tx.date, DateTime.now());
    final dateLabel =
        '${today ? "Hôm nay, " : ""}${Formatters.formatDate(_tx.date)}';
    void openBudget() {
      budgetVm.setSelectedMonth(month);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Ngân sách')),
            body: const BudgetScreen(),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi Tiết Giao Dịch'),
        titleSpacing: 0,
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Thao tác giao dịch',
            onSelected: (action) {
              if (action == 'edit') {
                _handleEditNote();
              } else {
                _handleDelete();
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Chỉnh sửa ghi chú')),
              PopupMenuItem(value: 'delete', child: Text('Xóa giao dịch')),
            ],
          ),
          IconButton(
            tooltip: 'Hồ sơ cá nhân',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
            icon: const CircleAvatar(
              radius: 15,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person_outline, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: AppSpacing.screenPadding,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                const Positioned(
                  right: -32,
                  top: -32,
                  child: _AccentCircle(color: AppColors.primaryTint, size: 112),
                ),
                const Positioned(
                  left: -32,
                  bottom: -40,
                  child: _AccentCircle(color: Color(0xFFDFFBEF), size: 104),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 20,
                  ),
                  color: Colors.white.withValues(alpha: .65),
                  child: Column(
                    children: [
                      ClipOval(
                        child: CategoryIcon(name: _tx.categoryName, size: 60),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _tx.note.isNotEmpty
                            ? _tx.note.split('\n').first
                            : _tx.categoryName,
                        style: AppTextStyles.groupTitle,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryTint,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          isIncome ? '• Khoản thu' : '• Khoản chi',
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 10,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '${isIncome ? "+" : "−"}${Formatters.formatCurrency(_tx.amount).replaceAll(" VNĐ", "")} ₫',
                          style: AppTextStyles.prominentAmount.copyWith(
                            color: isIncome
                                ? AppColors.income
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Đã ghi nhận vào sổ giao dịch',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 10,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          DesignCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Thông tin chi tiết',
                        style: AppTextStyles.buttonAndLabel,
                      ),
                    ),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 125),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryTint,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        'Mã ${_tx.id.isEmpty ? "—" : _tx.id}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 9,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _detail(
                  Icons.category_outlined,
                  'Danh mục',
                  Text(
                    _tx.categoryName,
                    style: AppTextStyles.buttonAndLabel.copyWith(fontSize: 12),
                  ),
                ),
                _detail(
                  Icons.swap_vert,
                  'Loại giao dịch',
                  Text(
                    isIncome ? 'Khoản thu nhập' : 'Khoản chi tiêu',
                    style: AppTextStyles.caption.copyWith(
                      color: isIncome ? AppColors.income : AppColors.expense,
                    ),
                  ),
                ),
                _detail(
                  Icons.calendar_today_outlined,
                  'Thời gian',
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        dateLabel,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        Formatters.formatTime(_tx.date),
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 10,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                _detail(
                  Icons.payments_outlined,
                  'Phương thức',
                  Text(
                    _tx.paymentMethod ?? 'Chưa cập nhật',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.notes_outlined,
                      size: 18,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text('Ghi chú', style: AppTextStyles.caption),
                    ),
                    IconButton(
                      tooltip: 'Chỉnh sửa ghi chú',
                      visualDensity: VisualDensity.compact,
                      onPressed: _handleEditNote,
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _tx.note.isEmpty ? 'Không có ghi chú' : _tx.note,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                InkWell(
                  onTap: openBudget,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.pie_chart_outline,
                          size: 18,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Thuộc ngân sách',
                            style: AppTextStyles.caption,
                          ),
                        ),
                        Text(
                          'Tháng $month',
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 11,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: openBudget,
                  borderRadius: BorderRadius.circular(10),
                  child: DesignCard(
                    color: AppColors.primaryTint,
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.account_balance_wallet_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Số dư ngân sách sau chi:',
                                style: AppTextStyles.caption,
                              ),
                              Text(
                                budgets.isEmpty
                                    ? 'Chưa thiết lập ngân sách'
                                    : '${Formatters.formatCurrency(limit - spent)} còn lại',
                                style: AppTextStyles.buttonAndLabel.copyWith(
                                  fontSize: 12,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detail(IconData icon, String label, Widget value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textTertiary),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: AppTextStyles.caption)),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: Align(alignment: Alignment.centerRight, child: value),
        ),
      ],
    ),
  );
}

class _AccentCircle extends StatelessWidget {
  final Color color;
  final double size;
  const _AccentCircle({required this.color, required this.size});
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}
