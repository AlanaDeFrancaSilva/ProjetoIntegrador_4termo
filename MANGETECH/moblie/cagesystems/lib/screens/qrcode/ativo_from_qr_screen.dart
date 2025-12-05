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

  static const String base =
      "https://cage-int-cqg3ahh4a4hjbhb4.westus3-01.azurewebsites.net/api";

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
      // 🔥 BUSCA ATIVO
      final eqRes = await http.get(
        Uri.parse("$base/equipment/${widget.ativoId}/"),
        headers: {"Authorization": "Token $token"},
      );

      if (eqRes.statusCode == 200) {
        ativo = jsonDecode(eqRes.body);
      }

      // 🔥 BUSCA CHAMADOS
      final chRes = await http.get(
        Uri.parse("$base/task/?equipment_FK=${widget.ativoId}"),
        headers: {"Authorization": "Token $token"},
      );

      if (chRes.statusCode == 200) {
        final decoded = jsonDecode(chRes.body);
        chamados = decoded["results"] ?? [];
      }
    } catch (e) {
      print("Erro QR: $e");
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(title: Text("Carregando...")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (ativo == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Ativo inválido")),
        body: Center(child: Text("Ativo não encontrado.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Ativo ${widget.ativoId}"),
        backgroundColor: Color(0xFF1E293B),
      ),
      backgroundColor: Color(0xFFF4F6FA),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CARD ATIVO
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 14,
                    offset: Offset(0, 6),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${ativo!['name']}",
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  Text("Código: ${ativo!['code']}"),
                  SizedBox(height: 8),
                  Text("Categoria: ${ativo!['category_FK']?['name'] ?? '-'}"),
                  SizedBox(height: 8),
                  Text("Ambiente: ${ativo!['environment_FK']?['name'] ?? '-'}"),
                ],
              ),
            ),

            SizedBox(height: 30),

            Text("Chamados relacionados",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),

            if (chamados.isEmpty)
              Text("Nenhum chamado encontrado")
            else
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
                          offset: Offset(0, 6),
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${c["name"]}",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600)),
                        Icon(Icons.chevron_right),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
