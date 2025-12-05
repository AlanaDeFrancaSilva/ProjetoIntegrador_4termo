import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DashboardMonitoramentoScreen extends StatefulWidget {
  const DashboardMonitoramentoScreen({Key? key}) : super(key: key);

  @override
  State<DashboardMonitoramentoScreen> createState() =>
      _DashboardMonitoramentoScreenState();
}

class _DashboardMonitoramentoScreenState
    extends State<DashboardMonitoramentoScreen> {
  bool loading = true;

  Map<String, dynamic>? user;
  List<dynamic> tasks = [];

  int totalChamados = 0;
  int mensagens = 0;
  int totalClientes = 0;

  // agenda fake (igual ao web)
  final agenda = [
    {"dia": "Segunda", "tarefa": "Revisar chamados pendentes"},
    {"dia": "Terça", "tarefa": "Visita técnica"},
    {"dia": "Quarta", "tarefa": "Instalação de equipamentos"},
  ];

  static const String base =
      "https://cage-int-cqg3ahh4a4hjbhb4.westus3-01.azurewebsites.net";

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("auth_token");
  }

  Future<void> _loadDashboard() async {
    setState(() => loading = true);

    await Future.wait([
      _fetchUser(),
      _fetchTasks(),
      _fetchUsersCount(),
    ]);

    _processDashboardData();

    setState(() => loading = false);
  }

  /// GET Usuário logado
  Future<void> _fetchUser() async {
    final token = await _getToken();
    if (token == null) return;

    final url = Uri.parse("$base/api/auth/users/me/");

    final res = await http.get(url, headers: {
      "Authorization": "Token $token",
    });

    print("USER STATUS: ${res.statusCode}");
    print("USER BODY: ${res.body}");

    if (res.statusCode == 200) {
      user = jsonDecode(res.body);
    }
  }

  /// GET Tasks
  Future<void> _fetchTasks() async {
    final token = await _getToken();
    if (token == null) return;

    final url = Uri.parse("$base/api/task/");

    final res = await http.get(url, headers: {
      "Authorization": "Token $token",
    });

    print("TASKS STATUS: ${res.statusCode}");
    print("TASKS BODY: ${res.body}");

    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      tasks = decoded["results"] ?? [];
    }
  }

  /// GET total usuários
  Future<void> _fetchUsersCount() async {
    final token = await _getToken();
    if (token == null) return;

    final url = Uri.parse("$base/api/auth/users/");

    final res = await http.get(url, headers: {
      "Authorization": "Token $token",
    });

    print("USERS STATUS: ${res.statusCode}");
    print("USERS BODY: ${res.body}");

    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      totalClientes = (decoded["results"] ?? []).length;
    }
  }

  /// PROCESSAMENTO DOS DADOS
  void _processDashboardData() {
    totalChamados = tasks.length;

    mensagens = tasks
        .where((t) =>
            (t["type"] ?? "").toString().toLowerCase() == "mensagem")
        .length;
  }

  /// ÚLTIMO STATUS
  String _getLatestStatus(task) {
    final list = task["TaskStatus_task_FK"] ?? [];
    if (list.isEmpty) return "OPEN";
    return list.last["status"] ?? "OPEN";
  }

  /// CONTAGEM DE STATUS
  Map<String, int> _countStatus() {
    final counts = <String, int>{};

    for (var t in tasks) {
      final status = _getLatestStatus(t);
      counts[status] = (counts[status] ?? 0) + 1;
    }
    return counts;
  }

  Color _statusColor(String status) {
    switch (status) {
      case "OPEN":
        return Colors.blue;
      case "WAITING_RESPONSIBLE":
        return Colors.amber;
      case "ONGOING":
        return Colors.orange;
      case "DONE":
        return Colors.green;
      case "FINISHED":
        return Colors.indigo;
      case "CANCELLED":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _labelStatus(String s) {
    const m = {
      "OPEN": "Aberto",
      "WAITING_RESPONSIBLE": "Aguardando",
      "ONGOING": "Em Andamento",
      "DONE": "Concluído",
      "FINISHED": "Finalizado",
      "CANCELLED": "Cancelado",
    };
    return m[s] ?? s;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text("Monitoramento"),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboard,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // HEADER ====================================================
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1E293B), Color(0xFF1E3A8A)],
                          ),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Olá, ${user?["name"] ?? ""}",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Text(user?["email"] ?? "",
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 14)),
                          ],
                        ),
                      ),

                      const SizedBox(height: 22),

                      // CARDS ====================================================
                      Row(
                        children: [
                          _cardInfo("Total de Chamados",
                              totalChamados.toString()),
                          const SizedBox(width: 12),
                          _cardInfo("Mensagens", mensagens.toString()),
                          const SizedBox(width: 12),
                          _cardInfo("Total de Clientes",
                              totalClientes.toString()),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // GRÁFICO ====================================================
                      _buildStatusChart(),

                      const SizedBox(height: 28),

                      // AGENDA ====================================================
                      _buildAgenda(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _cardInfo(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(color: Colors.grey[700], fontSize: 13)),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChart() {
    final counts = _countStatus();

    if (counts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Center(
          child: Text("Nenhum chamado para exibir."),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Text(
            "Distribuição de Chamados por Status",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 260,
            child: PieChart(
              PieChartData(
                sections: counts.entries.map((e) {
                  final color = _statusColor(e.key);
                  return PieChartSectionData(
                    color: color,
                    value: e.value.toDouble(),
                    title: "",
                    radius: 60,
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: counts.entries.map((e) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      width: 12, height: 12, color: _statusColor(e.key)),
                  const SizedBox(width: 4),
                  Text("${_labelStatus(e.key)} (${e.value})"),
                ],
              );
            }).toList(),
          )
        ],
      ),
    );
  }

  Widget _buildAgenda() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Agenda da Semana",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          ...agenda.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 18, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "${item["dia"]}: ${item["tarefa"]}",
                      style: const TextStyle(fontSize: 14),
                    ),
                  )
                ],
              ),
            );
          }).toList(),
        ],
      ), 
    );
  }
}
