import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AtivoFromQRScreen extends StatefulWidget {
  final int ativoId;
  const AtivoFromQRScreen({required this.ativoId});

  @override
  _AtivoFromQRScreenState createState() => _AtivoFromQRScreenState();
}

class _AtivoFromQRScreenState extends State<AtivoFromQRScreen> {
  Map<String, dynamic>? ativo;
  List<dynamic> chamados = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadAtivoAndChamados();
  }

  Future<void> _loadAtivoAndChamados() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");

    if (token == null) return;

    try {
      // -----------------------------------------------------
      // 🔥 DETALHES DO ATIVO
      // -----------------------------------------------------
      final eqRes = await http.get(
        Uri.parse("http://localhost:8001/api/equipment/${widget.ativoId}/"),
        headers: {"Authorization": "Token $token"},
      );

      if (eqRes.statusCode == 200) {
        ativo = jsonDecode(eqRes.body);
      }

      // -----------------------------------------------------
      // 🔥 CHAMADOS DO ATIVO
      // -----------------------------------------------------
      final chRes = await http.get(
        Uri.parse(
            "http://localhost:8001/api/task/?equipments_FK=${widget.ativoId}"),
        headers: {"Authorization": "Token $token"},
      );

      if (chRes.statusCode == 200) {
        final data = jsonDecode(chRes.body);

        chamados = data["results"] ??
            data["data"]?["value"]?["results"] ??
            data["data"]?["results"] ??
            data;
      }
    } catch (e) {
      print("Erro QR: $e");
    }

    setState(() => loading = false);
  }

  // ==========================================================
  //                        UI
  // ==========================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ativo ${widget.ativoId}"),
        backgroundColor: Color(0xFF1E293B),
      ),
      backgroundColor: Color(0xFFF4F6FA),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : ativo == null
              ? Center(
                  child: Text(
                    "Ativo não encontrado",
                    style: TextStyle(fontSize: 20),
                  ),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // -----------------------------------------------------
                      // CARD DO ATIVO
                      // -----------------------------------------------------
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 14,
                                offset: Offset(0, 6))
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Nome:",
                                style: TextStyle(color: Colors.grey)),
                            Text("${ativo!['name']}",
                                style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold)),

                            SizedBox(height: 12),

                            Text("Código:",
                                style: TextStyle(color: Colors.grey)),
                            Text("${ativo!['code']}",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600)),

                            SizedBox(height: 12),

                            Text("Categoria:",
                                style: TextStyle(color: Colors.grey)),
                            Text("${ativo!['category_FK']?['name'] ?? '-'}",
                                style: TextStyle(fontSize: 18)),

                            SizedBox(height: 12),

                            Text("Ambiente:",
                                style: TextStyle(color: Colors.grey)),
                            Text("${ativo!['environment_FK']?['name'] ?? '-'}",
                                style: TextStyle(fontSize: 18)),
                          ],
                        ),
                      ),

                      SizedBox(height: 30),

                      // -----------------------------------------------------
                      // LISTA DE CHAMADOS DO ATIVO
                      // -----------------------------------------------------
                      Text(
                        "Chamados relacionados",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),

                      SizedBox(height: 10),

                      Column(
                        children: chamados.map((c) {
                          return Container(
                            margin: EdgeInsets.only(bottom: 14),
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.12),
                                    blurRadius: 14,
                                    offset: Offset(0, 6))
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  c["name"],
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600),
                                ),
                                Icon(Icons.chevron_right,
                                    color: Colors.grey, size: 30)
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                      SizedBox(height: 30),

                      // -----------------------------------------------------
                      // BOTÃO: NOVO CHAMADO
                      // -----------------------------------------------------
                      ElevatedButton.icon(
                        onPressed: () {
                          // Aqui você chama sua tela de novo chamado
                        },
                        icon: Icon(Icons.add, color: Colors.white),
                        label: Text(
                          "Abrir chamado para este ativo",
                          style:
                              TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF1E293B),
                          minimumSize: Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
