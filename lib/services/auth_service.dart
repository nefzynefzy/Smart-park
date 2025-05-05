import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = "http://10.0.2.2:8082/parking";

  // Login method
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/api/auth/login');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token']; // Assuming the backend returns a token
        return {
          'success': true,
          'token': token,
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error connecting to server: $e',
      };
    }
  }

  // Signup method
  static Future<Map<String, dynamic>> signup(
      String firstName,
      String lastName,
      String email,
      String phone,
      String password,
      ) async {
    final url = Uri.parse('$baseUrl/api/auth/signup'); // Adjust your signup endpoint here

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "firstName": firstName,
          "lastName": lastName,
          "email": email,
          "phone": phone,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token']; // Assuming backend sends a token after signup
        return {
          'success': true,
          'token': token,
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Signup failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error connecting to server: $e',
      };
    }
  }
}
