import 'package:flutter/material.dart';
import '../services/models/app_version.dart';
import '../services/services/app_version_service.dart';
import '../core/version_comparator.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersionCheckProvider extends ChangeNotifier {
  AppVersion? _appVersion;
  String _currentVersion = '';
  bool _isLoading = false;
  String? _error;
  bool _isBelowMinimum = false;
  bool _hasNewVersion = false;
  bool _isMaintenanceMode = false;

  // Getters
  AppVersion? get appVersion => _appVersion;
  String get currentVersion => _currentVersion;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isBelowMinimum => _isBelowMinimum;
  bool get hasNewVersion => _hasNewVersion;
  bool get isMaintenanceMode => _isMaintenanceMode;

  /// Initialize dan check version
  Future<void> checkVersion() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🔍 VERSION CHECK: Starting version check...');
      
      // Get current app version
      final packageInfo = await PackageInfo.fromPlatform();
      _currentVersion = packageInfo.version;
      print('🔍 VERSION CHECK: Current app version: $_currentVersion');

      // Determine platform
      final platform = 'Android';
      print('🔍 VERSION CHECK: Platform: $platform');

      // Fetch app version dari API
      print('🔍 VERSION CHECK: Fetching from API...');
      final appVersion = await AppVersionService.getAppVersion(platform);

      if (appVersion != null) {
        print('🔍 VERSION CHECK: API Response received');
        print('🔍 VERSION CHECK: Latest: ${appVersion.latestVersion}');
        print('🔍 VERSION CHECK: Minimum: ${appVersion.minimumVersion}');
        print('🔍 VERSION CHECK: Maintenance Mode: ${appVersion.maintenanceMode}');
        
        _appVersion = appVersion;

        // Check status
        _isBelowMinimum = VersionComparator.isVersionBelowMinimum(
          _currentVersion,
          appVersion.minimumVersion,
        );
        print('🔍 VERSION CHECK: Is Below Minimum: $_isBelowMinimum');

        _hasNewVersion = VersionComparator.hasNewVersion(
          _currentVersion,
          appVersion.latestVersion,
        );
        print('🔍 VERSION CHECK: Has New Version: $_hasNewVersion');

        _isMaintenanceMode = appVersion.maintenanceMode;
        print('🔍 VERSION CHECK: Is Maintenance Mode: $_isMaintenanceMode');
        
        final action = getRequiredAction();
        print('🔍 VERSION CHECK: Required Action: $action');
      } else {
        _error = 'Gagal mengambil data versi aplikasi';
        print('🔍 VERSION CHECK: ERROR - API returned null');
      }
    } catch (e) {
      _error = 'Error checking version: $e';
      print('🔍 VERSION CHECK: EXCEPTION - $e');
    }

    _isLoading = false;
    notifyListeners();
    print('🔍 VERSION CHECK: Check completed');
  }

  /// Get action yang diperlukan
  VersionCheckAction getRequiredAction() {
    if (_isMaintenanceMode) {
      return VersionCheckAction.maintenance;
    }
    if (_isBelowMinimum) {
      return VersionCheckAction.forceUpdate;
    }
    if (_hasNewVersion) {
      return VersionCheckAction.optionalUpdate;
    }
    return VersionCheckAction.none;
  }

  /// Check apakah perlu force exit (maintenance atau force update)
  bool shouldShowBlockingDialog() {
    return _isMaintenanceMode || _isBelowMinimum;
  }

  String getVersionDescription() {
    return VersionComparator.getVersionDescription(
      _currentVersion,
      _appVersion?.latestVersion ?? '',
      _appVersion?.minimumVersion ?? '',
    );
  }

  /// Reset state
  void reset() {
    _appVersion = null;
    _currentVersion = '';
    _isLoading = false;
    _error = null;
    _isBelowMinimum = false;
    _hasNewVersion = false;
    _isMaintenanceMode = false;
    notifyListeners();
  }
}

enum VersionCheckAction {
  none,
  optionalUpdate,
  forceUpdate,
  maintenance,
}
