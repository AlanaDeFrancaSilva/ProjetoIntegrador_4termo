import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'ativo_detalhes_screen.dart';

class AtivosListaScreen extends StatefulWidget {
  const AtivosListaScreen({Key? key}) : super(key: key);

  @override
  State<AtivosListaScreen> createState() => _AtivosListaScreenState();
}

class _AtivosListaScreenState extends State<AtivosListaScreen> {
  List<dynamic> ativos = [];
  bool loading = true;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _fetchAtivos();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("auth_token");
  }

  Future<void> _fetchAtivos() async {
    setState(() => loading = true);

    final token = await _getToken();
    if (token == null) {
      _showMessage("Token não encontrado.");
      return;
    }

    try {
      final url =
          Uri.parse("http://localhost:8001/api/equipment/?name=$searchQuery");

      final res = await http.get(url, headers: {
        "Authorization": "Token $token",
      });

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);

        // 🔥 GARANTE FORMATO LISTA
        final list =
            decoded["data"]?["value"]?["results"] ??
                decoded["data"]?["results"] ??
                decoded["results"] ??
                (decoded is List ? decoded : [decoded]);

        setState(() => ativos = List.from(list));
      } else {
        _showMessage("Erro ao buscar ativos (${res.statusCode}).");
      }
    } catch (e) {
      _showMessage("Erro ao conectar ao servidor.");
    } finally {
      setState(() => loading = false);
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // 🔍 Função auxiliar segura, sem estouro de tipo
  String safeField(dynamic value) {
    if (value == null) return "-";
    if (value is Map && value.containsKey("name")) return value["name"];
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ativos"),
        backgroundColor: Color(0xFF1E293B),
      ),
      backgroundColor: Color(0xFFF4F6FA),
      body: Column(
        children: [
          // 🔎 SEARCH
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (v) {
                searchQuery = v;
                _fetchAtivos();
              },
              decoration: InputDecoration(
                hintText: "Buscar por nome/código",
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),

          Expanded(
            child: loading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: ativos.length,
                    itemBuilder: (_, i) {
                      final ativo = ativos[i];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AtivoDetalhesScreen(
                                ativoId: ativo["id"],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          padding: EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 8,
                                  offset: Offset(0, 4))
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                safeField(ativo["name"]),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 6),

                              Text(
                                "Código: ${safeField(ativo["code"])}",
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                              SizedBox(height: 6),

                              Text(
                                "Categoria: ${safeField(ativo["category_FK"])}",
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                              SizedBox(height: 6),

                              Text(
                                "Ambiente: ${safeField(ativo["environment_FK"])}",
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }
}
