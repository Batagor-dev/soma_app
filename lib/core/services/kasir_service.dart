import 'package:dio/dio.dart';
import '../network/dio_client.dart';

class KasirService {
  final Dio _dio = DioClient().dio;

  /// ===============================
  /// GET PRODUK (Search + Filter)
  /// ===============================
  Future<Map<String, dynamic>?> getProduk({
    String? search,
    int? kategoriId,
  }) async {
    try {
      Map<String, dynamic> query = {};

      if (search != null && search.isNotEmpty) {
        query['search'] = search;
      }

      if (kategoriId != null) {
        query['kategori_id'] = kategoriId;
      }

      final response = await _dio.get(
        "/kasir",
        queryParameters: query,
      );

      return response.data;
    } on DioException catch (e) {
      print(e.response?.data);
      return null;
    }
  }

  /// ===============================
  /// CREATE TRANSAKSI
  /// ===============================
  Future<Map<String, dynamic>?> createTransaksi({
    required List<Map<String, dynamic>> items,
    String? tanggal,
  }) async {
    try {
      final response = await _dio.post(
        "/kasir",
        data: {
          "items": items,
          if (tanggal != null) "tanggal": tanggal,
        },
      );

      return response.data;
    } on DioException catch (e) {
      print(e.response?.data);
      return e.response?.data;
    }
  }
}
