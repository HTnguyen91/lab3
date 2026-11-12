import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/models/budget_model.dart';
import 'package:expense_tracker/models/transaction_model.dart';
import 'package:expense_tracker/services/firestore_service.dart';
import 'package:expense_tracker/services/analytics_service.dart';
import 'package:expense_tracker/viewmodels/auth_viewmodel.dart';
import 'package:expense_tracker/viewmodels/settings_viewmodel.dart';
import 'package:expense_tracker/viewmodels/transaction_viewmodel.dart';
import 'package:expense_tracker/viewmodels/budget_viewmodel.dart';
import 'package:expense_tracker/viewmodels/statistics_viewmodel.dart';
import 'package:expense_tracker/screens/main_scaffold.dart';
import 'package:expense_tracker/screens/s09_login_screen.dart';
import 'package:expense_tracker/screens/s02_add_transaction_screen.dart';
import 'package:expense_tracker/screens/s03_history_screen.dart';
import 'package:expense_tracker/screens/s08_create_budget_screen.dart';
import 'package:expense_tracker/theme/app_theme.dart';
import 'package:expense_tracker/utils/formatters.dart';

class _Store implements FirestoreService {
  final now = DateTime.now();
  @override
  Stream<List<TransactionModel>> streamTransactions(String uid) =>
      Stream.value([
        TransactionModel(
          id: 'tx1',
          userId: uid,
          amount: 450000,
          type: 'expense',
          categoryId: 'cat_food',
          categoryName: 'Ăn uống',
          date: now,
          note: 'Cơm trưa sinh viên',
          paymentMethod: 'Tiền mặt',
          createdAt: now,
        ),
      ]);
  @override
  Stream<List<BudgetModel>> streamBudgets(String uid) => Stream.value([
    BudgetModel(
      id: 'b1',
      userId: uid,
      month: Formatters.formatMonth(now),
      categoryId: 'cat_food',
      categoryName: 'Ăn uống',
      limitAmount: 300000,
      createdAt: now,
    ),
  ]);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Analytics implements AnalyticsService {
  @override
  Future<void> logViewTransaction({
    required String id,
    required String name,
  }) async {}
  @override
  Future<void> logViewCategoryStats({
    required String category,
    required String month,
  }) async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Auth extends ChangeNotifier implements AuthViewModel {
  @override
  String get displayName => 'Minh Anh';
  @override
  String? get photoUrl => null;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _LoginAuth extends _Auth {
  bool loading = false;
  String? error;
  int calls = 0;
  @override
  bool get isLoading => loading;
  @override
  String? get errorMessage => error;
  @override
  Future<bool> signInWithGoogle() async {
    calls++;
    loading = true;
    notifyListeners();
    return false;
  }

  void fail() {
    loading = false;
    error = 'Không thể đăng nhập. Vui lòng thử lại.';
    notifyListeners();
  }
}

class _Settings extends ChangeNotifier implements SettingsViewModel {
  @override
  bool get enableBudgetTips => false;
  @override
  String get promoBannerText => '';
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final previewFont = Platform.environment['PREVIEW_FONT'];
  setUpAll(() async {
    if (previewFont != null) {
      final loader = FontLoader('Roboto');
      loader.addFont(
        Future.value(
          ByteData.sublistView(await File(previewFont).readAsBytes()),
        ),
      );
      await loader.load();
      final iconsPath = Platform.environment['PREVIEW_ICONS'];
      if (iconsPath != null) {
        final icons = FontLoader('MaterialIcons');
        icons.addFont(
          Future.value(
            ByteData.sublistView(await File(iconsPath).readAsBytes()),
          ),
        );
        await icons.load();
      }
    }
  });
  final boundaryKey = GlobalKey();
  Widget host(Widget screen, {AuthViewModel? auth}) {
    final store = _Store(), analytics = _Analytics();
    return MultiProvider(
      providers: [
        Provider<AnalyticsService>.value(value: analytics),
        ChangeNotifierProvider<AuthViewModel>(create: (_) => auth ?? _Auth()),
        ChangeNotifierProvider<SettingsViewModel>(create: (_) => _Settings()),
        ChangeNotifierProvider<TransactionViewModel>(
          create: (_) => TransactionViewModel(
            firestoreService: store,
            analyticsService: analytics,
            userId: 'test',
          ),
        ),
        ChangeNotifierProvider<BudgetViewModel>(
          create: (_) => BudgetViewModel(
            firestoreService: store,
            analyticsService: analytics,
            userId: 'test',
          ),
        ),
        ChangeNotifierProvider<StatisticsViewModel>(
          create: (_) => StatisticsViewModel(analyticsService: analytics),
        ),
      ],
      child: RepaintBoundary(
        key: boundaryKey,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: previewFont == null
              ? AppTheme.lightTheme
              : AppTheme.lightTheme.copyWith(
                  textTheme: AppTheme.lightTheme.textTheme.apply(
                    fontFamily: 'Roboto',
                  ),
                ),
          home: screen,
        ),
      ),
    );
  }

  Future<void> capture(WidgetTester tester, String name) async {
    if (Platform.environment['SAVE_UI_PREVIEWS'] != '1') return;
    final boundary =
        boundaryKey.currentContext!.findRenderObject()!
            as RenderRepaintBoundary;
    await tester.runAsync(() async {
      final picture = await boundary.toImage(pixelRatio: 2);
      final bytes = await picture.toByteData(format: ui.ImageByteFormat.png);
      final dir = Directory('build/ui-previews');
      await dir.create(recursive: true);
      await File('${dir.path}/$name.png')
          .writeAsBytes(bytes!.buffer.asUint8List());
      picture.dispose();
    });
  }

  testWidgets(
    'Login adapts to phone and desktop and keeps Google sign-in states usable',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final size in [
        const Size(320, 640),
        const Size(360, 800),
        const Size(1000, 760),
      ]) {
        tester.view.physicalSize = size;
        await tester.pumpWidget(host(const LoginScreen(), auth: _LoginAuth()));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Tiếp tục với Google'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '$size');
        await capture(
          tester,
          size.width == 1000
              ? 'login-desktop'
              : size.width == 360
              ? 'login'
              : 'login-small',
        );
        await tester.pumpWidget(const SizedBox.shrink());
      }
      tester.view.physicalSize = const Size(360, 800);
      final auth = _LoginAuth();
      await tester.pumpWidget(host(const LoginScreen(), auth: auth));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Tiếp tục với Google'));
      await tester.tap(find.text('Tiếp tục với Google'));
      await tester.pump();
      expect(auth.calls, 1);
      expect(find.text('Đang đăng nhập…'), findsOneWidget);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      auth.fail();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Tiếp tục với Google'));
      expect(
        find.text('Không thể đăng nhập. Vui lòng thử lại.'),
        findsOneWidget,
      );
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNotNull,
      );
      await capture(tester, 'login-error');
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('Main tabs fit a 360px phone and preserve tab navigation', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(host(const MainScaffold()));
    await tester.pumpAndSettle();
    expect(find.text(Formatters.formatCurrency(-150000)), findsWidgets);
    await capture(tester, 'home');
    for (final tab in ['Lịch sử', 'Thống kê', 'Ngân sách']) {
      await tester.tap(find.text(tab).last);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: tab);
      await capture(
        tester,
        tab == 'Lịch sử'
            ? 'history'
            : tab == 'Thống kê'
            ? 'statistics'
            : 'budgets',
      );
    }
    await tester.tap(find.text('Chỉnh sửa').first);
    await tester.pumpAndSettle();
    expect(find.text('Tạo Ngân Sách'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await capture(tester, 'create-budget');
  });
  testWidgets(
    'History category/search filters open detail and return without losing the filter',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(host(const Scaffold(body: HistoryScreen())));
      await tester.pumpAndSettle();
      expect(find.text('Tổng quan tháng'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsNothing);
      await tester.tap(find.text('Ăn uống').first);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Tìm giao dịch'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'không tồn tại');
      await tester.pumpAndSettle();
      expect(find.text('Không tìm thấy giao dịch'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'cơm');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cơm trưa sinh viên'));
      await tester.pumpAndSettle();
      expect(find.text('Thông tin chi tiết'), findsOneWidget);
      expect(find.text('Khoản chi tiêu'), findsOneWidget);
      expect(find.text('Tiền mặt'), findsOneWidget);
      expect(find.text('Ghi chú'), findsOneWidget);
      expect(find.text('Thuộc ngân sách'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await capture(tester, 'transaction-detail');
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.text('cơm'), findsOneWidget);
      expect(find.text('Cơm trưa sinh viên'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'Income starts on a valid category and unfinished form asks before leaving',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        host(const AddTransactionScreen(initialType: 'income')),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.enterText(find.byType(TextField).first, '45000');
      await tester.pumpAndSettle();
      await capture(tester, 'add-transaction');
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.text('Bỏ thay đổi?'), findsOneWidget);
      await tester.tap(find.text('Tiếp tục nhập'));
      await tester.pumpAndSettle();
      expect(find.text('45000'), findsOneWidget);
    },
  );
  testWidgets('Duplicate budget remains on form with an actionable error', (
    tester,
  ) async {
    await tester.pumpWidget(host(const CreateBudgetScreen()));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '3000000');
    await tester.ensureVisible(find.text('Lưu ngân sách'));
    await tester.tap(find.text('Lưu ngân sách'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Danh mục này đã có ngân sách'), findsOneWidget);
  });
}
