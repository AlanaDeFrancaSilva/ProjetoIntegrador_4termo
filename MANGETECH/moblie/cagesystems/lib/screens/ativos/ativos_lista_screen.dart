import 'package:flutter/material.dart';
import '../../services/ativos_service.dart';
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

  Future<void> _fetchAtivos() async {
    setState(() => loading = true);

    try {
      final data = await AtivosService.getAtivos(search: searchQuery);
      setState(() {
        ativos = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      print("❌ ERRO na tela de ativos: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao carregar ativos.")),
      );
    }
  }

  String safeField(dynamic v) {
    if (v == null) return "-";
    if (v is Map && v.containsKey("name")) return v["name"].toString();
    return v.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ativos"),
        backgroundColor: Color(0xFF1E293B),
      ),
      backgroundColor: const Color(0xFFF4F6FA),

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
                ? const Center(child: CircularProgressIndicator())
                : ativos.isEmpty
                    ? const Center(child: Text("Nenhum ativo encontrado."))
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
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              padding: const EdgeInsets.all(20),
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
                                  Text(
                                    safeField(ativo["name"]),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 6),
                                  Text(
                                    "Código: ${safeField(ativo["code"])}",
                                    style:
                                        TextStyle(color: Colors.grey.shade700),
                                  ),

                                  const SizedBox(height: 6),
                                  Text(
                                    "Categoria: ${safeField(ativo["category_FK"])}",
                                    style:
                                        TextStyle(color: Colors.grey.shade700),
                                  ),

                                  const SizedBox(height: 6),
                                  Text(
                                    "Ambiente: ${safeField(ativo["environment_FK"])}",
                                    style:
                                        TextStyle(color: Colors.grey.shade700),
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
