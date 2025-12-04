import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cagesystems/services/token_storage.dart';

class AtivosService {
  // TROQUE localhost → IP da sua máquina
  static const String base = "https://cage-int-cqg3ahh4a4hjbhb4.westus3-01.azurewebsites.net/api/equipment/";

  /// Normaliza retorno exatamente como seu norm()
  static dynamic normalize(dynamic data) {
    return data["data"]?["value"]?["results"] ??
           data["data"]?["results"] ??
           data["results"] ??
           data ??
           [];
  }

  /// ============================================================
  /// 🔹 GET /equipment/?filtros — Lista equipamentos
  /// ============================================================
  static Future<List<dynamic>> getAtivos({String? search}) async {
    final token = await TokenStorage.getToken();

    final uri = Uri.parse(base).replace(
      queryParameters: search != null && search.isNotEmpty
          ? {"name": search}
          : null,
    );

    final response = await http.get(
      uri,
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return normalize(decoded);
    }

    return [];
  }

  /// ============================================================
  /// 🔹 GET /equipment/:id — Buscar detalhes
  /// ============================================================
  static Future<dynamic> getAtivoById(int id) async {
    final token = await TokenStorage.getToken();

    final response = await http.get(
      Uri.parse("$base$id/"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded["data"]?["value"] ?? decoded;
    }
    return null;
  }

  /// ============================================================
  /// 🔹 GET /environment — Ambientes
  /// ============================================================
  static const String envBase = "https://cage-int-cqg3ahh4a4hjbhb4.westus3-01.azurewebsites.net/api/environment/";

  static Future<List<dynamic>> getAmbientes() async {
    final token = await TokenStorage.getToken();

    final response = await http.get(
      Uri.parse(envBase),
      headers: {"Authorization": "Bearer $token"},
    );

    final decoded = jsonDecode(response.body);
    return normalize(decoded);
  }

  /// ============================================================
  /// 🔹 GET /category — Categorias
  /// ============================================================
  static const String catBase = "https://cage-int-cqg3ahh4a4hjbhb4.westus3-01.azurewebsites.net/api/category/";

  static Future<List<dynamic>> getCategorias() async {
    final token = await TokenStorage.getToken();

    final response = await http.get(
      Uri.parse(catBase),
      headers: {"Authorization": "Bearer $token"},
    );

    final decoded = jsonDecode(response.body);
    return normalize(decoded);
  }
}
