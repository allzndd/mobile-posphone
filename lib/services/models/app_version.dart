class AppVersion {
  final int? id;
  final String platform;
  final String latestVersion;
  final String minimumVersion;
  final bool maintenanceMode;
  final String? maintenanceMessage;
  final String? storeUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AppVersion({
    this.id,
    required this.platform,
    required this.latestVersion,
    required this.minimumVersion,
    required this.maintenanceMode,
    this.maintenanceMessage,
    this.storeUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory AppVersion.fromJson(Map<String, dynamic> json) {
    return AppVersion(
      id: json['id'],
      platform: json['platform'] ?? '',
      latestVersion: json['latest_version'] ?? '',
      minimumVersion: json['minimum_version'] ?? '',
      maintenanceMode:
          json['maintenance_mode'] == 1 || json['maintenance_mode'] == true,
      maintenanceMessage: json['maintenance_message'],
      storeUrl: json['store_url'],
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'platform': platform,
      'latest_version': latestVersion,
      'minimum_version': minimumVersion,
      'maintenance_mode': maintenanceMode ? 1 : 0,
      'maintenance_message': maintenanceMessage,
      'store_url': storeUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
