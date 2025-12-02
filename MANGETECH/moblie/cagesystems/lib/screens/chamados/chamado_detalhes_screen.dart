import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChamadoDetalhesScreen extends StatefulWidget {
  final int taskId; // ID do chamado (chamado a partir da lista)

  const ChamadoDetalhesScreen({Key? key, required this.taskId}) : super(key: key);

  @override
  _ChamadoDetalhesScreenState createState() => _ChamadoDetalhesScreenState();
}

class _ChamadoDetalhesScreenState extends State<ChamadoDetalhesScreen> {
  Map<String, dynamic>? task;
  bool loading = true;
  bool submitting = false;

  // Avançar status
  String? selectedStatus;
  final TextEditingController descriptionController = TextEditingController();
  File? pickedImage;

  @override
  void initState() {
    super.initState();
    _fetchTask();
  }

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _fetchTask() async {
    setState(() => loading = true);
    final token = await _getToken();
    if (token == null) {
      _showMessage("Token não encontrado. Faça login novamente.");
      setState(() => loading = false);
      return;
    }

    try {
      final res = await http.get(
        Uri.parse("http://localhost:8001/api/task/${widget.taskId}/"),
        headers: {"Authorization": "Token $token"},
      );

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        // web pode devolver em wrappers diferentes — tratar:
        final data = decoded['data']?['value'] ?? decoded;
        setState(() => task = data);
      } else {
        _showMessage("Erro ao buscar chamado (${res.statusCode}).");
      }
    } catch (e) {
      _showMessage("Erro ao conectar ao servidor.");
    } finally {
      setState(() => loading = false);
    }
  }

  String _formatStatusLabel(String raw) {
    final map = {
      "OPEN": "Aberto",
      "WAITING_RESPONSIBLE": "Aguardando Responsável",
      "ONGOING": "Em Andamento",
      "DONE": "Concluído",
      "FINISHED": "Finalizado",
      "CANCELLED": "Cancelado"
    };
    return map[raw] ?? raw;
  }

  /// Retorna o último status (string) ou 'OPEN' se não existir
  String _getCurrentStatus() {
    final list = task?['TaskStatus_task_FK'] as List<dynamic>?;
    if (list == null || list.isEmpty) return "OPEN";
    return (list.last['status'] ?? 'OPEN').toString();
  }

  /// Retorna as opções válidas para avançar a partir do status atual
  List<String> _allowedNextStatuses(String current) {
    switch (current) {
      case "WAITING_RESPONSIBLE":
        return ["ONGOING", "CANCELLED"];
      case "OPEN":
        return ["WAITING_RESPONSIBLE", "ONGOING", "CANCELLED"];
      case "ONGOING":
        return ["DONE", "CANCELLED"];
      case "DONE":
        return ["FINISHED"];
      default:
        return [];
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera, imageQuality: 75);
    if (picked != null) {
      setState(() => pickedImage = File(picked.path));
    }
  }

  Future<void> _selectFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (picked != null) {
      setState(() => pickedImage = File(picked.path));
    }
  }

  Future<void> _submitStatus() async {
    final desc = descriptionController.text.trim();
    if (selectedStatus == null) {
      _showMessage("Selecione um status para avançar.");
      return;
    }
    if (desc.isEmpty) {
      _showMessage("A descrição é obrigatória.");
      return;
    }

    setState(() => submitting = true);

    final token = await _getToken();
    if (token == null) {
      _showMessage("Token não encontrado.");
      setState(() => submitting = false);
      return;
    }

    try {
      // Endpoint: POST /api/taskstatus/
      final uri = Uri.parse("http://localhost:8001/api/taskstatus/");

      final request = http.MultipartRequest("POST", uri);
      request.headers['Authorization'] = "Token $token";

      request.fields['task_FK'] = widget.taskId.toString();
      request.fields['status'] = selectedStatus!;
      request.fields['description'] = desc;

      // Se backend exigir creator_FK, normalmente ele usa o token para quem cria.
      // Se precisar enviar, descomente e ajuste:
      // request.fields['creator_FK'] = usuarioId.toString();

      if (pickedImage != null) {
        final file = await http.MultipartFile.fromPath('image', pickedImage!.path);
        request.files.add(file);
      }

      final streamed = await request.send();
      final res = await http.Response.fromStream(streamed);

      if (res.statusCode == 201 || res.statusCode == 200) {
        _showMessage("Status atualizado com sucesso.");
        // Recarrega o chamado para atualizar timeline e status atual
        await _fetchTask();
        // limpar form
        setState(() {
          selectedStatus = null;
          descriptionController.clear();
          pickedImage = null;
        });
      } else {
        // tenta detalhar erro
        String body = res.body;
        String msg = "Erro ao atualizar status (${res.statusCode}).";
        try {
          final json = jsonDecode(body);
          msg = json['detail']?.toString() ?? json.toString();
        } catch (_) {}
        _showMessage(msg);
      }
    } catch (e) {
      _showMessage("Erro ao enviar status.");
    } finally {
      setState(() => submitting = false);
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  void _openImage(String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: InteractiveViewer(
          child: Container(
            color: Colors.black,
            child: Image.network(url, fit: BoxFit.contain, loadingBuilder: (ctx, child, progress) {
              if (progress == null) return child;
              return SizedBox(width: 200, height: 200, child: Center(child: CircularProgressIndicator()));
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final current = _getCurrentStatus();
    final urg = task?['urgency_level'] ?? '-';
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0,4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ID e status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Chamado #${task?['id'] ?? widget.taskId}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300)
                ),
                child: Text(_formatStatusLabel(current), style: TextStyle(fontWeight: FontWeight.w700)),
              )
            ],
          ),
          SizedBox(height: 8),
          Text(task?['name'] ?? '-', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          SizedBox(height: 6),
          Row(
            children: [
              Text("Urgência: ", style: TextStyle(color: Colors.grey[700])),
              Text(urg.toString(), style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0,4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Solicitante", style: TextStyle(color: Colors.grey[600])),
          SizedBox(height: 6),
          Text(task?['creator_FK']?['name'] ?? '-', style: TextStyle(fontWeight: FontWeight.w700)),
          SizedBox(height: 12),
          Text("Ativo", style: TextStyle(color: Colors.grey[600])),
          SizedBox(height: 6),
          Text(task?['equipment_FK']?['name'] ?? '-', style: TextStyle(fontWeight: FontWeight.w700)),
          SizedBox(height: 12),
          Text("Abertura", style: TextStyle(color: Colors.grey[600])),
          SizedBox(height: 6),
          Text(task?['creation_date'] != null ? DateTime.parse(task!['creation_date']).toLocal().toString().split('.')[0] : '-', style: TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    final list = (task?['TaskStatus_task_FK'] as List<dynamic>?) ?? [];
    if (list.isEmpty) {
      return Container(
        padding: EdgeInsets.all(18),
        child: Text("Nenhum histórico encontrado.", style: TextStyle(color: Colors.grey[700])),
      );
    }

    return Column(
      children: list.reversed.map((s) {
        final status = s['status'] ?? '';
        final desc = s['description'] ?? '';
        final timestamp = s['timestamp'] ?? s['created_at'] ?? '';
        final imageUrl = s['image'] ?? null; // ajustar conforme campo real
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0,4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatStatusLabel(status.toString()), style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(timestamp.toString().replaceAll("T", " "), style: TextStyle(color: Colors.grey[600], fontSize: 12))
                ],
              ),
              if (desc.toString().isNotEmpty) ...[
                SizedBox(height: 8),
                Text(desc.toString()),
              ],
              if (imageUrl != null && imageUrl.toString().isNotEmpty) ...[
                SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _openImage(imageUrl.toString().startsWith('http') ? imageUrl.toString() : "http://localhost:8001${imageUrl.toString()}"),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl.toString().startsWith('http') ? imageUrl.toString() : "http://localhost:8001${imageUrl.toString()}",
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (ctx, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          height: 120,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      },
                      errorBuilder: (_, __, ___) => Container(
                        height: 120,
                        color: Colors.grey[200],
                        child: Center(child: Icon(Icons.broken_image)),
                      ),
                    ),
                  ),
                )
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAdvanceSection() {
    final current = _getCurrentStatus();
    final options = _allowedNextStatuses(current);

    if (options.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0,4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Avançar Status", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 12),

          // dropdown
          DropdownButtonFormField<String>(
            value: selectedStatus,
            decoration: InputDecoration(
              filled: true, fillColor: Colors.grey[50],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))
            ),
            items: options.map((o) => DropdownMenuItem(value: o, child: Text(_formatStatusLabel(o)))).toList(),
            onChanged: (v) => setState(() => selectedStatus = v),
            hint: Text("Selecione o próximo status"),
          ),

          SizedBox(height: 12),

          // descrição obrigatória
          TextField(
            controller: descriptionController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: "Descreva o que foi feito (obrigatório)",
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))
            ),
          ),

          SizedBox(height: 12),

          // imagens
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: Icon(Icons.camera_alt),
                label: Text("Tirar foto"),
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF1E293B)),
              ),
              SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: _selectFromGallery,
                icon: Icon(Icons.photo_library),
                label: Text("Galeria"),
              ),
              SizedBox(width: 10),
              if (pickedImage != null)
                Expanded(
                  child: Stack(
                    children: [
                      Image.file(pickedImage!, height: 64, fit: BoxFit.cover),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: GestureDetector(
                          onTap: () => setState(() => pickedImage = null),
                          child: Container(
                            color: Colors.black38,
                            child: Icon(Icons.close, color: Colors.white, size: 18),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
            ],
          ),

          SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: submitting ? null : _submitStatus,
              child: submitting ? SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text("Confirmar"),
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF1E293B), padding: EdgeInsets.symmetric(vertical: 14)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detalhes do Chamado"),
        backgroundColor: Color(0xFF1E293B),
      ),
      backgroundColor: Color(0xFFF4F6FA),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : task == null
              ? Center(child: Text("Chamado não encontrado"))
              : RefreshIndicator(
                  onRefresh: _fetchTask,
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        SizedBox(height: 12),
                        _buildInfoCard(),
                        SizedBox(height: 16),
                        _buildTimeline(),
                        SizedBox(height: 18),
                        _buildAdvanceSection(),
                        SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
    );
  }
}
