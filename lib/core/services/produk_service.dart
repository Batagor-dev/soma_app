import 'package:dio/dio.dart';
import '../network/dio_client.dart';

class ProdukService {
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

  Future<Map<String, dynamic>?> getProduk() async {
    try {
      final response = await _dio.get("/produk");
      return response.data;
    } on DioException catch (e) {
      print(e.response?.data);
      return null;
    }
  }

}
