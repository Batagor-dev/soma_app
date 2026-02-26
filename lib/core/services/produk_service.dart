import 'package:dio/dio.dart';
import '../network/dio_client.dart';

class ProdukService {
  final Dio _dio = DioClient().dio;

  // GET ALL
Future<Map<String, dynamic>?> getProduk({int? kategoriId}) async {
    try {
      final query = kategoriId != null ? "?kategori_id=$kategoriId" : "";
      final response = await _dio.get("/produk$query");
      return response.data;
    } on DioException catch (e) {
      print(e.response?.data);
      return null;
    }
  }

  // GET DETAIL
  Future<Map<String, dynamic>?> getDetail(int id) async {
    try {
      final response = await _dio.get("/produk/$id");
      return response.data;
    } on DioException catch (e) {
      print(e.response?.data);
      return null;
    }
  }

  // CREATE (pakai FormData karena ada foto)
  Future<Map<String, dynamic>?> createProduk({
    required int kategoriId,
    required String nama,
    String? deskripsi,
    required int harga,
    required int stok,
    String? fotoPath,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        "kategori_produk_id": kategoriId,
        "nama": nama,
        "deskripsi": deskripsi,
        "harga": harga,
        "stok": stok,
        if (fotoPath != null) "foto": await MultipartFile.fromFile(fotoPath),
      });

      final response = await _dio.post("/produk", data: formData);
      return response.data;
    } on DioException catch (e) {
      return e.response?.data;
    }
  }

  // UPDATE
  Future<Map<String, dynamic>?> updateProduk({
    required int id,
    int? kategoriId,
    String? nama,
    String? deskripsi,
    int? harga,
    int? stok,
    String? fotoPath,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        if (kategoriId != null) "kategori_produk_id": kategoriId,
        if (nama != null) "nama": nama,
        if (deskripsi != null) "deskripsi": deskripsi,
        if (harga != null) "harga": harga,
        if (stok != null) "stok": stok,
        if (fotoPath != null)
          "foto": await MultipartFile.fromFile(fotoPath),
      });

      final response =
          await _dio.post("/produk/$id?_method=PUT", data: formData);

      return response.data;
    } on DioException catch (e) {
      print(e.response?.data);
      return null;
    }
  }

  // DELETE
  Future<bool> deleteProduk(int id) async {
    try {
      await _dio.delete("/produk/$id");
      return true;
    } on DioException catch (e) {
      print(e.response?.data);
      return false;
    }
  }

  // RESTOK
  Future<Map<String, dynamic>?> restokProduk({
    required int id,
    required int jumlah,
    String? keterangan,
    String? tanggal,
  }) async {
    try {
      final response = await _dio.post(
        "/produk/$id/restok",
        data: {
          "jumlah": jumlah,
          "keterangan": keterangan,
          "tanggal": tanggal,
        },
      );
      return response.data;
    } on DioException catch (e) {
      print(e.response?.data);
      return null;
    }
  }

  
}


