import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:cagesystems/services/token_storage.dart';

class ChamadosService {
  static const String baseUrl = "https://cage-int-cqg3ahh4a4hjbhb4.westus3-01.azurewebsites.net/api/task/";
  /// ============================================================
  /// 🔹 GET /task/?filtros - lista os chamados
  /// ============================================================
  static Future<List<dynamic>> getChamados({
    String? search,
    String? urgency,
  }) async {
    String? token = await TokenStorage.getToken();
    if (token == null) return [];

    final query = {
      if (search != null && search.isNotEmpty) "name": search,
      if (urgency != null && urgency.isNotEmpty) "urgency_level": urgency,
    };

    final uri = Uri.parse(baseUrl).replace(queryParameters: query);

    final response = await http.get(
      uri,
      headers: {"Authorization": "Token $token"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["results"] ?? data;
    }

    return [];
  }

  /// ============================================================
  /// 🔹 GET /task/:id - detalhar chamado
  /// ============================================================
  static Future<dynamic> getTaskById(int id) async {
    String? token = await TokenStorage.getToken();
    if (token == null) return null;

    final response = await http.get(
      Uri.parse("$baseUrl$id/"),
      headers: {"Authorization": "Token $token"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return null;
  }

  /// ============================================================
  /// 🔹 DELETE /task/:id - deletar chamado (só web)
  /// ============================================================
  static Future<bool> deleteTaskById(int id) async {
    String? token = await TokenStorage.getToken();
    if (token == null) return false;

    final response = await http.delete(
      Uri.parse("$baseUrl$id/"),
      headers: {"Authorization": "Token $token"},
    );

    return response.statusCode == 204;
  }

  /// ============================================================
  /// 🔹 PUT /task/:id - atualizar chamado
  ///    Compatível com Vue!
  /// ============================================================
  static Future<bool> updateTask(int id, Map<String, dynamic> data) async {
    String? token = await TokenStorage.getToken();
    if (token == null) return false;

    final body = {
      "name": data["name"],
      "description": data["description"],
      "urgency_level": data["urgency_level"],
      "responsibles_FK": List.from(data["responsibles_FK"]),
      "equipments_FK": List.from(data["equipments_FK"]),
    };

    final response = await http.put(
      Uri.parse("$baseUrl$id/"),
      headers: {
        "Authorization": "Token $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    return response.statusCode == 200;
  }

  /// ============================================================
  /// 🔥 POST /task/:id/advance-status/
  ///    descrição obrigatória + foto opcional
  /// ============================================================
  static Future<bool> avancarStatus({
    required int taskId,
    required String newStatus,
    required String description,
    File? image,
  }) async {
    String? token = await TokenStorage.getToken();
    if (token == null) return false;

    final url = Uri.parse("$baseUrl$taskId/advance-status/");

    var request = http.MultipartRequest("POST", url);
    request.headers["Authorization"] = "Token $token";

    request.fields["status"] = newStatus;
    request.fields["description"] = description;

    if (image != null) {
      request.files.add(
        await http.MultipartFile.fromPath("image", image.path),
      );
    }

    final response = await request.send();

    return response.statusCode == 200 || response.statusCode == 201;
  }
}
