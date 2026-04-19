import 'package:dio/dio.dart';

class ApiService {
  final Dio dio = Dio();

  final String baseUrl = "https://69dde147410caa3d47ba1d8d.mockapi.io";

  Future<bool> send(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await dio.post("$baseUrl/$endpoint", data: data);

      print("Ma trang thai tra ve: ${response.statusCode}");
      print("Du lieu tra ve: ${response.data}");

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Loi goi API: $e");
      return false;
    }
  }

  Future<bool> checkLogin(
    String endpoint,
    String email,
    String password,
  ) async {
    try {
      final response = await dio.get(
        "$baseUrl/$endpoint",
        queryParameters: {"email": email, "password": password},
      );

      print("Ma trang thai tra ve: ${response.statusCode}");
      print("Du lieu tra ve: ${response.data}");

      if (response.statusCode == 200) {
        final List users = response.data;
        if (users.isNotEmpty) {
          return true;
        }
      }
      return false;
    } catch (e) {
      print("Loi goi API: $e");
      return false;
    }
  }
}
