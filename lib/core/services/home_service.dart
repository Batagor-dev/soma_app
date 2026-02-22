// home_service.dart
import 'package:dio/dio.dart';
import '../network/dio_client.dart';

class HomeService {
  final Dio _dio = DioClient().dio;

  Future<Map<String, dynamic>?> getHome() async {
    try {
      final response = await _dio.get("/home");
      return response.data;
    } on DioException catch (e) {
      print(e.response?.data);
      return null;
    }
  }
  
}
