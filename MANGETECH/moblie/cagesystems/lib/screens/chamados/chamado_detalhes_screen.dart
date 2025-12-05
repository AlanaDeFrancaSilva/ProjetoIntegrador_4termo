import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChamadoDetalhesScreen extends StatefulWidget {
  final int taskId;

  const ChamadoDetalhesScreen({Key? key, required this.taskId})
      : super(key: key);

  @override
  _ChamadoDetalhesScreenState createState() => _ChamadoDetalhesScreenState();
}

class _ChamadoDetalhesScreenState extends State<ChamadoDetalhesScreen> {
  static const String baseApi =
      "https://cage-int-cqg3ahh4a4hjbhb4.westus3-01.azurewebsites.net";

  Map<String, dynamic>? task;
  bool loading = true;
  bool submitting = false;

  String? selectedStatus;
  final TextEditingController descriptionController = TextEditingController();
  File? pickedImage;

  @override
  void initState() {
    super.initState();
    _fetchTask();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("auth_token");
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
      final url = Uri.parse("$baseApi/api/task/${widget.taskId}/");

      final res = await http.get(
        url,
        headers: {"Authorization": "Token $token"},
      );

      if (res.statusCode == 200) {
        setState(() => task = jsonDecode(res.body));
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
      "CANCELLED": "Cancelado",
    };
    return map[raw] ?? raw;
  }

  String _getCurrentStatus() {
    final list = (task?['TaskStatus_task_FK'] as List<dynamic>?) ?? [];
    if (list.isEmpty) return "OPEN";
    return list.last["status"].toString();
  }

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
    final picked =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 75);
    if (picked != null) {
      setState(() => pickedImage = File(picked.path));
    }
  }

  Future<void> _selectFromGallery() async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (picked != null) {
      setState(() => pickedImage = File(picked.path));
    }
  }

  Future<void> _submitStatus() async {
    final desc = descriptionController.text.trim();

    if (selectedStatus == null) {
      _showMessage("Selecione um status.");
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
      final url = Uri.parse("$baseApi/api/taskstatus/");

      final request = http.MultipartRequest("POST", url);
      request.headers["Authorization"] = "Token $token";

      request.fields["task_FK"] = widget.taskId.toString();
      request.fields["status"] = selectedStatus!;
      request.fields["description"] = desc;

      if (pickedImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          "image",
          pickedImage!.path,
        ));
      }

      final streamed = await request.send();
      final res = await http.Response.fromStream(streamed);

      if (res.statusCode == 200 || res.statusCode == 201) {
        _showMessage("Status atualizado com sucesso.");

        await _fetchTask();

        setState(() {
          selectedStatus = null;
          descriptionController.clear();
          pickedImage = null;
        });
      } else {
        _showMessage("Erro ao atualizar (${res.statusCode})");
      }
    } catch (e) {
      _showMessage("Erro ao enviar status.");
    } finally {
      setState(() => submitting = false);
    }
  }

  void _openImage(String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: InteractiveViewer(
          child: Container(
            color: Colors.black,
            child: Image.network(url, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }

  // ===================== UI COMPONENTS ===================== //

  Widget _buildHeader() {
    final current = _getCurrentStatus();
    final urg = task?['urgency_level'] ?? '-';

    return Container(
      padding: EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Chamado #${task?['id']}",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: _chipDecoration(),
                child: Text(_formatStatusLabel(current),
                    style: TextStyle(fontWeight: FontWeight.bold)),
              )
            ],
          ),
          SizedBox(height: 8),
          Text(task?["name"] ?? "-",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          SizedBox(height: 6),
          Text("Urgência: $urg",
              style: TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Solicitante:", style: TextStyle(color: Colors.grey[700])),
          SizedBox(height: 4),
          Text(task?["creator_FK"]?["name"] ?? "-",
              style: TextStyle(fontWeight: FontWeight.w700)),
          SizedBox(height: 12),
          Text("Ativo:", style: TextStyle(color: Colors.grey[700])),
          SizedBox(height: 4),
          Text(task?["equipment_FK"]?["name"] ?? "-",
              style: TextStyle(fontWeight: FontWeight.w700)),
          SizedBox(height: 12),
          Text("Abertura:", style: TextStyle(color: Colors.grey[700])),
          SizedBox(height: 4),
          Text(
            task?["creation_date"] != null
                ? DateTime.parse(task!["creation_date"])
                    .toLocal()
                    .toString()
                    .split('.')[0]
                : "-",
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    final list = (task?['TaskStatus_task_FK'] as List<dynamic>?) ?? [];

    if (list.isEmpty) {
      return Text("Nenhum histórico encontrado.");
    }

    return Column(
      children: list.reversed.map((item) {
        final status = item["status"] ?? "";
        final desc = item["description"] ?? "";
        final timestamp = item["timestamp"] ?? item["created_at"] ?? "";
        final image = item["image"];

        final imgUrl = (image != null && image.toString().isNotEmpty)
            ? "$baseApi$image"
            : null;

        return Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(14),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatStatusLabel(status),
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(timestamp.toString().replaceAll("T", " "),
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              if (desc.isNotEmpty) ...[
                SizedBox(height: 8),
                Text(desc),
              ],
              if (imgUrl != null) ...[
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _openImage(imgUrl),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(imgUrl,
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover),
                  ),
                ),
              ]
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAdvanceSection() {
    final current = _getCurrentStatus();
    final options = _allowedNextStatuses(current);

    if (options.isEmpty) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Avançar Status",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 14),

          DropdownButtonFormField<String>(
            value: selectedStatus,
            items: options
                .map((o) => DropdownMenuItem(
                    value: o, child: Text(_formatStatusLabel(o))))
                .toList(),
            onChanged: (v) => setState(() => selectedStatus = v),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[100],
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),

          SizedBox(height: 14),

          TextField(
            controller: descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Descreva o que foi feito...",
              filled: true,
              fillColor: Colors.grey[100],
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),

          SizedBox(height: 14),

          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: Icon(Icons.camera_alt),
                label: Text("Foto"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                ),
              ),
              SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: _selectFromGallery,
                icon: Icon(Icons.photo),
                label: Text("Galeria"),
              ),
              if (pickedImage != null) ...[
                SizedBox(width: 10),
                Image.file(pickedImage!, height: 60),
              ]
            ],
          ),

          SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: submitting ? null : _submitStatus,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey[900],
                padding: EdgeInsets.symmetric(vertical: 14),
              ),
              child: submitting
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("Confirmar"),
            ),
          ),
        ],
      ),
    );
  }

  Decoration _cardDecoration() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))
        ],
      );

  Decoration _chipDecoration() => BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      );

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text("Detalhes do Chamado"), backgroundColor: Colors.blueGrey[900]),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : task == null
              ? Center(child: Text("Chamado não encontrado."))
              : RefreshIndicator(
                  onRefresh: _fetchTask,
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(18),
                    child: Column(
                      children: [
                        _buildHeader(),
                        SizedBox(height: 14),
                        _buildInfoCard(),
                        SizedBox(height: 16),
                        _buildTimeline(),
                        SizedBox(height: 20),
                        _buildAdvanceSection(),
                        SizedBox(height: 50),
                      ],
                    ),
                  ),
                ),
    );
  }
}
