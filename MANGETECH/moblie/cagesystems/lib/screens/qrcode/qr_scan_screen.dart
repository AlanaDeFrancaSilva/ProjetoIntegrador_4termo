import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../ativos/ativo_detalhes_screen.dart';

class QRScanScreen extends StatefulWidget {
  const QRScanScreen({Key? key}) : super(key: key);

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  bool _isScanning = true;
  bool _processingScan = false;
  MobileScannerController controller = MobileScannerController();

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("auth_token");
  }

  void _onDetect(BarcodeCapture capture) async {
    if (!_isScanning || _processingScan) return;

    final barcode = capture.barcodes.first.rawValue;

    if (barcode == null) return;

    setState(() => _processingScan = true);

    final scannedId = barcode.trim();

    // Verifica se é número
    final id = int.tryParse(scannedId);

    if (id == null) {
      _showMessage("QR inválido. Esperado apenas o ID do ativo.");
      setState(() => _processingScan = false);
      return;
    }

    // Agora validar no backend
    await _validateAndOpen(id);

    setState(() => _processingScan = false);
  }

  Future<void> _validateAndOpen(int id) async {
    final token = await _getToken();
    if (token == null) {
      _showMessage("Token não encontrado.");
      return;
    }

    try {
      final url = Uri.parse("http://localhost:8001/api/equipment/$id/");
      final res = await http.get(url, headers: {
        "Authorization": "Token $token",
      });

      if (res.statusCode == 200) {
        // OK → abre a tela do ativo
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AtivoDetalhesScreen(ativoId: id),
          ),
        );
      } else {
        _showMessage("Ativo não encontrado.");
      }
    } catch (e) {
      _showMessage("Erro ao validar QR Code.");
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Escanear QR Code"),
        backgroundColor: Color(0xFF1E293B),
      ),
      body: Stack(
        children: [
          // CAMERA
          MobileScanner(
            controller: controller,
            onDetect: _onDetect,
          ),

          // MÁSCARA ESCURA EM VOLTA
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                color: Colors.black.withOpacity(0.35),
              ),
            ),
          ),

          // QUADRADO CENTRAL
          Center(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          // TEXTO INFORMATIVO
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "Aponte para um QR Code de Ativo",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  shadows: [
                    Shadow(
                        blurRadius: 6,
                        color: Colors.black,
                        offset: Offset(0, 2))
                  ],
                ),
              ),
            ),
          ),

          if (_processingScan)
            Container(
              color: Colors.black54,
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
