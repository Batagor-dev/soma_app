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

  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? username,
    String? email,
    String? gender,
    String? phone,
    String? address,
  }) async {
    try {
      final response = await _dio.put(
        "/auth/update-profile",
        data: {
          if (name != null) "name": name,
          if (username != null) "username": username,
          if (email != null) "email": email,
          if (gender != null) "gender": gender,
          if (phone != null) "phone": phone,
          if (address != null) "address": address,
        },
      );

      return {
        "success": true,
        "data": response.data["data"],
        "message": response.data["message"],
      };
    } on DioException catch (e) {
      final errors = e.response?.data["errors"];

      if (errors != null) {
        if (errors["email"] != null) {
          throw Exception(errors["email"][0]);
        }
        if (errors["username"] != null) {
          throw Exception(errors["username"][0]);
        }
      }

      throw Exception("Gagal update profil");
    }
  }

  Future<Map<String, dynamic>> getMe() async {
    try {
      final response = await _dio.get("/auth/me");

      return {
        "success": true,
        "data": response.data["data"],
      };
    } catch (e) {
      throw Exception("Gagal mengambil data me");
    }
  }
}
