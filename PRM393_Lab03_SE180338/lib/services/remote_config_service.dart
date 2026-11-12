import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

import '../utils/constants.dart';

class RemoteConfigService {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  // Defaults
  final Map<String, dynamic> _defaults = {
    AppConstants.rcKeySpendingThreshold:
        200000.0, // Alert if single expense exceeds 200.000 VNĐ
    AppConstants.rcKeyPromoBanner:
        'Mẹo tài chính: Hãy ghi chép ngay sau khi chi tiêu!',
    AppConstants.rcKeyEnableTips: true,
  };

  Future<void> initialize() async {
    try {
      await _remoteConfig.setDefaults(_defaults);
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(
            seconds: 0,
          ), // 0 for instant testing
        ),
      );
      await fetchAndActivate();
    } catch (e) {
      debugPrint('RemoteConfig init error (fallback to in-app defaults): $e');
    }
  }

  Future<bool> fetchAndActivate() async {
    try {
      return await _remoteConfig.fetchAndActivate();
    } catch (e) {
      debugPrint('RemoteConfig fetch error: $e');
      return false;
    }
  }

  // Getters
  double get spendingWarningThreshold {
    try {
      final val = _remoteConfig.getDouble(AppConstants.rcKeySpendingThreshold);
      return val > 0 ? val : 200000.0;
    } catch (_) {
      return 200000.0;
    }
  }

  String get promoBannerText {
    try {
      final text = _remoteConfig.getString(AppConstants.rcKeyPromoBanner);
      return text.isNotEmpty
          ? text
          : _defaults[AppConstants.rcKeyPromoBanner] as String;
    } catch (_) {
      return _defaults[AppConstants.rcKeyPromoBanner] as String;
    }
  }

  bool get enableBudgetTips {
    try {
      return _remoteConfig.getBool(AppConstants.rcKeyEnableTips);
    } catch (_) {
      return true;
    }
  }
}
