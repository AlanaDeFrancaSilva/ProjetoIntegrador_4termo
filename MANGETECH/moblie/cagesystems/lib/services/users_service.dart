import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UsersService {
  // CORRIGINDO localhost → IP do computador
static const String base = "https://cage-int-cqg3ahh4a4hjbhb4.westus3-01.azurewebsites.net/api/";

  /// -------------------------------------------------------------------
  /// Obtém o token salvo (ou retorna null se não existir)
  /// -------------------------------------------------------------------
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("auth_token");
  }

  /// -------------------------------------------------------------------
  /// GET /auth/users/me/ → dados do usuário logado
  /// -------------------------------------------------------------------
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
      throw Exception("Erro ao buscar usuário logado: ${response.body}");
    }

    return jsonDecode(response.body);
  }

  /// -------------------------------------------------------------------
  /// GET /auth/users/ → lista de todos os usuários
  /// -------------------------------------------------------------------
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
      throw Exception("Erro ao buscar usuários: ${response.body}");
    }

    final body = jsonDecode(response.body);

    if (body is List) return body;
    return body["results"] ?? [];
  }
}
