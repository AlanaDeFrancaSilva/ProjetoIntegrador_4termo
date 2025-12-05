import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:cagesystems/services/token_storage.dart'; // <-- USE O TOKENSTORAGE CORRETAMENTE

import 'home_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // =====================================================
  //                     LOGIN
  // =====================================================
  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError("Preencha todos os campos.");
      return;
    }

    setState(() => loading = true);

    try {
      final url = Uri.parse(
        "https://cage-int-cqg3ahh4a4hjbhb4.westus3-01.azurewebsites.net/api/auth/token/login/",
      );

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      print("🔍 LOGIN STATUS: ${response.statusCode}");
      print("🔍 LOGIN BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data["auth_token"];

        if (token != null) {
          // 🔥 SALVAR TOKEN DO JEITO CORRETO
          await TokenStorage.saveToken(token);

          print("🔑 TOKEN SALVO CORRETAMENTE: $token");

          // NAVEGAÇÃO
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomeScreen()),
          );
        } else {
          _showError("Erro inesperado: token não recebido.");
        }
      } else {
        final body = jsonDecode(response.body);
        _showError(body["detail"] ?? "Email ou senha incorretos.");
      }
    } catch (e) {
      print("❌ LOGIN ERROR: $e");
      _showError("Erro ao conectar ao servidor.");
    } finally {
      setState(() => loading = false);
    }
  }

  // =====================================================
  //                    ERROR SNACKBAR
  // =====================================================
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // =====================================================
  //                          UI
  // =====================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(),

                // LOGO
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Image.asset('assets/logo.png', height: 100),
                ),

                // FORM
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildLoginCard(),
                          const SizedBox(height: 24),
                          _buildSignUpCard(),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // LOADING
          if (loading)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  // =====================================================
  //                   HEADER
  // =====================================================
  Widget _buildHeader() {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF003366), Color(0xFF001F3F)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  // =====================================================
  //                   CARD LOGIN
  // =====================================================
  Widget _buildLoginCard() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Acesse o portal',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Entre usando seu e-mail e senha cadastrados',
                style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 24),

            // EMAIL
            _buildTextField(
              controller: _emailController,
              label: 'E-MAIL',
              hint: 'exemplo@mail.com',
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 16),

            // SENHA
            _buildTextField(
              controller: _passwordController,
              label: 'SENHA',
              hint: 'Digite sua senha',
              obscureText: true,
            ),

            const SizedBox(height: 32),

            // BOTÃO ENTRAR
            ElevatedButton(
              onPressed: loading ? null : _login,
              child: const Text('Entrar',
                  style: TextStyle(fontSize: 16, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF343A40),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  //                CARD DE CADASTRO
  // =====================================================
  Widget _buildSignUpCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ainda não tem uma conta?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Cadastre agora mesmo',
                style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: loading
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignUpScreen()),
                      );
                    },
              child: const Text(
                'Criar conta',
                style: TextStyle(fontSize: 16, color: Color(0xFF343A40)),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  //              INPUT COMPONENT
  // =====================================================
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(),
            ),
          ),
        ),
      ],
    );
  }
}
