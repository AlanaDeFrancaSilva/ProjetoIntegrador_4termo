import 'dart:async';
import 'package:flutter/material.dart';


import 'home_screen.dart';

// ----------------------------------
// HOME SCREEN COMPLETA + NAVEGAÇÃO
// ----------------------------------

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentSlide = 0;
  Timer? _timer;

  final List<Map<String, String>> slides = [
    {
      "title": "SUA CENTRAL DE CHAMADOS",
      "highlight": "RÁPIDA",
      "image": "assets/phone.png",
    },
    {
      "title": "ORGANIZAÇÃO EM QUALQUER LUGAR",
      "highlight": "INTELIGENTE",
      "image": "assets/comp.png",
    },
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      setState(() {
        currentSlide = (currentSlide + 1) % slides.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: Row(
          children: [
            _buildSidebar(context),
            Expanded(child: _buildContent(context)),
          ],
        ),
      ),
    );
  }

  // -----------------------------------
  // SIDEBAR
  // -----------------------------------
  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 220,
      color: const Color(0xFF071126),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Image.asset('assets/logob.png', height: 48),
          ),

          Expanded(
            child: ListView(
              children: [
                _menuItem("Home", Icons.home, true, () {
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (_) => const HomeScreen()));
                }),
                _menuItem("Chamados", Icons.list_alt, false, () {
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (_) => const ChamadosScreen()));
                }),
                _menuItem("Técnicos", Icons.people, false, () {
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (_) => const TecnicosScreen()));
                }),
                _menuItem("Clientes", Icons.apartment, false, () {
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (_) => const ClientesScreen()));
                }),
                _menuItem("Monitoramento", Icons.visibility, false, () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => const MonitoramentoScreen()));
                }),
                _menuItem("Ativos", Icons.devices_other, false, () {
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (_) => const AtivosScreen()));
                }),
                _menuItem("Ambientes", Icons.location_city, false, () {
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (_) => const AmbientesScreen()));
                }),
                _menuItem("Documentação", Icons.description, false, () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => const DocumentacaoScreen()));
                }),
              ],
            ),
          ),

          // User Card
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0E1A2A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const CircleAvatar(radius: 20, backgroundColor: Colors.grey),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Alana',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w600)),
                      SizedBox(height: 4),
                      Text('admin@admin.com',
                          style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(String label, IconData icon, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF4B6CFF).withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: selected ? const Color(0xFF4B6CFF) : Colors.white70, size: 20),
            const SizedBox(width: 12),
            Text(label,
                style: TextStyle(
                  color: selected ? const Color(0xFF4B6CFF) : Colors.white70,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                )),
          ],
        ),
      ),
    );
  }

  // -----------------------------------
  // CONTEÚDO PRINCIPAL
  // -----------------------------------
  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 28,
            runSpacing: 28,
            children: [
              _buildChamadosCard(),
              _buildMapCard(),
            ],
          ),
          const SizedBox(height: 28),
          _buildBannerCarousel(),
        ],
      ),
    );
  }

  Widget _buildChamadosCard() {
    return Container(
      width: 740,
      padding: const EdgeInsets.symmetric(vertical: 44, horizontal: 36),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 28, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: const [
          Text("Total de Chamados", style: TextStyle(color: Colors.white70, fontSize: 16)),
          SizedBox(height: 14),
          Text("235", style: TextStyle(color: Colors.white, fontSize: 56, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text("Registrados no sistema", style: TextStyle(color: Colors.white60)),
        ],
      ),
    );
  }

  Widget _buildMapCard() {
    return Container(
      width: 740,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Center(
        child: Image.asset("assets/map.png", width: 500, fit: BoxFit.contain),
      ),
    );
  }

  // -----------------------------------
  // BANNER / CARROSSEL
  // -----------------------------------
  Widget _buildBannerCarousel() {
    return Container(
      height: 340,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 28, offset: const Offset(0, 12)),
        ],
      ),
      child: Stack(
        children: [
          ...slides.asMap().entries.map((entry) {
            int index = entry.key;
            var slide = entry.value;

            bool active = index == currentSlide;

            return AnimatedOpacity(
              opacity: active ? 1 : 0,
              duration: const Duration(milliseconds: 600),
              child: Transform.translate(
                offset: Offset(active ? 0 : 60, 0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 44),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: slide["title"]! + "\n",
                                style: const TextStyle(
                                    fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              TextSpan(
                                text: slide["highlight"]!,
                                style: const TextStyle(
                                    fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF4B6CFF)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 40.0),
                        child: Image.asset(
                          slide["image"]!,
                          width: 250,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),

          Positioned(
            bottom: 18,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(slides.length, (i) {
                bool active = i == currentSlide;
                return GestureDetector(
                  onTap: () => setState(() => currentSlide = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 260),
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: active ? 14 : 10,
                    height: active ? 14 : 10,
                    decoration: BoxDecoration(
                      color: active ? Colors.white : Colors.grey[500],
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),
            ),
          )
        ],
      ),
    );
  }
}
