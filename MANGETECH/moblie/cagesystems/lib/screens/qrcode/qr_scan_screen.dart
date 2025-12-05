import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../ativos/ativo_detalhes_screen.dart';

class QRScanScreen extends StatefulWidget {
  const QRScanScreen({Key? key}) : super(key: key);

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  bool _processing = false;

  final MobileScannerController controller = MobileScannerController(
    facing: CameraFacing.back,
    detectionSpeed: DetectionSpeed.normal,
    formats: [BarcodeFormat.qrCode],
    autoStart: true,
  );

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("auth_token");
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_processing) return;

    final code = capture.barcodes.first.rawValue;
    print("\n===============================");
    print("📌 QR LIDO: '$code'");
    print("===============================\n");

    if (code == null) return;

    final id = int.tryParse(code.trim());

    print("🔎 ID PARSEADO: $id");

    if (id == null) {
      _showMessage("QR inválido. Valor lido: $code");
      return;
    }

    _processing = true;
    controller.stop();

    final token = await _getToken();
    print("🔑 TOKEN: $token");

    if (token == null) {
      _showMessage("Token não encontrado.");
      _processing = false;
      controller.start();
      return;
    }

    final url = Uri.parse(
      "https://cage-int-cqg3ahh4a4hjbhb4.westus3-01.azurewebsites.net/api/equipment/$id/",
    );

    print("🌐 ACESSANDO URL: $url");

    try {
      final res = await http.get(url, headers: {
        "Authorization": "Token $token",
      });

      print("📡 STATUS DA API: ${res.statusCode}");
      print("📦 RESPOSTA: ${res.body}");

      if (res.statusCode == 200) {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AtivoDetalhesScreen(ativoId: id),
          ),
        );
      } else {
        _showMessage("Ativo não encontrado.");
        _processing = false;
        controller.start();
      }
    } catch (e) {
      print("❌ ERRO AO VALIDAR QR: $e");
      _showMessage("Erro ao validar QR Code: $e");
      _processing = false;
      controller.start();
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
        title: const Text("Escanear QR Code"),
        backgroundColor: Color(0xFF1E293B),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: _onDetect,
          ),

          // Moldura
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3),
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),

          const Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "Aponte para o QR Code do Ativo",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
