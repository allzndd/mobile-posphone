/// Utility untuk membandingkan versi aplikasi
class VersionComparator {
  /// Parse versi dari format "1.0.0+1" menjadi [major, minor, patch, build]
  /// Returns list dengan minimal 3 elemen (major.minor.patch)
  static List<int> parseVersion(String version) {
    try {
      // Pisahkan versi dan build number (format: 1.0.0+1)
      final parts = version.split('+');
      final versionPart = parts[0];
      
      // Split major.minor.patch
      final versionNumbers = versionPart.split('.').map((e) {
        return int.tryParse(e) ?? 0;
      }).toList();
      
      // Pastikan minimal 3 elemen
      while (versionNumbers.length < 3) {
        versionNumbers.add(0);
      }
      
      return versionNumbers;
    } catch (e) {
      print('Error parsing version $version: $e');
      return [0, 0, 0];
    }
  }

  /// Bandingkan dua versi
  /// Return: 
  ///   1 jika version1 > version2
  ///   -1 jika version1 < version2
  ///   0 jika version1 == version2
  static int compareVersions(String version1, String version2) {
    final v1 = parseVersion(version1);
    final v2 = parseVersion(version2);
    
    for (int i = 0; i < 3; i++) {
      if (v1[i] > v2[i]) return 1;
      if (v1[i] < v2[i]) return -1;
    }
    
    return 0;
  }

  /// Check apakah currentVersion lebih kecil dari minimumVersion
  static bool isVersionBelowMinimum(String currentVersion, String minimumVersion) {
    return compareVersions(currentVersion, minimumVersion) < 0;
  }

  /// Check apakah ada versi baru (currentVersion < latestVersion)
  static bool hasNewVersion(String currentVersion, String latestVersion) {
    return compareVersions(currentVersion, latestVersion) < 0;
  }

  /// Dapatkan deskripsi perbandingan versi
  static String getVersionDescription(
    String currentVersion,
    String latestVersion,
    String minimumVersion,
  ) {
    if (isVersionBelowMinimum(currentVersion, minimumVersion)) {
      return 'Versi terlalu lama, update wajib dilakukan';
    } else if (hasNewVersion(currentVersion, latestVersion)) {
      return 'Versi baru tersedia';
    }
    return 'Aplikasi sudah versi terbaru';
  }
}
