import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cagesystems/services/token_storage.dart';

class AtivosService {
  static const String base =
      "https://cage-int-cqg3ahh4a4hjbhb4.westus3-01.azurewebsites.net/api/equipment/";

  /// Normaliza listas do DRF
  static List<dynamic> _normalizeList(dynamic data) {
    if (data is Map && data.containsKey("results")) return data["results"];
    if (data is List) return data;
    if (data is Map) return [data];
    return [];
  }

  /// ============================================================
  /// 🔹 GET /equipment/?name= — Lista equipamentos
  /// ============================================================
  static Future<List<dynamic>> getAtivos({String? search}) async {
    final token = await TokenStorage.getToken();
    if (token == null) return [];

    final uri = Uri.parse(base).replace(
      queryParameters: search != null && search.isNotEmpty
          ? {"name": search} // sua API usa name como filtro
          : null,
    );

    print("🔎 GET Ativos → $uri");
    print("🔑 Token → $token");

    try {
      final response = await http.get(
        uri,
        headers: {"Authorization": "Token $token"},
      );

      print("📥 Status Ativos: ${response.statusCode}");
      print("📥 Body Ativos: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return _normalizeList(decoded);
      }
    } catch (e) {
      print("❌ ERRO getAtivos: $e");
    }

    return [];
  }

  /// ============================================================
  /// 🔹 GET /equipment/:id — Detalhes
  /// ============================================================
  static Future<Map<String, dynamic>?> getAtivoById(int id) async {
    final token = await TokenStorage.getToken();
    if (token == null) return null;

    final uri = Uri.parse("$base$id/");

    print("🔎 GET Ativo por ID → $uri");

    try {
      final response = await http.get(
        uri,
        headers: {"Authorization": "Token $token"},
      );

      print("📥 Status Ativo ID: ${response.statusCode}");
      print("📥 Body Ativo ID: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) return decoded;
      }
    } catch (e) {
      print("❌ ERRO getAtivoById: $e");
    }

    return null;
  }
}
