import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/notification_item.dart';
import '../models/report_model.dart';
import '../models/transaction_model.dart';
import '../services/remote_config_service.dart';
import '../services/crashlytics_service.dart';
import '../services/pdf_export_service.dart';
import '../services/firestore_service.dart';
import '../services/analytics_service.dart';

class SettingsViewModel extends ChangeNotifier {
  final RemoteConfigService _remoteConfigService;
  final CrashlyticsService _crashlyticsService;
  final PdfExportService _pdfExportService;
  final FirestoreService _firestoreService;
  final AnalyticsService _analyticsService;
  final String _userId;

  List<NotificationItem> _notifications = [];
  List<ReportModel> _reports = [];
  bool _isExporting = false;
  String? _lastExportedUrl;
  String? _statusMessage;
  StreamSubscription<List<NotificationItem>>? _notifSubscription;
  StreamSubscription<List<ReportModel>>? _reportsSubscription;

  SettingsViewModel({
    required RemoteConfigService remoteConfigService,
    required CrashlyticsService crashlyticsService,
    required PdfExportService pdfExportService,
    required FirestoreService firestoreService,
    required AnalyticsService analyticsService,
    required String userId,
  }) : _remoteConfigService = remoteConfigService,
       _crashlyticsService = crashlyticsService,
       _pdfExportService = pdfExportService,
       _firestoreService = firestoreService,
       _analyticsService = analyticsService,
       _userId = userId {
    _initStreams();
  }

  void _initStreams() {
    if (_userId.isEmpty) return;
    _notifSubscription = _firestoreService.streamNotifications(_userId).listen((
      items,
    ) {
      _notifications = items;
      notifyListeners();
    });
    _reportsSubscription = _firestoreService.streamReports(_userId).listen((
      items,
    ) {
      _reports = items;
      notifyListeners();
    });
  }

  // Getters
  List<NotificationItem> get notifications => _notifications;
  List<ReportModel> get reports => _reports;
  bool get isExporting => _isExporting;
  String? get lastExportedUrl => _lastExportedUrl;
  String? get statusMessage => _statusMessage;

  // Remote Config Values
  double get spendingWarningThreshold =>
      _remoteConfigService.spendingWarningThreshold;
  String get promoBannerText => _remoteConfigService.promoBannerText;
  bool get enableBudgetTips => _remoteConfigService.enableBudgetTips;

  /// Re-fetch and activate remote config values (Demo)
  Future<void> refreshRemoteConfig() async {
    final updated = await _remoteConfigService.fetchAndActivate();
    _statusMessage = updated
        ? 'Đã cập nhật Remote Config từ máy chủ!'
        : 'Giá trị Remote Config chưa thay đổi.';
    notifyListeners();
  }

  /// Trigger Handled Exception in Crashlytics
  Future<void> recordHandledException() async {
    try {
      throw Exception(
        'Thử nghiệm ghi ngoại lệ có xử lý (PRM393 Handled Exception Demo)',
      );
    } catch (e, stack) {
      await _crashlyticsService.recordHandledException(
        message: e.toString(),
        stack: stack,
      );
      _statusMessage =
          'Đã gửi Exception có xử lý lên Firebase Crashlytics thành công!';
      notifyListeners();
    }
  }

  /// Trigger Forced Test Crash
  void triggerForceCrash() {
    _crashlyticsService.forceCrash();
  }

  /// Export PDF Report and upload to Cloudinary/Storage
  Future<ReportModel?> exportMonthlyReport({
    required String userName,
    required String month,
    required double totalIncome,
    required double totalExpense,
    required List<TransactionModel> transactions,
  }) async {
    _isExporting = true;
    _statusMessage = 'Đang tạo và tải lên báo cáo PDF...';
    notifyListeners();

    try {
      final report = await _pdfExportService.exportAndSaveReport(
        userId: _userId,
        userName: userName,
        month: month,
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        transactions: transactions,
      );

      _lastExportedUrl = report.fileUrl;
      await _analyticsService.logExportPdf(itemCount: transactions.length);
      _statusMessage = 'Đã xuất và lưu trữ báo cáo thành công!';
      _isExporting = false;
      notifyListeners();
      return report;
    } catch (e) {
      _statusMessage = 'Lỗi xuất báo cáo: $e';
      _isExporting = false;
      notifyListeners();
      return null;
    }
  }

  @override
  void dispose() {
    _notifSubscription?.cancel();
    _reportsSubscription?.cancel();
    super.dispose();
  }
}
