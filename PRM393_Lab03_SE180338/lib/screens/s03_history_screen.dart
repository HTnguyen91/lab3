import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/transaction_viewmodel.dart';
import '../models/transaction_model.dart';
import '../widgets/design_widgets.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/formatters.dart';
import '../utils/constants.dart';
import 's02_add_transaction_screen.dart';
import 's04_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String? _categoryId;
  String _type = 'all';
  String _query = '';
  bool _searching = false;
  final _search = TextEditingController();
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _filters() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Lọc loại giao dịch',
                style: AppTextStyles.groupTitle,
              ),
            ),
            for (final item in [
              ('all', 'Tất cả giao dịch'),
              ('expense', 'Khoản chi'),
              ('income', 'Khoản thu'),
            ])
              ListTile(
                title: Text(item.$2),
                trailing: _type == item.$1
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () => Navigator.pop(ctx, item.$1),
              ),
          ],
        ),
      ),
    );
    if (result != null && mounted) setState(() => _type = result);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TransactionViewModel>();
    final monthly = vm.transactionsInSelectedMonth;
    final expense = monthly
        .where((t) => t.isExpense)
        .fold(0.0, (s, t) => s + t.amount);
    final income = monthly
        .where((t) => t.isIncome)
        .fold(0.0, (s, t) => s + t.amount);
    final categories = <String, String>{
      for (final category in AppConstants.defaultCategories)
        category.id: category.name,
      for (final tx in monthly) tx.categoryId: tx.categoryName,
    };
    final filtered =
        monthly
            .where(
              (tx) =>
                  (_categoryId == null || tx.categoryId == _categoryId) &&
                  (_type == 'all' || tx.type == _type) &&
                  ('${tx.note} ${tx.categoryName}'.toLowerCase().contains(
                    _query.toLowerCase(),
                  )),
            )
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
    final groups = <DateTime, List<TransactionModel>>{};
    for (final tx in filtered) {
      groups.putIfAbsent(DateUtils.dateOnly(tx.date), () => []).add(tx);
    }
    final now = DateTime.now();
    final months = {
      ...List.generate(
        12,
        (i) => Formatters.formatMonth(DateTime(now.year, now.month - i)),
      ),
      ...vm.allTransactions.map((t) => Formatters.formatMonth(t.date)),
      vm.selectedMonth,
    }.toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.primaryTint,
                borderRadius: BorderRadius.circular(20),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isDense: true,
                  value: vm.selectedMonth,
                  borderRadius: BorderRadius.circular(16),
                  icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                  items: months
                      .map(
                        (m) => DropdownMenuItem(
                          value: m,
                          child: Text(
                            'Tháng $m',
                            style: AppTextStyles.buttonAndLabel,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (month) {
                    if (month != null) {
                      vm.setSelectedMonth(month);
                      setState(() => _categoryId = null);
                    }
                  },
                ),
              ),
            ),
            const Spacer(),
            _tool(
              Icons.search,
              'Tìm giao dịch',
              () => setState(() {
                _searching = !_searching;
                if (!_searching) {
                  _query = '';
                  _search.clear();
                }
              }),
            ),
            const SizedBox(width: 6),
            _tool(
              Icons.tune,
              'Bộ lọc giao dịch',
              _filters,
              active: _type != 'all',
            ),
          ],
        ),
        if (_searching)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: TextField(
              controller: _search,
              autofocus: true,
              onChanged: (value) => setState(() => _query = value.trim()),
              decoration: const InputDecoration(
                hintText: 'Tìm theo danh mục, ghi chú',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
        const SizedBox(height: 12),
        DesignCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Tổng quan tháng',
                      style: AppTextStyles.caption,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1FAE5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${monthly.length} giao dịch',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.income,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _total('Tổng chi tiêu', expense, false)),
                  const SizedBox(width: 16),
                  Expanded(child: _total('Tổng thu nhập', income, true)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _chip('Tất cả', null),
              ...categories.entries.map((e) => _chip(e.value, e.key)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (vm.isLoading)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (vm.errorMessage != null)
          DesignCard(
            child: Text(
              'Không tải được lịch sử giao dịch. Vui lòng kiểm tra kết nối.',
              style: AppTextStyles.errorCaption,
            ),
          )
        else if (groups.isEmpty)
          DesignCard(
            child: Column(
              children: [
                const Icon(
                  Icons.receipt_long_outlined,
                  size: 40,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  monthly.isEmpty
                      ? 'Chưa có giao dịch trong tháng này'
                      : 'Không tìm thấy giao dịch',
                  style: AppTextStyles.buttonAndLabel,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Đổi bộ lọc hoặc thêm giao dịch để bắt đầu.',
                  style: AppTextStyles.caption,
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddTransactionScreen(),
                    ),
                  ),
                  child: const Text('Thêm giao dịch'),
                ),
              ],
            ),
          )
        else
          ...groups.entries.map((group) {
            final net = group.value.fold(
              0.0,
              (s, t) => s + (t.isIncome ? t.amount : -t.amount),
            );
            final today = DateUtils.isSameDay(group.key, now);
            final yesterday = DateUtils.isSameDay(
              group.key,
              now.subtract(const Duration(days: 1)),
            );
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: today
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${today
                              ? "Hôm nay, "
                              : yesterday
                              ? "Hôm qua, "
                              : ""}${Formatters.formatDate(group.key)}',
                          style: AppTextStyles.buttonAndLabel,
                        ),
                      ),
                      Text(
                        '${net > 0 ? "+" : ""}${Formatters.formatCurrency(net)}',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 10,
                          color: net > 0
                              ? AppColors.income
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DesignCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    child: Column(
                      children: group.value
                          .map((tx) => _tile(context, tx))
                          .toList(),
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _total(String title, double amount, bool income) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: AppTextStyles.caption.copyWith(fontSize: 11)),
      const SizedBox(height: 4),
      Text(
        '${income ? "+" : "−"}${Formatters.formatCurrency(amount)}',
        style: AppTextStyles.bodyMedium.copyWith(
          color: income ? AppColors.income : AppColors.expense,
        ),
      ),
    ],
  );
  Widget _tool(
    IconData icon,
    String label,
    VoidCallback tap, {
    bool active = false,
  }) => IconButton(
    tooltip: label,
    onPressed: tap,
    style: IconButton.styleFrom(
      backgroundColor: AppColors.primaryTint,
      foregroundColor: active ? AppColors.primary : AppColors.textSecondary,
      minimumSize: const Size(40, 40),
      padding: EdgeInsets.zero,
    ),
    icon: Icon(icon, size: 18),
  );
  Widget _chip(String label, String? id) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: _categoryId == id ? Colors.white : AppColors.textSecondary,
        ),
      ),
      selected: _categoryId == id,
      showCheckmark: false,
      onSelected: (_) => setState(() => _categoryId = id),
    ),
  );
  Widget _tile(BuildContext context, TransactionModel tx) => InkWell(
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TransactionDetailScreen(transaction: tx),
      ),
    ),
    borderRadius: BorderRadius.circular(12),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          CategoryIcon(name: tx.categoryName),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.note.isNotEmpty
                      ? tx.note.split('\n').first
                      : tx.categoryName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.buttonAndLabel.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  '${tx.categoryName} · ${Formatters.formatTime(tx.date)}${tx.paymentMethod == null ? "" : " · ${tx.paymentMethod}"}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            Formatters.formatTransactionAmount(
              tx.amount,
              isIncome: tx.isIncome,
            ),
            style: AppTextStyles.buttonAndLabel.copyWith(
              fontSize: 12,
              color: tx.isIncome ? AppColors.income : AppColors.expense,
            ),
          ),
          const Icon(
            Icons.chevron_right,
            size: 14,
            color: AppColors.textTertiary,
          ),
        ],
      ),
    ),
  );
}
