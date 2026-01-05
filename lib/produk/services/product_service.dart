import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/api_config.dart';
import '../../auth/services/auth_service.dart';
import '../models/product.dart';
import '../models/product_brand.dart';
import '../../core/models/api_response.dart';

class ProductService {
  /// Get all products with optional filters
  static Future<ApiResponse<List<Product>>> getAllProducts({
    String? nama,
    int? merkId,
    String? warna,
    String? penyimpanan,
    String? sortBy,
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return ApiResponse<List<Product>>(
          success: false,
          message: 'Token tidak ditemukan. Silakan login kembali.',
        );
      }

      // Build query parameters
      Map<String, String> queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (nama != null && nama.isNotEmpty) {
        queryParams['nama'] = nama;
      }
      if (merkId != null) {
        queryParams['pos_produk_merk_id'] = merkId.toString();
      }
      if (warna != null && warna.isNotEmpty) {
        queryParams['warna'] = warna;
      }
      if (penyimpanan != null && penyimpanan.isNotEmpty) {
        queryParams['penyimpanan'] = penyimpanan;
      }
      if (sortBy != null && sortBy.isNotEmpty) {
        queryParams['sort_by'] = sortBy;
      }

      final uri = Uri.parse(
        ApiConfig.getUrl(ApiConfig.allProductsEndpoint),
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: ApiConfig.authHeaders(token),
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> productsJson = responseData['data'] ?? [];
        final products = <Product>[];

        // Safe parsing with error handling
        for (final json in productsJson) {
          try {
            products.add(Product.fromJson(json));
          } catch (e) {
            print('Error parsing product: $e');
            print('Product data: $json');
            // Skip this product and continue with others
            continue;
          }
        }

        return ApiResponse<List<Product>>(
          success: true,
          message: responseData['message'],
          data: products,
          pagination:
              responseData['pagination'] != null
                  ? PaginationInfo.fromJson(responseData['pagination'])
                  : null,
        );
      } else {
        return ApiResponse<List<Product>>(
          success: false,
          message: responseData['message'] ?? 'Gagal mengambil data produk',
        );
      }
    } catch (e) {
      return ApiResponse<List<Product>>(
        success: false,
        message: 'Error: ${e.toString()}',
      );
    }
  }

  /// Create a new product
  static Future<ApiResponse<Product>> createProduct({
    String? nama,
    required int merkId,
    required String productType,
    String? deskripsi,
    String? warna,
    String? penyimpanan,
    String? batteryHealth,
    required double hargaBeli,
    required double hargaJual,
    Map<String, double>? biayaTambahan,
    required String imei,
    String? aksesoris,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return ApiResponse<Product>(
          success: false,
          message: 'Token tidak ditemukan. Silakan login kembali.',
        );
      }

      // Prepare request body
      Map<String, dynamic> requestBody = {
        'pos_produk_merk_id': merkId,
        'product_type': productType,
        'harga_beli': hargaBeli,
        'harga_jual': hargaJual,
        'imei': imei,
      };

      // Add optional fields
      if (nama != null && nama.isNotEmpty) requestBody['nama'] = nama;
      if (deskripsi != null && deskripsi.isNotEmpty)
        requestBody['deskripsi'] = deskripsi;
      if (warna != null && warna.isNotEmpty) requestBody['warna'] = warna;
      if (penyimpanan != null && penyimpanan.isNotEmpty)
        requestBody['penyimpanan'] = penyimpanan;
      if (batteryHealth != null && batteryHealth.isNotEmpty)
        requestBody['battery_health'] = batteryHealth;
      if (aksesoris != null && aksesoris.isNotEmpty)
        requestBody['aksesoris'] = aksesoris;

      // Add additional costs
      if (biayaTambahan != null && biayaTambahan.isNotEmpty) {
        List<String> costNames = [];
        List<double> costAmounts = [];

        biayaTambahan.forEach((name, amount) {
          costNames.add(name);
          costAmounts.add(amount);
        });

        requestBody['cost_names'] = costNames;
        requestBody['cost_amounts'] = costAmounts;
      }

      // Debug logging
      print('Sending request body: ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.allProductsEndpoint)),
        headers: ApiConfig.authHeaders(token),
        body: json.encode(requestBody),
      );
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Product product = Product.fromJson(responseData['data']);

        return ApiResponse<Product>(
          success: true,
          message: responseData['message'] ?? 'Produk berhasil dibuat',
          data: product,
        );
      } else {
        return ApiResponse<Product>(
          success: false,
          message: responseData['message'] ?? 'Gagal membuat produk',
        );
      }
    } catch (e) {
      return ApiResponse<Product>(
        success: false,
        message: 'Error: ${e.toString()}',
      );
    }
  }

  /// Get product detail by ID
  static Future<Map<String, dynamic>> getProductDetail(int id) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan. Silakan login kembali.');
      }

      final response = await http.get(
        Uri.parse(ApiConfig.getUrl('${ApiConfig.allProductsEndpoint}/$id')),
        headers: ApiConfig.authHeaders(token),
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        throw Exception(
          responseData['message'] ?? 'Gagal mengambil detail produk',
        );
      }
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  /// Create new product
  static Future<Map<String, dynamic>> CreateProductScreen(
    Map<String, dynamic> productData,
  ) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan. Silakan login kembali.');
      }

      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.allProductsEndpoint)),
        headers: ApiConfig.authHeaders(token),
        body: json.encode(productData),
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 201) {
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Gagal membuat produk');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  /// Update product
  static Future<Map<String, dynamic>> updateProduct(
    int id,
    Map<String, dynamic> productData,
  ) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan. Silakan login kembali.');
      }

      final response = await http.put(
        Uri.parse(ApiConfig.getUrl('${ApiConfig.allProductsEndpoint}/$id')),
        headers: ApiConfig.authHeaders(token),
        body: json.encode(productData),
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Gagal mengupdate produk');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  /// Delete product
  static Future<ApiResponse<void>> deleteProduct(int id) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return ApiResponse<void>(
          success: false,
          message: 'Token tidak ditemukan. Silakan login kembali.',
        );
      }

      final response = await http.delete(
        Uri.parse(ApiConfig.getUrl('${ApiConfig.allProductsEndpoint}/$id')),
        headers: ApiConfig.authHeaders(token),
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<void>(
          success: true,
          message: responseData['message'] ?? 'Product deleted successfully',
        );
      } else {
        return ApiResponse<void>(
          success: false,
          message: responseData['message'] ?? 'Gagal menghapus produk',
        );
      }
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: 'Error: ${e.toString()}',
      );
    }
  }

  /// Get product brands for filter
  static Future<ApiResponse<List<ProductBrand>>> getProductBrands() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return ApiResponse<List<ProductBrand>>(
          success: false,
          message: 'Token tidak ditemukan. Silakan login kembali.',
        );
      }

      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.productBrandsEndpoint)),
        headers: ApiConfig.authHeaders(token),
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> brandsJson = responseData['data'] ?? [];
        final brands = <ProductBrand>[];

        // Safe parsing with error handling
        for (final json in brandsJson) {
          try {
            brands.add(ProductBrand.fromJson(json));
          } catch (e) {
            print('Error parsing brand: $e');
            print('Brand data: $json');
            // Skip this brand and continue with others
            continue;
          }
        }

        return ApiResponse<List<ProductBrand>>(
          success: true,
          message: responseData['message'],
          data: brands,
        );
      } else {
        return ApiResponse<List<ProductBrand>>(
          success: false,
          message: responseData['message'] ?? 'Gagal mengambil data brand',
        );
      }
    } catch (e) {
      return ApiResponse<List<ProductBrand>>(
        success: false,
        message: 'Error: ${e.toString()}',
      );
    }
  }

  /// Convert sort option from UI to API format
  static String? convertSortOption(String sortOption) {
    switch (sortOption) {
      case 'Harga Terendah':
        return 'harga_jual_asc';
      case 'Harga Tertinggi':
        return 'harga_jual_desc';
      case 'Nama A-Z':
        return 'nama_asc';
      case 'Nama Z-A':
        return 'nama_desc';
      case 'Stok Terbanyak':
        return 'stok_desc';
      default:
        return null; // Default sorting (latest)
    }
  }
}
