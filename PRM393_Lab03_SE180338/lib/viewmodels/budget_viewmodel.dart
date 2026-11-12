import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/budget_model.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../services/firestore_service.dart';
import '../services/analytics_service.dart';
import '../utils/formatters.dart';

enum BudgetStatus {
  normal, // < 80% (Trong hạn mức)
  warning, // 80% - <100% (Sắp chạm hạn mức)
  reached, // == 100% (Đã chạm hạn mức)
  exceeded, // > 100% (Vượt hạn mức)
}

class BudgetCategoryStatus {
  final BudgetModel budget;
  final double spentAmount;
  final double remainingAmount;
  final double percentage; // 0.0 to 1.0+
  final BudgetStatus status;
  final String statusLabel;

  BudgetCategoryStatus({
    required this.budget,
    required this.spentAmount,
    required this.remainingAmount,
    required this.percentage,
    required this.status,
    required this.statusLabel,
  });
}

class BudgetViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final AnalyticsService _analyticsService;
  final String _userId;

  List<BudgetModel> _budgets = [];
  bool _isLoading = true;
  String? _errorMessage;
  StreamSubscription<List<BudgetModel>>? _subscription;

  String _selectedMonth = Formatters.formatMonth(DateTime.now());
  bool _isSaving = false;

  BudgetViewModel({
    required FirestoreService firestoreService,
    required AnalyticsService analyticsService,
    required String userId,
  }) : _firestoreService = firestoreService,
       _analyticsService = analyticsService,
       _userId = userId {
    _initStream();
  }

  void _initStream() {
    if (_userId.isEmpty) {
      _isLoading = false;
      notifyListeners();
      return;
    }
    _isLoading = true;
    _subscription?.cancel();
    _subscription = _firestoreService
        .streamBudgets(_userId)
        .listen(
          (data) {
            _budgets = data;
            _isLoading = false;
            notifyListeners();
          },
          onError: (err) {
            _errorMessage = 'Lỗi tải ngân sách: $err';
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  List<BudgetModel> get allBudgets => _budgets;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  String get selectedMonth => _selectedMonth;

  void setSelectedMonth(String month) {
    _selectedMonth = month;
    notifyListeners();
  }

  List<BudgetModel> get budgetsInSelectedMonth {
    return _budgets.where((b) => b.month == _selectedMonth).toList();
  }

  /// Total budget limit for selected month
  double get totalBudgetLimit {
    return budgetsInSelectedMonth.fold(0.0, (sum, b) => sum + b.limitAmount);
  }

  /// Calculate status for each budget category compared to actual transactions
  List<BudgetCategoryStatus> calculateStatuses(
    List<TransactionModel> transactions,
  ) {
    final list = <BudgetCategoryStatus>[];

    // Filter transactions for this month and expenses only
    final monthExpenses = transactions
        .where(
          (tx) =>
              tx.isExpense && Formatters.formatMonth(tx.date) == _selectedMonth,
        )
        .toList();

    for (var budget in budgetsInSelectedMonth) {
      final spent = monthExpenses
          .where((tx) => tx.categoryId == budget.categoryId)
          .fold(0.0, (sum, tx) => sum + tx.amount);

      final remaining = budget.limitAmount - spent;
      final ratio = budget.limitAmount > 0 ? (spent / budget.limitAmount) : 0.0;

      BudgetStatus status;
      String label;

      if (ratio > 1.0) {
        status = BudgetStatus.exceeded;
        final exceededAmount = spent - budget.limitAmount;
        label = 'Vượt hạn mức ${Formatters.formatCurrency(exceededAmount)}';
      } else if (ratio == 1.0) {
        status = BudgetStatus.reached;
        label = 'Đã chạm hạn mức';
      } else if (ratio >= 0.8) {
        status = BudgetStatus.warning;
        label = 'Sắp chạm hạn mức';
      } else {
        status = BudgetStatus.normal;
        label = 'Trong hạn mức';
      }

      list.add(
        BudgetCategoryStatus(
          budget: budget,
          spentAmount: spent,
          remainingAmount: remaining > 0 ? remaining : 0.0,
          percentage: ratio,
          status: status,
          statusLabel: label,
        ),
      );
    }

    return list;
  }

  /// Total remaining monthly budget across all categories
  double calculateTotalRemaining(List<TransactionModel> transactions) {
    final statuses = calculateStatuses(transactions);
    if (statuses.isEmpty) {
      // Default fallback if no budget is set yet
      return 1200000.0;
    }
    return statuses.fold(0.0, (sum, s) => sum + s.remainingAmount);
  }

  /// Save / update category budget
  Future<bool> saveBudget({
    required String month,
    required CategoryModel category,
    required double limitAmount,
  }) async {
    _isSaving = true;
    notifyListeners();

    try {
      final budget = BudgetModel(
        id: '',
        userId: _userId,
        month: month,
        categoryId: category.id,
        categoryName: category.name,
        limitAmount: limitAmount,
        createdAt: DateTime.now(),
      );

      await _firestoreService.setBudget(_userId, budget);
      await _analyticsService.logCreateBudget(
        category: category.name,
        limitAmount: limitAmount,
      );

      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Lưu ngân sách thất bại: $e';
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
