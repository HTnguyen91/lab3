import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

// Themes & Utils
import 'theme/app_theme.dart';
import 'utils/constants.dart';

// Services
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/analytics_service.dart';
import 'services/crashlytics_service.dart';
import 'services/remote_config_service.dart';
import 'services/fcm_service.dart';
import 'services/pdf_export_service.dart';

// ViewModels
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/transaction_viewmodel.dart';
import 'viewmodels/budget_viewmodel.dart';
import 'viewmodels/statistics_viewmodel.dart';
import 'viewmodels/settings_viewmodel.dart';

// Screens
import 'screens/s09_login_screen.dart';
import 'screens/main_scaffold.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init notice: $e');
  }

  // Initialize Firebase services
  final crashlyticsService = CrashlyticsService();
  await crashlyticsService.initialize();

  final remoteConfigService = RemoteConfigService();
  await remoteConfigService.initialize();

  final fcmService = FCMService();

  runApp(
    ExpenseTrackerApp(
      crashlyticsService: crashlyticsService,
      remoteConfigService: remoteConfigService,
      fcmService: fcmService,
    ),
  );
}

class ExpenseTrackerApp extends StatelessWidget {
  final CrashlyticsService crashlyticsService;
  final RemoteConfigService remoteConfigService;
  final FCMService fcmService;

  const ExpenseTrackerApp({
    super.key,
    required this.crashlyticsService,
    required this.remoteConfigService,
    required this.fcmService,
  });

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final firestoreService = FirestoreService();
    final analyticsService = AnalyticsService();
    final pdfExportService = PdfExportService();

    return MultiProvider(
      providers: [
        // Services
        Provider<AuthService>.value(value: authService),
        Provider<FirestoreService>.value(value: firestoreService),
        Provider<AnalyticsService>.value(value: analyticsService),
        Provider<CrashlyticsService>.value(value: crashlyticsService),
        Provider<RemoteConfigService>.value(value: remoteConfigService),
        Provider<FCMService>.value(value: fcmService),
        Provider<PdfExportService>.value(value: pdfExportService),

        // Auth ViewModel
        ChangeNotifierProvider<AuthViewModel>(
          create: (_) => AuthViewModel(
            authService: authService,
            analyticsService: analyticsService,
            crashlyticsService: crashlyticsService,
          ),
        ),

        // Statistics ViewModel
        ChangeNotifierProvider<StatisticsViewModel>(
          create: (_) =>
              StatisticsViewModel(analyticsService: analyticsService),
        ),

        // User-dependent ViewModels using ProxyProvider
        ChangeNotifierProxyProvider<AuthViewModel, TransactionViewModel>(
          create: (ctx) => TransactionViewModel(
            firestoreService: firestoreService,
            analyticsService: analyticsService,
            userId: ctx.read<AuthViewModel>().uid,
          ),
          update: (_, authVm, previous) => TransactionViewModel(
            firestoreService: firestoreService,
            analyticsService: analyticsService,
            userId: authVm.uid,
          ),
        ),

        ChangeNotifierProxyProvider<AuthViewModel, BudgetViewModel>(
          create: (ctx) => BudgetViewModel(
            firestoreService: firestoreService,
            analyticsService: analyticsService,
            userId: ctx.read<AuthViewModel>().uid,
          ),
          update: (_, authVm, previous) => BudgetViewModel(
            firestoreService: firestoreService,
            analyticsService: analyticsService,
            userId: authVm.uid,
          ),
        ),

        ChangeNotifierProxyProvider<AuthViewModel, SettingsViewModel>(
          create: (ctx) => SettingsViewModel(
            remoteConfigService: remoteConfigService,
            crashlyticsService: crashlyticsService,
            pdfExportService: pdfExportService,
            firestoreService: firestoreService,
            analyticsService: analyticsService,
            userId: ctx.read<AuthViewModel>().uid,
          ),
          update: (_, authVm, previous) => SettingsViewModel(
            remoteConfigService: remoteConfigService,
            crashlyticsService: crashlyticsService,
            pdfExportService: pdfExportService,
            firestoreService: firestoreService,
            analyticsService: analyticsService,
            userId: authVm.uid,
          ),
        ),
      ],
      child: Consumer<AuthViewModel>(
        builder: (context, authVm, _) {
          // Initialize FCM for user once authenticated
          if (authVm.isAuthenticated) {
            fcmService.initialize(authVm.uid);
          }

          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            navigatorObservers: [analyticsService.analyticsObserver],
            home: authVm.isAuthenticated
                ? const MainScaffold()
                : const LoginScreen(),
          );
        },
      ),
    );
  }
}
