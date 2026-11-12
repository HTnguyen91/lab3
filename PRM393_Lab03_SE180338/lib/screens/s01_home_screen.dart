import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/transaction_viewmodel.dart';
import '../viewmodels/budget_viewmodel.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../widgets/design_widgets.dart';
import '../widgets/primary_button.dart';
import '../widgets/transaction_row.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/formatters.dart';
import 's02_add_transaction_screen.dart';
import 's04_detail_screen.dart';
import 's08_create_budget_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onOpenHistory;
  const HomeScreen({super.key, required this.onOpenHistory});
  @override
  Widget build(BuildContext context) {
    final txVm = context.watch<TransactionViewModel>();
    final budgetVm = context.watch<BudgetViewModel>();
    final settings = context.watch<SettingsViewModel>();
    final month = Formatters.formatMonth(DateTime.now());
    final budgets = budgetVm.allBudgets.where((b) => b.month == month).toList();
    final limit = budgets.fold(0.0, (s, b) => s + b.limitAmount);
    final spent = txVm.allTransactions
        .where(
          (t) =>
              t.isExpense &&
              Formatters.formatMonth(t.date) == month &&
              budgets.any((b) => b.categoryId == t.categoryId),
        )
        .fold(0.0, (s, t) => s + t.amount);
    final today = txVm.allTransactions
        .where((t) => DateUtils.isSameDay(t.date, DateTime.now()))
        .length;
    void add({String? category}) => Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddTransactionScreen(prefillCategory: category),
      ),
    );
    return RefreshIndicator(
      onRefresh: settings.refreshRemoteConfig,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chào ${context.watch<AuthViewModel>().displayName}',
                      style: AppTextStyles.groupTitle,
                    ),
                    const Text(
                      'Quản lý chi tiêu sinh viên',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  budgets.isEmpty
                      ? 'Bắt đầu tiết kiệm'
                      : spent > limit
                      ? 'Vượt hạn mức'
                      : 'Tiết kiệm tốt',
                  style: TextStyle(fontSize: 10, color: AppColors.income),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          DesignCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  budgets.isEmpty
                      ? 'Ngân sách tháng'
                      : 'Ngân sách tháng còn lại',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 10),
                Text(
                  budgets.isEmpty
                      ? 'Chưa thiết lập'
                      : Formatters.formatCurrency(limit - spent),
                  style: AppTextStyles.prominentAmount.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                if (budgets.isNotEmpty) ...[
                  Wrap(
                    spacing: 16,
                    runSpacing: 4,
                    children: [
                      Text(
                        'Đã chi: ${Formatters.formatCurrency(spent)}',
                        style: AppTextStyles.caption,
                      ),
                      Text(
                        'Hạn mức: ${Formatters.formatCurrency(limit)}',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: limit > 0 ? (spent / limit).clamp(0, 1) : 0,
                      minHeight: 6,
                      backgroundColor: AppColors.primaryTint,
                      color: spent > limit
                          ? AppColors.expense
                          : AppColors.primary,
                    ),
                  ),
                ] else
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreateBudgetScreen(),
                      ),
                    ),
                    child: const Text('Thiết lập ngân sách ngay →'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          DesignCard(
            color: AppColors.primaryTint,
            child: Row(
              children: [
                const CategoryIcon(name: 'Hóa đơn & Tiện ích'),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hôm nay, ${Formatters.formatDate(DateTime.now())}',
                        style: AppTextStyles.caption,
                      ),
                      Text(
                        '$today giao dịch phát sinh',
                        style: AppTextStyles.buttonAndLabel,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '−${Formatters.formatCurrency(txVm.todayExpense)}',
                      style: AppTextStyles.buttonAndLabel.copyWith(
                        color: AppColors.expense,
                      ),
                    ),
                    const Text(
                      'Tổng chi hôm nay',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            label: 'Thêm khoản chi',
            icon: Icons.add_circle_outline,
            onPressed: () => add(),
          ),
          const SizedBox(height: 24),
          const Text(
            'Mục hay chi hôm nay',
            style: AppTextStyles.buttonAndLabel,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (final item in [
                ('Ăn uống', Icons.lunch_dining_outlined, 'Ăn uống'),
                ('Cà phê', Icons.local_cafe_outlined, 'Ăn uống'),
                ('Xe buýt', Icons.directions_bus_outlined, 'Đi lại'),
                ('In ấn', Icons.print_outlined, 'Học tập & Sách'),
              ])
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => add(category: item.$3),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Column(
                            children: [
                              Icon(item.$2, color: AppColors.primary, size: 22),
                              const SizedBox(height: 8),
                              Text(item.$1, style: AppTextStyles.caption),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: Text('Gần đây', style: AppTextStyles.groupTitle),
              ),
              TextButton(
                onPressed: onOpenHistory,
                child: const Text('Xem tất cả ›'),
              ),
            ],
          ),
          if (txVm.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (txVm.recentTransactions.isEmpty)
            DesignCard(
              child: Column(
                children: [
                  const Icon(
                    Icons.receipt_long_outlined,
                    color: AppColors.primary,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  const Text('Chưa có giao dịch nào'),
                  TextButton(
                    onPressed: () => add(),
                    child: const Text('Thêm khoản chi đầu tiên'),
                  ),
                ],
              ),
            )
          else
            ...txVm.recentTransactions.map(
              (tx) => TransactionRow(
                transaction: tx,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TransactionDetailScreen(transaction: tx),
                  ),
                ),
              ),
            ),
          if (settings.enableBudgetTips && settings.promoBannerText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: DesignCard(
                color: AppColors.primaryTint,
                child: Text(
                  settings.promoBannerText,
                  style: AppTextStyles.caption,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
