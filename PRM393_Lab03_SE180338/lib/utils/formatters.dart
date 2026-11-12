import 'package:intl/intl.dart';

class Formatters {
  static final NumberFormat _currencyFormat = NumberFormat('#,###', 'vi_VN');
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _monthFormat = DateFormat('MM/yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('HH:mm dd/MM/yyyy');

  /// 45000 -> "45.000 VNĐ"
  static String formatCurrency(double amount) {
    return '${_currencyFormat.format(amount.round())} VNĐ';
  }

  /// Format with sign for transaction row
  /// -45.000 VNĐ (expense) or +500.000 VNĐ (income)
  static String formatTransactionAmount(
    double amount, {
    required bool isIncome,
  }) {
    final formatted = _currencyFormat.format(amount.round());
    if (isIncome) {
      return '+$formatted VNĐ';
    } else {
      return '−$formatted VNĐ';
    }
  }

  /// DateTime -> "12/11/2026"
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  /// DateTime -> "11/2026"
  static String formatMonth(DateTime date) {
    return _monthFormat.format(date);
  }

  /// DateTime -> "10:30 12/11/2026"
  static String formatDateTime(DateTime date) {
    return _dateTimeFormat.format(date);
  }

  /// Parse text like "45.000" or "45000" to double
  static double parseAmount(String input) {
    final clean = input
        .replaceAll('.', '')
        .replaceAll(',', '')
        .replaceAll(' ', '')
        .replaceAll('VNĐ', '')
        .trim();
    return double.tryParse(clean) ?? 0.0;
  }
}
