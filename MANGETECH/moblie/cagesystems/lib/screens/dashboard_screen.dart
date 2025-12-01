import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'chamados_screen.dart';
import 'tecnicos_screen.dart';
import 'ativos_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const Color _cardBgColor = Color(0xFFF4F6FA);
  static const Color _mainTextColor = Color(0xFF0D0D0D);
  static const Color _subTextColor = Color(0xFF8A8A8A);
  static const Color _primaryColor = Color(0xFF5252FF);

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

  /// barra de navegação lateral
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
                isSelected: true,
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
                  // vai pra tela de ativos:
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

  /// icones de navegação
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
              _buildWelcomeHeader(),
              const SizedBox(height: 24),
              _buildTopCardsRow(),
              const SizedBox(height: 24),
              _buildDesempenhoCard(),
              const SizedBox(height: 24),
              _buildAgendaCard(),
              const SizedBox(height: 24),
              _buildAnaliseCard(),
            ],
          ),
        ),
      ),
    );
  }

  /// card ola cauã
  Widget _buildWelcomeHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF001F3F), 
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Olá, Cauã Moura',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'caua@cage.com',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopCardsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(Icons.call_outlined, 'Chamadas', '10'),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildInfoCard(Icons.chat_bubble_outline, 'Mensagem', '2'),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildInfoCard(Icons.people_alt_outlined, 'Total de clientes', '80', isDark: true),
        ),
      ],
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value, {bool isDark = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFFE3E4FF) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? null : Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? _primaryColor : _primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: isDark ? Colors.white : _primaryColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(color: isDark ? Colors.black54 : _subTextColor, fontSize: 12),
          ),
          Text(
            value,
            style: TextStyle(
              color: isDark ? _primaryColor : _mainTextColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// card desempenho
  Widget _buildDesempenhoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Desempenho', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Icon(Icons.more_horiz, color: _subTextColor),
            ],
          ),
          const SizedBox(height: 16),
          _buildDesempenhoRow(Icons.trending_up, 'Desempenho da equipe', '89.80%', Colors.blue),
          const SizedBox(height: 12),
          _buildDesempenhoRow(Icons.call_outlined, 'Chamadas finalizadas', '90.20%', Colors.blue[300]!),
        ],
      ),
    );
  }

  Widget _buildDesempenhoRow(IconData icon, String label, String value, Color iconColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  /// card agenda
  Widget _buildAgendaCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Agenda', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildAgendaDay('03', 'Mon', false),
              _buildAgendaDay('04', 'Tue', false),
              _buildAgendaDay('05', 'Wed', true),
              _buildAgendaDay('06', 'Thu', false),
              _buildAgendaDay('07', 'Fri', false),
            ],
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              '● ● ●',
              style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 2),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAgendaDay(String dayNum, String dayName, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? _primaryColor : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            dayNum,
            style: TextStyle(
              color: isSelected ? Colors.white : _mainTextColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            dayName,
            style: TextStyle(color: isSelected ? Colors.white70 : _subTextColor, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.orangeAccent,
              shape: BoxShape.circle,
            ),
          )
        ],
      ),
    );
  }

  /// card analise
  Widget _buildAnaliseCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Análise', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: const [
                    Text('2025', style: TextStyle(fontWeight: FontWeight.w500)),
                    Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // simulação do grafico
          SizedBox(
            height: 150, 
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildChartBar('Jan', 130, _primaryColor.withOpacity(0.3)),
                _buildChartBar('Fab', 35, _primaryColor),
                _buildChartBar('Mar', 40, _primaryColor.withOpacity(0.3)),
                _buildChartBar('Abr', 55, _primaryColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartBar(String label, double height, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          height.toInt().toString(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        const SizedBox(height: 4),
        // A barra
        Container(
          height: height * 0.7, 
          width: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(color: _subTextColor, fontWeight: FontWeight.w500, fontSize: 12),
        ),
      ],
    );
  }
}