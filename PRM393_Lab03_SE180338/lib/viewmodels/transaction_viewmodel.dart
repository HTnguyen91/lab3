import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../services/firestore_service.dart';
import '../services/analytics_service.dart';
import '../utils/formatters.dart';

class TransactionViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final AnalyticsService _analyticsService;
  final String _userId;

  List<TransactionModel> _transactions = [];
  bool _isLoading = true;
  String? _errorMessage;
  StreamSubscription<List<TransactionModel>>? _subscription;

  // Selected filter month (MM/yyyy)
  String _selectedMonth = Formatters.formatMonth(DateTime.now());

  // Input validation errors
  String? _amountError;
  String? _categoryError;
  bool _isSaving = false;

  TransactionViewModel({
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
        .streamTransactions(_userId)
        .listen(
          (data) {
            _transactions = data;
            _isLoading = false;
            notifyListeners();
          },
          onError: (err) {
            _errorMessage = 'Lỗi tải dữ liệu giao dịch: $err';
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  // Getters
  List<TransactionModel> get allTransactions => _transactions;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  String? get amountError => _amountError;
  String? get categoryError => _categoryError;
  String get selectedMonth => _selectedMonth;

  void setSelectedMonth(String month) {
    _selectedMonth = month;
    notifyListeners();
  }

  /// Transactions for selected month
  List<TransactionModel> get transactionsInSelectedMonth {
    return _transactions
        .where((tx) => Formatters.formatMonth(tx.date) == _selectedMonth)
        .toList();
  }

  /// Recent transactions (up to 5 for HomeScreen)
  List<TransactionModel> get recentTransactions {
    return _transactions.take(5).toList();
  }

  /// Total expense today
  double get todayExpense {
    final now = DateTime.now();
    return _transactions
        .where(
          (tx) =>
              tx.isExpense &&
              tx.date.year == now.year &&
              tx.date.month == now.month &&
              tx.date.day == now.day,
        )
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  /// Total expense in current month
  double get currentMonthExpense {
    final currentMonth = Formatters.formatMonth(DateTime.now());
    return _transactions
        .where(
          (tx) =>
              tx.isExpense && Formatters.formatMonth(tx.date) == currentMonth,
        )
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  /// Total income in current month
  double get currentMonthIncome {
    final currentMonth = Formatters.formatMonth(DateTime.now());
    return _transactions
        .where(
          (tx) =>
              tx.isIncome && Formatters.formatMonth(tx.date) == currentMonth,
        )
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  /// Clear validation errors
  void clearValidationErrors() {
    _amountError = null;
    _categoryError = null;
    notifyListeners();
  }

  /// Validate form inputs according to Lab 2 DESIGN.md specification:
  /// - Empty amount: "Nhập số tiền."
  /// - Non-positive amount: "Nhập số tiền lớn hơn 0 VNĐ."
  /// - Missing category: "Chọn một danh mục."
  bool validateTransaction({
    required String amountText,
    required CategoryModel? category,
  }) {
    bool isValid = true;
    _amountError = null;
    _categoryError = null;

    final trimmed = amountText.trim();
    if (trimmed.isEmpty) {
      _amountError = 'Nhập số tiền.';
      isValid = false;
    } else {
      final val = Formatters.parseAmount(trimmed);
      if (val <= 0) {
        _amountError = 'Nhập số tiền lớn hơn 0 VNĐ.';
        isValid = false;
      }
    }

    if (category == null || category.id.isEmpty) {
      _categoryError = 'Chọn một danh mục.';
      isValid = false;
    }

    notifyListeners();
    return isValid;
  }

  /// Save new transaction
  Future<bool> saveTransaction({
    required double amount,
    required String type,
    required CategoryModel category,
    required DateTime date,
    String note = '',
  }) async {
    _isSaving = true;
    notifyListeners();

    try {
      final tx = TransactionModel(
        id: '',
        userId: _userId,
        amount: amount,
        type: type,
        categoryId: category.id,
        categoryName: category.name,
        date: date,
        note: note,
        createdAt: DateTime.now(),
      );

      final docId = await _firestoreService.addTransaction(_userId, tx);
      await _analyticsService.logCreateTransaction(
        id: docId,
        amount: amount,
        category: category.name,
      );

      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Lưu thất bại: $e';
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  /// Update existing transaction
  Future<bool> updateTransaction(TransactionModel tx) async {
    _isSaving = true;
    notifyListeners();
    try {
      await _firestoreService.updateTransaction(_userId, tx);
      await _analyticsService.logUpdateTransaction(id: tx.id);
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Cập nhật thất bại: $e';
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete transaction
  Future<bool> deleteTransaction(String txId) async {
    try {
      await _firestoreService.deleteTransaction(_userId, txId);
      await _analyticsService.logDeleteTransaction(id: txId);
      return true;
    } catch (e) {
      _errorMessage = 'Xóa thất bại: $e';
      notifyListeners();
      return false;
    }
  }

  /// Seed initial demo data
  Future<void> seedInitialData() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firestoreService.seedLab2Data(_userId);
    } catch (e) {
      _errorMessage = 'Seed data error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
