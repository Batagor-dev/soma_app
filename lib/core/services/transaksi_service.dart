import 'package:dio/dio.dart';
import '../network/dio_client.dart';

class TransaksiService {
  final Dio _dio = DioClient().dio;

  /// GET ALL TRANSAKSI
  Future<Map<String, dynamic>?> getAll() async {
    try {
      final response = await _dio.get("/transaksi");
      return response.data;
    } on DioException catch (e) {
      print("GET ALL ERROR: ${e.response?.data}");
      return null;
    }
  }

  /// GET DETAIL TRANSAKSI
  Future<Map<String, dynamic>?> getDetail(int id) async {
    try {
      final response = await _dio.get("/transaksi/$id");
      return response.data;
    } on DioException catch (e) {
      print("GET DETAIL ERROR: ${e.response?.data}");
      return null;
    }
  }

  /// CREATE TRANSAKSI (Pengeluaran)
  Future<Map<String, dynamic>?> createTransaksi({
    required String deskripsi,
    required double total,
    required String sumber,
  }) async {
    try {
      final response = await _dio.post(
        "/transaksi",
        data: {
          "deskripsi": deskripsi,
          "total": total,
          "sumber": sumber,
        },
      );

      return response.data;
    } on DioException catch (e) {
      print("CREATE ERROR: ${e.response?.data}");
      return e.response?.data;
    }
  }
}
