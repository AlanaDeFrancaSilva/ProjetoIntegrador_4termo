import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// TELAS
import 'package:cagesystems/screens/chamados/chamados_screen.dart';
import 'package:cagesystems/screens/ativos/ativos_lista_screen.dart';
import 'package:cagesystems/screens/qrcode/qr_scan_screen.dart';
import 'package:cagesystems/screens/monitoramento/dashboard_monitoramento_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = "";
  int totalChamados = 0;

  static const String base =
      "https://cage-int-cqg3ahh4a4hjbhb4.westus3-01.azurewebsites.net";

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  // ==========================================================
  //              🔥 BUSCA DADOS DO BACKEND (AZURE)
  // ==========================================================
  Future<void> _loadDashboardData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");

    if (token == null) return;

    try {
      // ----------------- USER -----------------
      final userRes = await http.get(
        Uri.parse("$base/api/auth/users/me/"),
        headers: {"Authorization": "Token $token"},
      );

      print("USER STATUS: ${userRes.statusCode}");
      print("USER BODY: ${userRes.body}");

      if (userRes.statusCode == 200) {
        final userData = jsonDecode(userRes.body);
        setState(() {
          userName = userData["name"] ?? "Técnico";
        });
      }

      // ----------------- TASKS -----------------
      final taskRes = await http.get(
        Uri.parse("$base/api/task/"),
        headers: {"Authorization": "Token $token"},
      );

      print("TASK STATUS: ${taskRes.statusCode}");
      print("TASK BODY: ${taskRes.body}");

      if (taskRes.statusCode == 200) {
        final decoded = jsonDecode(taskRes.body);

        List resultList = decoded["results"] ?? [];

        setState(() {
          totalChamados = resultList.length;
        });
      }
    } catch (e) {
      print("Erro ao carregar dashboard: $e");
    }
  }

  // ==========================================================
  //                           UI
  // ==========================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: Text("Olá, $userName", style: TextStyle(fontSize: 20)),
        backgroundColor: const Color(0xFF1E293B),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(18),
        child: Column(
          children: [
            // ---------------- GRID SUPERIOR ----------------
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(26),
                    height: 180,
                    decoration: BoxDecoration(
                      color: Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 12,
                            offset: Offset(0, 6))
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Total de Chamados",
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                letterSpacing: 0.5)),
                        SizedBox(height: 6),
                        Text(
                          "$totalChamados",
                          style: TextStyle(
                              fontSize: 44,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        Text(
                          "Registrados no sistema",
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(width: 16),

                Expanded(
                  child: Container(
                    height: 180,
                    padding: EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 10,
                            offset: Offset(0, 4))
                      ],
                    ),
                    child: Center(
                      child: Image.asset(
                        "assets/map.png",
                        opacity: AlwaysStoppedAnimation(.9),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 28),

            // ---------------- IMAGEM DO BANNER ----------------
            Container(
              height: 300,
              padding: EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 18,
                      offset: Offset(0, 6))
                ],
              ),
              child: Center(
                child: Image.asset(
                  "assets/telateste1.png",
                  fit: BoxFit.contain,
                  height: 240,
                ),
              ),
            ),

            SizedBox(height: 40),

            // ---------------- MENUS ----------------
            _menuButton(
              icon: Icons.assignment,
              title: "Chamados",
              page: ChamadosScreen(),
            ),
            SizedBox(height: 16),

            _menuButton(
              icon: Icons.devices,
              title: "Ativos",
              page: AtivosListaScreen(),
            ),
            SizedBox(height: 16),

            _menuButton(
              icon: Icons.qr_code_scanner,
              title: "QR Code",
              page: QRScanScreen(),
            ),
            SizedBox(height: 16),

            _menuButton(
              icon: Icons.analytics,
              title: "Monitoramento",
              page: DashboardMonitoramentoScreen(),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- BOTÃO DE MENU ----------------
  Widget _menuButton({
    required IconData icon,
    required String title,
    required Widget page,
  }) {
    return GestureDetector(
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      child: Container(
        padding: EdgeInsets.all(22),
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
          children: [
            Icon(icon, size: 40, color: Color(0xFF1E293B)),
            SizedBox(width: 18),
            Text(title,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
