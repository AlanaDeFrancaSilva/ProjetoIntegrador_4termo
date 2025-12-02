import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../chamados/chamado_detalhes_screen.dart';

class AtivoDetalhesScreen extends StatefulWidget {
  final int ativoId;

  const AtivoDetalhesScreen({Key? key, required this.ativoId}) : super(key: key);

  @override
  State<AtivoDetalhesScreen> createState() => _AtivoDetalhesScreenState();
}

class _AtivoDetalhesScreenState extends State<AtivoDetalhesScreen> {
  Map<String, dynamic>? ativo;
  List<dynamic> chamados = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  // ================================================================
  //                       SAFE FIELD
  // ================================================================
  String safeField(dynamic value) {
    if (value == null) return "-";

    if (value is Map) {
      if (value.containsKey("name")) return value["name"].toString();
      if (value.containsKey("title")) return value["title"].toString();
    }

    return value.toString();
  }

  // ================================================================
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("auth_token");
  }

  Future<void> _loadAll() async {
    setState(() => loading = true);

    await _fetchAtivo();
    await _fetchChamados();

    setState(() => loading = false);
  }

  // ================================================================
  //                       BUSCA ATIVO
  // ================================================================
  Future<void> _fetchAtivo() async {
    final token = await _getToken();
    if (token == null) return;

    try {
      final url =
          Uri.parse("http://localhost:8001/api/equipment/${widget.ativoId}/");
      final res = await http.get(url, headers: {"Authorization": "Token $token"});

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        ativo = decoded["data"]?["value"] ?? decoded;
      }
    } catch (e) {
      _showMessage("Erro ao carregar ativo.");
    }
  }

  // ================================================================
  //                       BUSCA CHAMADOS
  // ================================================================
  Future<void> _fetchChamados() async {
    final token = await _getToken();
    if (token == null) return;

    try {
      final url =
          Uri.parse("http://localhost:8001/api/task/?equipment_FK=${widget.ativoId}");
      final res = await http.get(url, headers: {"Authorization": "Token $token"});

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);

        chamados = decoded["data"]?["value"]?["results"] ??
            decoded["data"]?["results"] ??
            decoded["results"] ??
            (decoded is List ? decoded : []) ??
            [];
      }
    } catch (e) {
      _showMessage("Erro ao carregar chamados.");
    }
  }

  // ================================================================
  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ================================================================
  //                        INFO TILE
  // ================================================================
  Widget _infoTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        SizedBox(height: 12),
      ],
    );
  }

  // ================================================================
  //                              UI
  // ================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detalhes do Ativo"),
        backgroundColor: Color(0xFF1E293B),
      ),
      backgroundColor: Color(0xFFF4F6FA),

      body: loading
          ? Center(child: CircularProgressIndicator())
          : ativo == null
              ? Center(child: Text("Ativo não encontrado."))
              : RefreshIndicator(
                  onRefresh: _loadAll,
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // =====================================================
                        //                   CARD DO ATIVO
                        // =====================================================
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                safeField(ativo!["name"]),
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 10),
                              _infoTile("Código", safeField(ativo!["code"])),
                              _infoTile("Categoria", safeField(ativo!["category_FK"])),
                              _infoTile("Ambiente", safeField(ativo!["environment_FK"])),
                              _infoTile(
                                "Criado em",
                                ativo!["creation_date"] != null
                                    ? ativo!["creation_date"].toString().split("T")[0]
                                    : "-",
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 24),

                        // =====================================================
                        //                         QR CODE
                        // =====================================================
                       // =====================================================
//                         QR CODE
// =====================================================
Container(
  width: double.infinity,
  padding: EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(18),
    boxShadow: [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 8,
        offset: Offset(0, 4),
      ),
    ],
  ),
  child: Column(
    children: [
      Text(
        "QR Code do Ativo",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 16),

      // QR CODE GERADO A PARTIR DO ID DO ATIVO
      QrImageView(
        data: widget.ativoId.toString(),
        size: 200,
        backgroundColor: Colors.white,
      ),

      SizedBox(height: 4),
      Text(
        "ID: ${widget.ativoId}",
        style: TextStyle(color: Colors.grey[700]),
      ),
    ],
  ),
),


                        SizedBox(height: 24),

                        // =====================================================
                        //                    CHAMADOS DO ATIVO
                        // =====================================================
                        Text(
                          "Chamados deste Ativo",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),

                        chamados.isEmpty
                            ? Container(
                                padding: EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text("Nenhum chamado relacionado."),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: chamados.length,
                                separatorBuilder: (_, __) =>
                                    SizedBox(height: 12),
                                itemBuilder: (_, index) {
                                  final task = chamados[index];

                                  final statusList =
                                      task["TaskStatus_task_FK"] ?? [];
                                  final lastStatus = statusList.isNotEmpty
                                      ? statusList.last["status"] ?? "-"
                                      : "-";

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ChamadoDetalhesScreen(
                                            taskId: task["id"],
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(18),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(14),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 8,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            safeField(task["name"]),
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 6),
                                          Text(
                                            "Status: $lastStatus",
                                            style: TextStyle(
                                              color: Colors.grey[700],
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),

                        SizedBox(height: 60),
                      ],
                    ),
                  ),
                ),
    );
  }
}
