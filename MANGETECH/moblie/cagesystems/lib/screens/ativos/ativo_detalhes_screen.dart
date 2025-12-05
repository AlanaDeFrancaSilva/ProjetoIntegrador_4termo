import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../services/ativos_service.dart';
import '../../services/chamados_service.dart';
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

  Future<void> _loadAll() async {
    setState(() => loading = true);

    try {
      ativo = await AtivosService.getAtivoById(widget.ativoId);

      // busca todos os chamados e filtra pelo ativo
      var todosChamados = await ChamadosService.getChamados();
      chamados = todosChamados.where((c) {
        final equips = c["equipments_FK"] ?? [];
        return equips.any((e) => e["id"] == widget.ativoId);
      }).toList();
    } catch (e) {
      print("❌ ERRO em AtivoDetalhesScreen: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao carregar dados do ativo.")),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  String safe(dynamic v) {
    if (v == null) return "-";
    if (v is Map && v.containsKey("name")) return v["name"].toString();
    return v.toString();
  }

  Widget infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  String traduzStatus(String s) {
    const map = {
      "OPEN": "Aberto",
      "WAITING_RESPONSIBLE": "Aguardando responsável",
      "ONGOING": "Em andamento",
      "DONE": "Concluído",
      "FINISHED": "Finalizado",
      "CANCELLED": "Cancelado",
    };
    return map[s] ?? s;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalhes do Ativo"),
        backgroundColor: const Color(0xFF1E293B),
      ),
      backgroundColor: const Color(0xFFF4F6FA),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ativo == null
              ? const Center(child: Text("Ativo não encontrado."))
              : RefreshIndicator(
                  onRefresh: _loadAll,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // CARD DO ATIVO
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                safe(ativo!["name"]),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              infoTile("Código", safe(ativo!["code"])),
                              infoTile("Categoria", safe(ativo!["category_FK"])),
                              infoTile("Ambiente", safe(ativo!["environment_FK"])),
                              infoTile(
                                "Criado em",
                                ativo!["creation_date"]
                                        ?.toString()
                                        .split("T")[0] ??
                                    "-",
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // QR CODE
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              )
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                "QR Code do Ativo",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              QrImageView(
                                data: widget.ativoId.toString(),
                                size: 200,
                                backgroundColor: Colors.white,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "ID: ${widget.ativoId}",
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // CHAMADOS
                        const Text(
                          "Chamados do Ativo",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),

                        chamados.isEmpty
                            ? Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child:
                                    const Text("Nenhum chamado encontrado."),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: chamados.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (_, i) {
                                  final t = chamados[i];
                                  final statusList =
                                      (t["TaskStatus_task_FK"] ?? []) as List;
                                  final lastStatus = statusList.isNotEmpty
                                      ? statusList.last["status"] ?? "-"
                                      : "-";

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
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(14),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 8,
                                            offset: Offset(0, 3),
                                          )
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            safe(t["name"]),
                                            style: const TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            "Status: ${traduzStatus(lastStatus)}",
                                            style: TextStyle(
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
    );
  }
}
