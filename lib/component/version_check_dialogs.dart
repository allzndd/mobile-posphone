import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/models/app_version.dart';
import '../../core/version_comparator.dart';

/// Widget untuk maintenance mode dialog
class MaintenanceDialog extends StatelessWidget {
  final String? message;

  const MaintenanceDialog({Key? key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Row(
        children: [
          const Icon(Icons.warning_rounded, color: Colors.amber, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Aplikasi Sedang Maintenance',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              message ??
                  'Aplikasi sedang dalam pemeliharaan. Silakan coba lagi nanti.',
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Exit app properly
            SystemNavigator.pop();
          },
          child: const Text('Tutup Aplikasi'),
        ),
      ],
    );
  }
}

/// Widget untuk update version dialog
class UpdateVersionDialog extends StatelessWidget {
  final AppVersion appVersion;
  final String currentVersion;
  final bool isForceUpdate;

  const UpdateVersionDialog({
    Key? key,
    required this.appVersion,
    required this.currentVersion,
    required this.isForceUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isBelowMinimum = VersionComparator.isVersionBelowMinimum(
      currentVersion,
      appVersion.minimumVersion,
    );

    return WillPopScope(
      onWillPop: () async => !isBelowMinimum, // Prevent back if forced update
      child: AlertDialog(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Icon(
              isBelowMinimum
                  ? Icons.error_rounded
                  : Icons.system_update_rounded,
              color: isBelowMinimum ? Colors.red : Colors.blue,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isBelowMinimum ? 'Update Wajib' : 'Update Tersedia',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                'Versi Aplikasi',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Versi Saat Ini:'),
                        Text(
                          currentVersion,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Versi Terbaru:'),
                        Text(
                          appVersion.latestVersion,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    if (isBelowMinimum) ...[
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Versi Minimum:'),
                          Text(
                            appVersion.minimumVersion,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (isBelowMinimum)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    border: Border.all(color: Colors.red[200]!, width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_rounded,
                        color: Colors.red[600],
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Versi aplikasi Anda sudah sangat lama. Update wajib dilakukan untuk melanjutkan penggunaan.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        actions: [
          if (!isBelowMinimum)
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Nanti Saja'),
            ),
          ElevatedButton.icon(
            onPressed: () => _openStore(context),
            icon: const Icon(Icons.open_in_new),
            label: const Text('Update Sekarang'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _openStore(BuildContext context) async {
    if (appVersion.storeUrl != null && appVersion.storeUrl!.isNotEmpty) {
      try {
        final Uri url = Uri.parse(appVersion.storeUrl!);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      } catch (e) {
        print('Error launching store URL: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Tidak dapat membuka Play Store'),
              backgroundColor: Colors.red[600],
            ),
          );
        }
      }
    }
  }
}

/// Widget untuk version check status (minimal)
class VersionStatusBar extends StatelessWidget {
  final String statusText;
  final Color statusColor;
  final VoidCallback? onUpdate;

  const VersionStatusBar({
    Key? key,
    required this.statusText,
    required this.statusColor,
    this.onUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        border: Border(top: BorderSide(color: statusColor, width: 2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
          if (onUpdate != null)
            SizedBox(
              height: 28,
              child: TextButton(
                onPressed: onUpdate,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text('Update', style: TextStyle(fontSize: 12)),
              ),
            ),
        ],
      ),
    );
  }
}
