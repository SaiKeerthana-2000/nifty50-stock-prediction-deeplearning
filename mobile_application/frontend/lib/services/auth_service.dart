import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  // ✅ Register User
  Future<bool> signUp(
    String name,
    String email,
    String username,
    String phone,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'email': email,
        'username': username,
        'phone': phone,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }

  // ✅ Login User
  Future<Map<String, dynamic>?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return json.decode(
        response.body,
      )['user']; // Return user data on successful login
    } else {
      return null; // Return null if login fails
    }
  }

  // ✅ Check if user is logged in (using a token or session in your Flask API)
  Future<bool> isUserLoggedIn() async {
    // You can add a check here to validate if the user is logged in
    // Example: check if a token exists in shared preferences or local storage
    // In this case, we can just check if the user is authenticated on the server-side.
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/check-login',
        ), // A route in Flask to verify login status
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // ✅ Logout User
  Future<void> logout() async {
    // Add a route to Flask to handle user logout (e.g., remove session, token, etc.)
    final response = await http.post(Uri.parse('$baseUrl/logout'));
    if (response.statusCode == 200) {
      // Handle logout logic (e.g., clear stored user data)
    }
  }
}
