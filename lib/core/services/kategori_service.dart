import 'package:dio/dio.dart';
import '../network/dio_client.dart';

class KategoriService {
  final Dio _dio = DioClient().dio;

  Future<Map<String, dynamic>?> getKategori() async {
    try {
      final response = await _dio.get("/kategori");
      return response.data;
    } on DioException catch (e) {
      print(e.response?.data);
      return null;
    }
  }

  Future<Map<String, dynamic>?> createKategori({
    required String nama,
    String? deskripsi,
  }) async {
    try {
      final response = await _dio.post(
        "/kategori",
        data: {
          "nama": nama,
          "deskripsi": deskripsi,
        },
      );
      return response.data;
    } on DioException catch (e) {
      print(e.response?.data);
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateKategori({
    required int id,
    required String nama,
    String? deskripsi,
  }) async {
    try {
      final response = await _dio.put(
        "/kategori/$id",
        data: {
          "nama": nama,
          "deskripsi": deskripsi,
        },
      );
      return response.data;
    } on DioException catch (e) {
      print(e.response?.data);
      return null;
    }
  }

  Future<bool> deleteKategori(int id) async {
    try {
      await _dio.delete("/kategori/$id");
      return true;
    } on DioException catch (e) {
      print(e.response?.data);
      return false;
    }
  }
}
