// auth_service.dart
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/dio_client.dart';

class AuthService {
  final Dio _dio = DioClient().dio;

  Future<bool> login(String email, String password) async {
    try {
      final response = await _dio.post("/auth/login", data: {
        "email": email,
        "password": password,
      });

      final token = response.data["access_token"] as String?;
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", token);
      }

      return true;
    } on DioException catch (e) {
      print(e.response?.data);
      return false;
    }
  }

  Future<bool> register(
      String name, String username, String email, String password) async {
    try {
      final response = await _dio.post("/auth/register", data: {
        "name": name,
        "username": username,
        "email": email,
        "password": password,
        "password_confirmation": password,
      });

      final token = response.data["access_token"] as String?;
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", token);
      }

      return true;
    } on DioException catch (e) {
      final errors = e.response?.data["errors"];
      if (errors != null) {
        if (errors["email"] != null) {
          throw Exception(errors["email"][0]);
        }
        if (errors["username"] != null) {
          throw Exception(errors["username"][0]);
        }
        if (errors["password"] != null) {
          throw Exception(errors["password"][0]);
        }
      }
      print(e.response?.data);
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post("/auth/logout"); // kalau backend ada endpoint logout
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");

    _dio.options.headers.remove("Authorization");
  }
}
