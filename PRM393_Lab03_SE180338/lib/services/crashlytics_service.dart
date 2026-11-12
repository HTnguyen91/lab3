import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class CrashlyticsService {
  FirebaseCrashlytics? get _crashlytics =>
      kIsWeb ? null : FirebaseCrashlytics.instance;

  Future<void> initialize() async {
    if (kIsWeb) return;
    try {
      // In debug mode, Crashlytics can still collect or disable
      await _crashlytics?.setCrashlyticsCollectionEnabled(true);

      // Pass all uncaught errors from Flutter framework to Crashlytics
      FlutterError.onError = _crashlytics!.recordFlutterFatalError;

      // Pass all uncaught asynchronous errors that aren't handled by Flutter to Crashlytics
      PlatformDispatcher.instance.onError = (error, stack) {
        _crashlytics!.recordError(error, stack, fatal: true);
        return true;
      };
    } catch (e) {
      debugPrint('Crashlytics init error: $e');
    }
  }

  /// Sets user identifier for crash reports
  Future<void> setUserIdentifier(String uid) async {
    if (kIsWeb) return;
    try {
      await _crashlytics?.setUserIdentifier(uid);
    } catch (_) {}
  }

  /// Record a non-fatal handled exception (Demo button 1)
  Future<void> recordHandledException({
    required String message,
    StackTrace? stack,
  }) async {
    if (kIsWeb) {
      debugPrint('[Crashlytics Web] Handled exception: $message');
      return;
    }
    try {
      debugPrint(
        '[Crashlytics] Recording handled non-fatal exception: $message',
      );
      await _crashlytics?.recordError(
        Exception('Handled Exception: $message'),
        stack ?? StackTrace.current,
        reason: 'PRM393 Lab 3 Handled Exception Demo',
        fatal: false,
      );
    } catch (e) {
      debugPrint('Failed to report handled exception: $e');
    }
  }

  /// Cause a forced test crash (Demo button 2)
  void forceCrash() {
    debugPrint('[Crashlytics] Triggering test forced crash now...');
    if (kIsWeb) return;
    _crashlytics?.crash();
  }
}
