/// Konfigurasi API untuk aplikasi
class ApiConfig {
  /// Base URL untuk Laravel API
  /// Sesuaikan dengan server Laravel yang berjalan
  static const String baseUrl = 'http://192.168.0.107:8000';

  /// API endpoints
  static const String registerEndpoint = '/api/register';
  static const String loginEndpoint = '/api/login';
  static const String logoutEndpoint = '/api/logout';
  static const String userEndpoint = '/api/user';
  static const String brandingConfigEndpoint = '/api/branding-config/public';
  
  // Product endpoints
  static const String allProductsEndpoint = '/api/products';
  static const String productBrandsEndpoint = '/api/product-brands';
  static const String stockManagementEndpoint = '/api/stock-management';
  static const String stockHistoryEndpoint = '/api/stock-history';

  /// Get full URL untuk endpoint
  static String getUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }

  /// Common headers untuk API request
  static Map<String, String> get defaultHeaders => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

  /// Headers dengan authorization token
  static Map<String, String> authHeaders(String token) => {
        ...defaultHeaders,
        'Authorization': 'Bearer $token',
      };
}
