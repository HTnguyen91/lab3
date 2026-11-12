import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/transaction_viewmodel.dart';
import '../models/transaction_model.dart';
import '../widgets/transaction_row.dart';
import '../widgets/empty_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/formatters.dart';
import 's02_add_transaction_screen.dart';
import 's04_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _filterType = 'all'; // all, expense, income
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TransactionViewModel>();
    final allTxs = vm.allTransactions;

    // Filter by type & search text
    final filtered = allTxs.where((tx) {
      if (_filterType == 'expense' && !tx.isExpense) return false;
      if (_filterType == 'income' && !tx.isIncome) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchesCat = tx.categoryName.toLowerCase().contains(q);
        final matchesNote = tx.note.toLowerCase().contains(q);
        if (!matchesCat && !matchesNote) return false;
      }
      return true;
    }).toList();

    // Group by Date String: dd/MM/yyyy
    final grouped = <String, List<TransactionModel>>{};
    for (var tx in filtered) {
      final dateKey = Formatters.formatDate(tx.date);
      grouped.putIfAbsent(dateKey, () => []).add(tx);
    }

    return Scaffold(
      body: Column(
        children: [
          // Filter & Search bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.surface,
            child: Column(
              children: [
                // Search box
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm theo danh mục, ghi chú...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.trim();
                    });
                  },
                ),
                const SizedBox(height: 8),

                // Type filter chips
                Row(
                  children: [
                    _buildFilterChip('Tất cả', 'all'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Khoản chi', 'expense'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Khoản thu', 'income'),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),

          // Transaction list
          Expanded(
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : grouped.isEmpty
                ? EmptyStateWidget(
                    icon: Icons.history,
                    title: 'Không tìm thấy giao dịch',
                    message: 'Chưa có dữ liệu nào phù hợp với bộ lọc hiện tại.',
                    action: OutlinedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Thêm giao dịch ngay'),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AddTransactionScreen(),
                          ),
                        );
                      },
                    ),
                  )
                : ListView.builder(
                    padding: AppSpacing.screenPadding,
                    itemCount: grouped.keys.length,
                    itemBuilder: (context, index) {
                      final dateKey = grouped.keys.elementAt(index);
                      final items = grouped[dateKey]!;

                      // Daily sum
                      final daySum = items.fold(
                        0.0,
                        (s, tx) => s + (tx.isIncome ? tx.amount : -tx.amount),
                      );

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date Group Header
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  dateKey,
                                  style: AppTextStyles.groupTitle.copyWith(
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  daySum >= 0
                                      ? '+${Formatters.formatCurrency(daySum)}'
                                      : '−${Formatters.formatCurrency(daySum.abs())}',
                                  style: AppTextStyles.caption.copyWith(
                                    color: daySum >= 0
                                        ? AppColors.income
                                        : AppColors.expense,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Items in day
                          ...items.map((tx) {
                            return TransactionRow(
                              transaction: tx,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => TransactionDetailScreen(
                                      transaction: tx,
                                    ),
                                  ),
                                );
                              },
                            );
                          }),
                          const SizedBox(height: 8),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterType == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primaryTint,
      labelStyle: AppTextStyles.caption.copyWith(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.divider,
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _filterType = value;
          });
        }
      },
    );
  }
}
