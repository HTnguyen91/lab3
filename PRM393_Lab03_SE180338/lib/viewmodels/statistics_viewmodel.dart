import 'package:flutter/foundation.dart';

import '../models/transaction_model.dart';
import '../services/analytics_service.dart';
import '../utils/formatters.dart';

class CategoryExpenseSummary {
  final String categoryId;
  final String categoryName;
  final double totalAmount;
  final double percentage; // 0.0 - 100.0%
  final int transactionCount;

  CategoryExpenseSummary({
    required this.categoryId,
    required this.categoryName,
    required this.totalAmount,
    required this.percentage,
    required this.transactionCount,
  });
}

class StatisticsViewModel extends ChangeNotifier {
  final AnalyticsService _analyticsService;

  String _selectedMonth = Formatters.formatMonth(DateTime.now());
  String? _selectedCategoryId;
  String? _selectedCategoryName;

  StatisticsViewModel({required AnalyticsService analyticsService})
    : _analyticsService = analyticsService;

  String get selectedMonth => _selectedMonth;
  String? get selectedCategoryId => _selectedCategoryId;
  String? get selectedCategoryName => _selectedCategoryName;

  void setSelectedMonth(String month) {
    _selectedMonth = month;
    notifyListeners();
  }

  void selectCategoryForDetail(String catId, String catName) {
    _selectedCategoryId = catId;
    _selectedCategoryName = catName;
    _analyticsService.logViewCategoryStats(
      category: catName,
      month: _selectedMonth,
    );
    notifyListeners();
  }

  /// Filter all transactions for selected month
  List<TransactionModel> getMonthTransactions(List<TransactionModel> all) {
    return all
        .where((tx) => Formatters.formatMonth(tx.date) == _selectedMonth)
        .toList();
  }

  /// Total income in selected month
  double getTotalIncome(List<TransactionModel> all) {
    return getMonthTransactions(all)
        .where((tx) => tx.isIncome)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  /// Total expense in selected month
  double getTotalExpense(List<TransactionModel> all) {
    return getMonthTransactions(all)
        .where((tx) => tx.isExpense)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  /// Balance (Income - Expense)
  double getBalance(List<TransactionModel> all) {
    return getTotalIncome(all) - getTotalExpense(all);
  }

  /// Breakdown by category, sorted descending by total expense
  List<CategoryExpenseSummary> getCategoryBreakdown(
    List<TransactionModel> all,
  ) {
    final monthExpenses = getMonthTransactions(all)
        .where((tx) => tx.isExpense)
        .toList();
    final total = getTotalExpense(all);

    final map = <String, List<TransactionModel>>{};
    for (var tx in monthExpenses) {
      map.putIfAbsent(tx.categoryId, () => []).add(tx);
    }

    final list = <CategoryExpenseSummary>[];
    map.forEach((catId, txs) {
      final sum = txs.fold(0.0, (s, t) => s + t.amount);
      final percent = total > 0 ? ((sum / total) * 100.0) : 0.0;
      list.add(
        CategoryExpenseSummary(
          categoryId: catId,
          categoryName: txs.first.categoryName,
          totalAmount: sum,
          percentage: percent,
          transactionCount: txs.length,
        ),
      );
    });

    // Sort descending by totalAmount
    list.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
    return list;
  }

  /// Transactions for the currently selected category in S06
  List<TransactionModel> getSelectedCategoryTransactions(
    List<TransactionModel> all,
  ) {
    if (_selectedCategoryId == null) return [];
    return getMonthTransactions(all)
        .where((tx) => tx.isExpense && tx.categoryId == _selectedCategoryId)
        .toList();
  }
}
