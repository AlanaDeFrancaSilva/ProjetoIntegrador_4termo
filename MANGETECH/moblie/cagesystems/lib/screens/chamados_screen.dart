import 'package:flutter/material.dart';
import 'home_screen.dart'; 
import 'tecnicos_screen.dart'; 
import 'dashboard_screen.dart';
import 'ativos_screen.dart'; 

class ChamadosScreen extends StatelessWidget {
  const ChamadosScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Row(
          children: [
            _buildVerticalNavBar(context),
            _buildMainContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalNavBar(BuildContext context) {
    return Container(
      width: 80,
      color: const Color(0xFF001122),
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(
            'assets/logob.png',
            height: 40,
          ),
          Column(
            children: [
              _buildNavIcon(
                icon: Icons.home,
                isSelected: false,
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
              ),
              _buildNavIcon(
                icon: Icons.people_outline,
                isSelected: true,
                onTap: () {},
              ),
              _buildNavIcon(
                icon: Icons.work_outline,
                isSelected: false,
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const TecnicosScreen()),
                  );
                },
              ),
              _buildNavIcon(
                icon: Icons.grid_view_outlined,
                isSelected: false,
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const DashboardScreen()),
                  );
                },
              ),
              _buildNavIcon(
                icon: Icons.apartment_outlined,
                isSelected: false,
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const AtivosScreen()),
                  );
                },
              ),
              _buildNavIcon(icon: Icons.build_outlined, isSelected: false, onTap: () {}),
              _buildNavIcon(icon: Icons.description_outlined, isSelected: false, onTap: () {}),
            ],
          ),
          const CircleAvatar(
          ),
        ],
      ),
    );
  }

  Widget _buildNavIcon({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.8) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.grey[400],
          size: 28,
        ),
      ),
    );
  }

  /// cria area principal de chamados:
  Widget _buildMainContent() {
    return Expanded(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // status:
              _buildStatCard('Total de Chamadas', '350', const Color(0xFF001F3F), Colors.white),
              const SizedBox(height: 16),
              _buildStatCard('Chamadas Finalizadas', '275', const Color(0xFFE9ECEF), Colors.black),
              const SizedBox(height: 16),
              _buildStatCard('Chamadas em Aberto', '65', const Color(0xFFE9ECEF), Colors.black),
              const SizedBox(height: 16),
              _buildStatCard('Chamadas em Atraso', '10', const Color(0xFFE9ECEF), Colors.black),
              const SizedBox(height: 32),
              
              // notificação:
              const Text(
                'Notificação',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildNotificationCard(),
              const SizedBox(height: 32),

              // histórico:
              const Text(
                'Historico de Chamadas',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildHistoryTable(),
            ],
          ),
        ),
      ),
    );
  }
  
    ///status (total,finalizados,etc)
  Widget _buildStatCard(String title, String value, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: bgColor == Colors.white 
          ? [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5, offset: Offset(0, 2))]
          : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 14),
              ),
              Text(
                value,
                style: TextStyle(color: textColor, fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_forward, color: Colors.purple[800], size: 16),
          )
        ],
      ),
    );
  }

  /// notificação
  Widget _buildNotificationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#0001',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Estou com dificuldades para gerar relatórios no sistema',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Responder'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green, // Cor verde
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          )
        ],
      ),
    );
  }

  /// tabela de historico
  Widget _buildHistoryTable() {
    return Column(
      children: [
        // cabeçalho
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF001F3F), // Azul escuro
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('ID', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text('Cliente', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text('Status', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // dados ficticios
        _buildHistoryRow('#001', 'Adidas', 'Pendente', const Color(0xFFFFF3CD), const Color(0xFF664D03)),
        _buildHistoryRow('#002', 'Adidas', 'Concluido', const Color(0xFFD1E7DD), const Color(0xFF0F5132)),
        _buildHistoryRow('#003', 'Adidas', 'Em andamento', const Color(0xFFFFE0B2), const Color(0xFFE65100)),
      ],
    );
  }

  /// historico:
  Widget _buildHistoryRow(String id, String cliente, String status, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(id, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(cliente, style: TextStyle(fontSize: 16)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}