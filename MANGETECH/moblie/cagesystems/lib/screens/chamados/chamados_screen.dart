import 'package:flutter/material.dart';
import '../../services/chamados_service.dart';
import 'package:cagesystems/screens/chamados/chamado_detalhes_screen.dart';

class ChamadosScreen extends StatefulWidget {
  @override
  _ChamadosScreenState createState() => _ChamadosScreenState();
}

class _ChamadosScreenState extends State<ChamadosScreen> {
  List<dynamic> chamados = [];
  bool loading = true;
  String searchQuery = "";
  String urgencyFilter = "";

  @override
  void initState() {
    super.initState();
    fetchChamados();
  }

  Future<void> fetchChamados() async {
    setState(() => loading = true);

    final data = await ChamadosService.getChamados(
      search: searchQuery,
      urgency: urgencyFilter,
    );

    setState(() {
      chamados = data;
      loading = false;
    });
  }

  // ============================================================
  //   STATUS
  // ============================================================
  String formatStatus(String status) {
    const map = {
      "OPEN": "Aberto",
      "WAITING_RESPONSIBLE": "Aguardando Responsável",
      "ONGOING": "Em Andamento",
      "DONE": "Concluído",
      "FINISHED": "Finalizado",
      "CANCELLED": "Cancelado"
    };
    return map[status] ?? status;
  }

  Color statusColor(String status) {
    switch (status) {
      case "OPEN":
        return Colors.blue.shade200;
      case "WAITING_RESPONSIBLE":
        return Colors.yellow.shade200;
      case "ONGOING":
        return Colors.orange.shade200;
      case "DONE":
        return Colors.green.shade200;
      case "FINISHED":
        return Colors.indigo.shade200;
      case "CANCELLED":
        return Colors.red.shade200;
      default:
        return Colors.grey.shade300;
    }
  }

  Color statusTextColor(String status) {
    switch (status) {
      case "OPEN":
        return Colors.blue.shade900;
      case "WAITING_RESPONSIBLE":
        return Colors.brown.shade800;
      case "ONGOING":
        return Colors.deepOrange.shade900;
      case "DONE":
        return Colors.green.shade900;
      case "FINISHED":
        return Colors.indigo.shade900;
      case "CANCELLED":
        return Colors.red.shade900;
      default:
        return Colors.black;
    }
  }

  // ============================================================
  //   URGÊNCIA
  // ============================================================
  String formatUrgency(String? urgency) {
    switch ((urgency ?? "").toUpperCase()) {
      case "LOW":
        return "Baixa";
      case "MEDIUM":
        return "Média";
      case "HIGH":
        return "Alta";
      case "EXTRA_HIGH":
        return "Crítica";
      default:
        return "-";
    }
  }

  Color urgencyColor(String? urgency) {
    switch ((urgency ?? "").toUpperCase()) {
      case "LOW":
        return Colors.green.shade700;
      case "MEDIUM":
        return Colors.orange.shade700;
      case "HIGH":
        return Colors.red.shade700;
      case "EXTRA_HIGH":
        return Colors.purple.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F6FA),
      appBar: AppBar(
        title: Text("Chamados"),
        backgroundColor: Color(0xFF1E293B),
      ),

      body: Column(
        children: [
          // 🔎 Campo de busca
          Padding(
            padding: EdgeInsets.all(12),
            child: TextField(
              onChanged: (value) {
                searchQuery = value;
                fetchChamados();
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: "Buscar por título",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),

          // 🔽 Filtro de urgência
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonFormField(
              value: urgencyFilter.isEmpty ? null : urgencyFilter,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                labelText: "Filtrar por urgência",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: [
                DropdownMenuItem(value: "", child: Text("Todas")),
                DropdownMenuItem(value: "LOW", child: Text("Baixa")),
                DropdownMenuItem(value: "MEDIUM", child: Text("Média")),
                DropdownMenuItem(value: "HIGH", child: Text("Alta")),
                DropdownMenuItem(value: "EXTRA_HIGH", child: Text("Crítica")),
              ],
              onChanged: (value) {
                urgencyFilter = value ?? "";
                fetchChamados();
              },
            ),
          ),

          SizedBox(height: 10),

          // LISTA
          Expanded(
            child: loading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: chamados.length,
                    padding: EdgeInsets.all(10),
                    itemBuilder: (context, index) {
                      final t = chamados[index];

                      // 🔥 CORREÇÃO: status seguro SEM ERROS
                      final statusList = (t["TaskStatus_task_FK"] ?? []) as List;
                      final status = statusList.isNotEmpty
                          ? statusList.last["status"]
                          : "OPEN";

                      final urgency = t["urgency_level"];

                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChamadoDetalhesScreen(
                              taskId: t["id"],
                            ),
                          ),
                        ),
                        child: Container(
                          margin: EdgeInsets.only(bottom: 14),
                          padding: EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 4),
                              )
                            ],
                          ),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ID e Status
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "ID: ${t["id"]}",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: statusColor(status),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      formatStatus(status),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: statusTextColor(status),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 8),

                              // Título
                              Text(
                                t["name"],
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              SizedBox(height: 6),

                              // Data + Urgência
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Aberto em: ${DateTime.parse(t["creation_date"]).day.toString().padLeft(2, '0')}/"
                                    "${DateTime.parse(t["creation_date"]).month.toString().padLeft(2, '0')}/"
                                    "${DateTime.parse(t["creation_date"]).year}",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  Text(
                                    formatUrgency(urgency),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: urgencyColor(urgency),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
