import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  FirebaseAnalyticsObserver get analyticsObserver =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  Future<void> logLogin({String method = 'google'}) async {
    try {
      await _analytics.logLogin(loginMethod: method);
      debugPrint('[Analytics] Logged login with $method');
    } catch (_) {}
  }

  Future<void> logLogout() async {
    try {
      await _analytics.logEvent(name: 'logout');
      debugPrint('[Analytics] Logged logout');
    } catch (_) {}
  }

  Future<void> logScreenView(String screenName) async {
    try {
      await _analytics.logScreenView(screenName: screenName);
      debugPrint('[Analytics] Logged screen_view: $screenName');
    } catch (_) {}
  }

  Future<void> logViewTransaction({
    required String id,
    required String name,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'view_transaction',
        parameters: {'item_id': id, 'item_name': name},
      );
      debugPrint('[Analytics] Logged view_transaction: $id - $name');
    } catch (_) {}
  }

  Future<void> logCreateTransaction({
    required String id,
    required double amount,
    required String category,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'create_transaction',
        parameters: {'item_id': id, 'amount': amount, 'category': category},
      );
      // Lab 2 flow custom event
      await _analytics.logEvent(
        name: 'add_expense_flow_complete',
        parameters: {'category': category, 'amount': amount},
      );
      debugPrint(
        '[Analytics] Logged create_transaction & add_expense_flow_complete',
      );
    } catch (_) {}
  }

  Future<void> logUpdateTransaction({required String id}) async {
    try {
      await _analytics.logEvent(
        name: 'update_transaction',
        parameters: {'item_id': id},
      );
    } catch (_) {}
  }

  Future<void> logDeleteTransaction({required String id}) async {
    try {
      await _analytics.logEvent(
        name: 'delete_transaction',
        parameters: {'item_id': id},
      );
    } catch (_) {}
  }

  Future<void> logCreateBudget({
    required String category,
    required double limitAmount,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'create_budget',
        parameters: {'category': category, 'limit_amount': limitAmount},
      );
      // Lab 2 flow custom event
      await _analytics.logEvent(
        name: 'set_budget_flow_complete',
        parameters: {'category': category, 'limit_amount': limitAmount},
      );
    } catch (_) {}
  }

  Future<void> logViewCategoryStats({
    required String category,
    required String month,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'view_statistics_category',
        parameters: {'category_name': category, 'month': month},
      );
    } catch (_) {}
  }

  Future<void> logExportPdf({required int itemCount}) async {
    try {
      await _analytics.logEvent(
        name: 'export_pdf',
        parameters: {'item_count': itemCount},
      );
      debugPrint('[Analytics] Logged export_pdf with $itemCount items');
    } catch (_) {}
  }
}
