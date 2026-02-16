import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/version_check_provider.dart';
import '../../component/version_check_dialogs.dart';
import '../../services/models/app_version.dart';

/// Screen wrapper untuk handle version checking
class VersionCheckWrapper extends StatefulWidget {
  final Widget child;
  final String? title;

  const VersionCheckWrapper({
    Key? key,
    required this.child,
    this.title,
  }) : super(key: key);

  @override
  State<VersionCheckWrapper> createState() => _VersionCheckWrapperState();
}

class _VersionCheckWrapperState extends State<VersionCheckWrapper> {
  late VersionCheckProvider _versionCheckProvider;
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    _checkVersion();
  }

  void _checkVersion() async {
    // Tunggu sedikit agar context sudah siap
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      _versionCheckProvider = context.read<VersionCheckProvider>();
      await _versionCheckProvider.checkVersion();

      if (mounted && !_dialogShown) {
        _showVersionCheckDialog();
      }
    }
  }

  void _showVersionCheckDialog() {
    final action = _versionCheckProvider.getRequiredAction();

    // Jangan tampilkan dialog jika tidak ada action yang diperlukan
    if (action == VersionCheckAction.none) {
      return;
    }

    _dialogShown = true;

    if (action == VersionCheckAction.maintenance) {
      _showMaintenanceDialog();
    } else if (action == VersionCheckAction.forceUpdate) {
      _showForceUpdateDialog();
    } else if (action == VersionCheckAction.optionalUpdate) {
      _showOptionalUpdateDialog();
    }
  }

  void _showMaintenanceDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => MaintenanceDialog(
        message: _versionCheckProvider.appVersion?.maintenanceMessage,
      ),
    );
  }

  void _showForceUpdateDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => UpdateVersionDialog(
        appVersion: _versionCheckProvider.appVersion!,
        currentVersion: _versionCheckProvider.currentVersion,
        isForceUpdate: true,
      ),
    );
  }

  void _showOptionalUpdateDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => UpdateVersionDialog(
        appVersion: _versionCheckProvider.appVersion!,
        currentVersion: _versionCheckProvider.currentVersion,
        isForceUpdate: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
