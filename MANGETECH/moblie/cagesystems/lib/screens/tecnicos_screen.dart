import 'package:flutter/material.dart';
import 'home_screen.dart';     
import 'chamados_screen.dart';
import 'dashboard_screen.dart';
import 'ativos_screen.dart'; 

class TecnicosScreen extends StatelessWidget {
  const TecnicosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(// Fundo branco
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

  /// 
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
                isSelected: false,
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const ChamadosScreen()),
                  );
                },
              ),
              _buildNavIcon(
                icon: Icons.work_outline,
                isSelected: true,
                onTap: () {},
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
              // Ícone Ativos <-- 3. MODIFIQUE AQUI
              _buildNavIcon(
                icon: Icons.apartment_outlined,
                isSelected: false,
                onTap: () {
                  // Navega para a tela de Ativos
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
            // ... (resto do avatar)
          ),
        ],
      ),
    );
  }

  /// Widget auxiliar para criar os ícones de navegação
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

  /// Constrói a área de Conteúdo Principal (à direita)
  Widget _buildMainContent() {
    return Expanded(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white, // Fundo branco
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0), // Padding maior
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              const Text(
                'Técnicos',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              // Subtítulo
              Text(
                'Membros Ativos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.teal[400], // Cor verde-água
                ),
              ),
              const SizedBox(height: 32),
              
              // Tabela
              _buildTableHeader(),
              const Divider(color: Color(0xFFEEEEEE), thickness: 1),
              _buildTableRow('Alana de França', 'Administrador'),
              const Divider(color: Color(0xFFEEEEEE), thickness: 1),
              _buildTableRow('Beatriz Piassa', 'Gestora'),
              const Divider(color: Color(0xFFEEEEEE), thickness: 1),
              _buildTableRow('Cauã Moura', 'Técnico'),
              const Divider(color: Color(0xFFEEEEEE), thickness: 1),
              _buildTableRow('Giovanna Moreira', 'Administrador'),
              const Divider(color: Color(0xFFEEEEEE), thickness: 1),
            ],
          ),
        ),
      ),
    );
  }

  /// Constrói o Cabeçalho da Tabela
  Widget _buildTableHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Expanded(
            flex: 3, // Mais espaço para o nome
            child: Text(
              'Nome',
              style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
          Expanded(
            flex: 2, // Espaço médio para a função
            child: Text(
              'Função',
              style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
          Expanded(
            flex: 1, // Menos espaço para o status
            child: Text(
              'Status',
              style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói uma Linha da Tabela
  Widget _buildTableRow(String nome, String funcao) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              nome,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              funcao,
              style: const TextStyle(fontSize: 15),
            ),
          ),
          Expanded(
            flex: 1,
            child: _buildStatusPill('Ativo'), // o pill de status
          ),
        ],
      ),
    );
  }

  /// constroi o pill de status ativo
  Widget _buildStatusPill(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2F1), 
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: Color(0xFF00796B), 
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}