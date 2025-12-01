import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'chamados_screen.dart';
import 'tecnicos_screen.dart';
import 'dashboard_screen.dart';

class AtivosScreen extends StatelessWidget {
  const AtivosScreen({super.key});

  // Cores da tela
  static const Color _navBarColor = Color(0xFF001122);
  static const Color _cardBgColor = Color(0xFFF4F6FA);
  static const Color _buttonColor = Color(0xFF2F2FDB);
  static const Color _mainTextColor = Color(0xFF0D0D0D);

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
                isSelected: false,
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
                isSelected: true,
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

  /// area principal
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
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderButtons(),
              const SizedBox(height: 24),
              _buildTotalAtivosCard(),
              const SizedBox(height: 24),
              _buildAtivoItemCard(
                titulo: 'Impressora HP Laserjet',
                tecnico: 'Técnico Caua',
                id: '#005',
                tipo: 'Impressora',
                status: 'Pendente',
                localizacao: 'Setor A',
                descricao: 'Manutenção preventiva e troca de rolamentos',
              ),
              const SizedBox(height: 16),
              _buildAtivoItemCard(
                titulo: 'Impressora HP Laserjet',
                tecnico: 'Técnico Caua',
                id: '#005',
                tipo: 'Impressora',
                status: 'Pendente',
                localizacao: 'Setor A',
                descricao: 'Manutenção preventiva e troca de rolamentos',
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// botao novo ativo e status
  Widget _buildHeaderButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Ativos',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _mainTextColor),
        ),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, color: Colors.white, size: 18),
              label: const Text('Novo Ativo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _buttonColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Status'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF001122), // Azul escuro
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// card total de ativos
  Widget _buildTotalAtivosCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _cardBgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 2.5, 
        children: [
          _buildAtivoGridItem(Icons.computer_outlined, 'Computador', '200'),
          _buildAtivoGridItem(Icons.print_outlined, 'Impressora', '79'),
          _buildAtivoGridItem(Icons.storage_outlined, 'Servidor', '27'),
          _buildAtivoGridItem(Icons.router_outlined, 'Switch', '290'),
        ],
      ),
    );
  }

  Widget _buildAtivoGridItem(IconData icon, String nome, String total) {
    return Row(
      children: [
        Icon(icon, size: 36, color: _buttonColor),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(nome, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            Text(
              total,
              style: const TextStyle(color: _mainTextColor, fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        )
      ],
    );
  }

  /// card impressora
  Widget _buildAtivoItemCard({
    required String titulo,
    required String tecnico,
    required String id,
    required String tipo,
    required String status,
    required String localizacao,
    required String descricao,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _cardBgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // cabeçalho do card
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                titulo,
                style: const TextStyle(color: _buttonColor, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                tecnico,
                style: const TextStyle(color: _mainTextColor, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(height: 24),
          // informações
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoColumn('ID', id),
              _buildInfoColumn('Tipo', tipo),
              _buildInfoColumn('Status', status),
              _buildInfoColumn('Localização', localizacao),
            ],
          ),
          const Divider(height: 24),
          _buildInfoColumn('Descrição do Serviço', descricao),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: _mainTextColor, fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}