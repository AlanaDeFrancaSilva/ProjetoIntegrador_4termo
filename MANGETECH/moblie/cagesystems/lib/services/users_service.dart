import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UsersService {
  // Sempre HTTPS — HTTP faz perder o Authorization no redirecionamento
  static const String base =
      "https://cage-int-cqg3ahh4a4hjbhb4.westus3-01.azurewebsites.net/api/auth/users/";

  /// ------------------------------------------------------------
  /// Obtém o token do dispositivo
  /// ------------------------------------------------------------
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("auth_token");
  }

  /// ------------------------------------------------------------
  /// GET /auth/users/me/
  /// ------------------------------------------------------------
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final token = await _getToken();
    if (token == null) return null;

    final response = await http.get(
      Uri.parse("${base}me/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
          "Erro ao buscar usuário logado: ${response.statusCode} → ${response.body}");
    }

    return jsonDecode(response.body);
  }

  /// ------------------------------------------------------------
  /// GET /auth/users/
  /// ------------------------------------------------------------
  static Future<List<dynamic>> getUsers() async {
    final token = await _getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse(base),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
          "Erro ao buscar usuários: ${response.statusCode} → ${response.body}");
    }

    final body = jsonDecode(response.body);
    if (body is List) return body;

    return body["results"] ?? [];
  }

  /// ------------------------------------------------------------
  /// LOGOUT → remove o token
  /// ------------------------------------------------------------
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("auth_token");
  }
}
