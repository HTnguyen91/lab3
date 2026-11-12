import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

// App entry & screens
import 'package:expense_tracker/theme/app_theme.dart';
import 'package:expense_tracker/services/auth_service.dart';
import 'package:expense_tracker/services/firestore_service.dart';
import 'package:expense_tracker/services/analytics_service.dart';
import 'package:expense_tracker/services/crashlytics_service.dart';
import 'package:expense_tracker/services/remote_config_service.dart';
import 'package:expense_tracker/services/fcm_service.dart';
import 'package:expense_tracker/services/pdf_export_service.dart';

import 'package:expense_tracker/viewmodels/auth_viewmodel.dart';
import 'package:expense_tracker/viewmodels/transaction_viewmodel.dart';
import 'package:expense_tracker/viewmodels/budget_viewmodel.dart';
import 'package:expense_tracker/viewmodels/statistics_viewmodel.dart';
import 'package:expense_tracker/viewmodels/settings_viewmodel.dart';

import 'package:expense_tracker/screens/main_scaffold.dart';
import 'package:expense_tracker/screens/s02_add_transaction_screen.dart';
import 'package:expense_tracker/screens/s05_statistics_screen.dart';
import 'package:expense_tracker/screens/s07_budget_screen.dart';
import 'package:expense_tracker/screens/s08_create_budget_screen.dart';
import 'package:expense_tracker/screens/s10_profile_screen.dart';

import 'package:expense_tracker/widgets/overview_card.dart';

Widget createTestApp({required String testUserId}) {
  final authService = AuthService();
  final firestoreService = FirestoreService();
  final analyticsService = AnalyticsService();
  final crashlyticsService = CrashlyticsService();
  final remoteConfigService = RemoteConfigService();
  final fcmService = FCMService();
  final pdfExportService = PdfExportService();

  return MultiProvider(
    providers: [
      Provider<AuthService>.value(value: authService),
      Provider<FirestoreService>.value(value: firestoreService),
      Provider<AnalyticsService>.value(value: analyticsService),
      Provider<CrashlyticsService>.value(value: crashlyticsService),
      Provider<RemoteConfigService>.value(value: remoteConfigService),
      Provider<FCMService>.value(value: fcmService),
      Provider<PdfExportService>.value(value: pdfExportService),
      ChangeNotifierProvider<AuthViewModel>(
        create: (_) => AuthViewModel(
          authService: authService,
          analyticsService: analyticsService,
          crashlyticsService: crashlyticsService,
        ),
      ),
      ChangeNotifierProvider<StatisticsViewModel>(
        create: (_) => StatisticsViewModel(analyticsService: analyticsService),
      ),
      ChangeNotifierProvider<TransactionViewModel>(
        create: (_) => TransactionViewModel(
          firestoreService: firestoreService,
          analyticsService: analyticsService,
          userId: testUserId,
        ),
      ),
      ChangeNotifierProvider<BudgetViewModel>(
        create: (_) => BudgetViewModel(
          firestoreService: firestoreService,
          analyticsService: analyticsService,
          userId: testUserId,
        ),
      ),
      ChangeNotifierProvider<SettingsViewModel>(
        create: (_) => SettingsViewModel(
          remoteConfigService: remoteConfigService,
          crashlyticsService: crashlyticsService,
          pdfExportService: pdfExportService,
          firestoreService: firestoreService,
          analyticsService: analyticsService,
          userId: testUserId,
        ),
      ),
    ],
    child: MaterialApp(theme: AppTheme.lightTheme, home: const MainScaffold()),
  );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('PRM393 Lab 3 - End-to-End Automated Testing Suite', () {
    const testUserId = 'test_student_se180338';

    testWidgets(
      'E2E Test 1: App initializes, displays MainScaffold and 4 Bottom Tabs',
      (tester) async {
        await tester.pumpWidget(createTestApp(testUserId: testUserId));
        await tester.pumpAndSettle();

        // Verify Main Scaffold loaded
        expect(find.byType(MainScaffold), findsOneWidget);
        expect(find.text('Trang chủ'), findsWidgets);
        expect(find.text('Lịch sử'), findsOneWidget);
        expect(find.text('Thống kê'), findsOneWidget);
        expect(find.text('Ngân sách'), findsOneWidget);
        expect(find.byType(OverviewCard), findsOneWidget);
      },
    );

    testWidgets(
      'E2E Test 2: UF-01 Happy Path - Add 45.000 VNĐ lunch expense into Ăn uống',
      (tester) async {
        await tester.pumpWidget(createTestApp(testUserId: testUserId));
        await tester.pumpAndSettle();

        // Find and tap "Thêm khoản chi"
        final addBtn = find.text('Thêm khoản chi');
        expect(addBtn, findsOneWidget);
        await tester.tap(addBtn);
        await tester.pumpAndSettle();

        // Verify navigated to S02 Add Transaction
        expect(find.byType(AddTransactionScreen), findsOneWidget);
        expect(find.text('Thêm giao dịch'), findsOneWidget);

        // Enter 45000 in amount field
        final amountField = find.byType(TextFormField).first;
        await tester.enterText(amountField, '45000');
        await tester.pumpAndSettle();

        // Tap Save button
        final saveBtn = find.text('Lưu giao dịch');
        expect(saveBtn, findsOneWidget);
        await tester.tap(saveBtn);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
      },
    );

    testWidgets('E2E Test 3: UF-01 Validation & Error Recovery Path', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider(
            create: (_) => TransactionViewModel(
              firestoreService: FirestoreService(),
              analyticsService: AnalyticsService(),
              userId: testUserId,
            ),
            child: const AddTransactionScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Submit empty -> expect "Nhập số tiền."
      await tester.tap(find.text('Lưu giao dịch'));
      await tester.pumpAndSettle();
      expect(find.text('Nhập số tiền.'), findsOneWidget);

      // 2. Submit 0 -> expect "Nhập số tiền lớn hơn 0 VNĐ."
      final amountField = find.byType(TextFormField).first;
      await tester.enterText(amountField, '0');
      await tester.tap(find.text('Lưu giao dịch'));
      await tester.pumpAndSettle();
      expect(find.text('Nhập số tiền lớn hơn 0 VNĐ.'), findsOneWidget);

      // 3. Recovery: enter 45.000 VNĐ -> error clears
      await tester.enterText(amountField, '45000');
      await tester.pumpAndSettle();
      expect(find.text('Nhập số tiền lớn hơn 0 VNĐ.'), findsNothing);
    });

    testWidgets(
      'E2E Test 4: UF-02 Happy Path - Navigate to Statistics and inspect breakdown',
      (tester) async {
        await tester.pumpWidget(createTestApp(testUserId: testUserId));
        await tester.pumpAndSettle();

        // Tap Thống kê tab (index 2)
        await tester.tap(find.byIcon(Icons.bar_chart_outlined));
        await tester.pumpAndSettle();

        expect(find.byType(StatisticsScreen), findsOneWidget);
        expect(find.text('Kỳ thống kê'), findsOneWidget);
        expect(find.text('Tổng thu'), findsOneWidget);
        expect(find.text('Tổng chi'), findsOneWidget);
        expect(find.text('Số dư'), findsOneWidget);
      },
    );

    testWidgets(
      'E2E Test 5: UF-03 Happy Path - Navigate to Budget, open Create Budget and Cancel',
      (tester) async {
        await tester.pumpWidget(createTestApp(testUserId: testUserId));
        await tester.pumpAndSettle();

        // Tap Ngân sách tab (index 3)
        await tester.tap(find.byIcon(Icons.account_balance_wallet_outlined));
        await tester.pumpAndSettle();

        expect(find.byType(BudgetScreen), findsOneWidget);
        expect(find.text('Tháng áp dụng'), findsOneWidget);

        // Tap floating action button to create budget
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        // Verify S08 Create Budget Screen opened
        expect(find.byType(CreateBudgetScreen), findsOneWidget);
        expect(find.text('Tạo ngân sách danh mục'), findsOneWidget);
        expect(find.text('Hạn mức ngân sách'), findsOneWidget);

        // Test Cancel button (UF-03 cancel path)
        await tester.tap(find.text('Hủy'));
        await tester.pumpAndSettle();

        // Back on Budget Screen
        expect(find.byType(BudgetScreen), findsOneWidget);
      },
    );

    testWidgets(
      'E2E Test 6: Profile Screen, Remote Config & Crashlytics Controls',
      (tester) async {
        await tester.pumpWidget(createTestApp(testUserId: testUserId));
        await tester.pumpAndSettle();

        // Tap avatar on AppBar to open Profile Screen
        final avatarBtn = find.byTooltip('Hồ sơ cá nhân & Cài đặt');
        expect(avatarBtn, findsOneWidget);
        await tester.tap(avatarBtn);
        await tester.pumpAndSettle();

        // Verify S10 Profile Screen
        expect(find.byType(ProfileScreen), findsOneWidget);
        expect(find.text('Hồ sơ & Cài đặt Lab 3'), findsOneWidget);
        expect(find.text('MSSV: SE180338'), findsOneWidget);
        expect(
          find.text('Xuất Báo Cáo PDF & Lưu Trữ (Mục 6.4)'),
          findsOneWidget,
        );
        expect(find.text('Firebase Remote Config (Mục 6.6)'), findsOneWidget);
        expect(find.text('Firebase Crashlytics (Mục 6.7)'), findsOneWidget);
        expect(find.text('Notification Center (Mục 6.5)'), findsOneWidget);
        expect(find.text('Đăng xuất tài khoản'), findsOneWidget);

        // Tap back button
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();
        expect(find.byType(MainScaffold), findsOneWidget);
      },
    );
  });
}
