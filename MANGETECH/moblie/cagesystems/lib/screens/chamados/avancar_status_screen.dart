import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/chamados_service.dart';

class AvancarStatusScreen extends StatefulWidget {
  final dynamic task;

  const AvancarStatusScreen({super.key, required this.task});

  @override
  _AvancarStatusScreenState createState() => _AvancarStatusScreenState();
}

class _AvancarStatusScreenState extends State<AvancarStatusScreen> {
  final TextEditingController descriptionController = TextEditingController();
  File? selectedImage;
  String? nextStatus;

  @override
  void initState() {
    super.initState();
    nextStatus = _getNextStatus(widget.task);
  }

  /// DEFINE O PRÓXIMO STATUS
  String? _getNextStatus(dynamic task) {
    final statusList = task["TaskStatus_task_FK"];
    final current = statusList.isNotEmpty ? statusList.last["status"] : "OPEN";

    switch (current) {
      case "WAITING_RESPONSIBLE":
        return "ONGOING";
      case "ONGOING":
        return "DONE";
      case "DONE":
        return "FINISHED";
      default:
        return null;
    }
  }

  Future pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() => selectedImage = File(picked.path));
    }
  }

  Future submit() async {
    if (descriptionController.text.isEmpty) {
      _showMessage("A descrição é obrigatória.");
      return;
    }

    final success = await ChamadosService.avancarStatus(
      taskId: widget.task["id"],
      newStatus: nextStatus!,
      description: descriptionController.text,
      image: selectedImage,
    );

    if (success) {
      _showMessage("Status atualizado com sucesso!");
      Navigator.pop(context);
    } else {
      _showMessage("Erro ao atualizar o status.");
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F6FA),
      appBar: AppBar(
        title: Text("Avançar Status"),
        backgroundColor: Color(0xFF1E293B),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// STATUS ATUAL
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(18),
              decoration: _cardStyle(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Status Atual:",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                  SizedBox(height: 6),
                  Text(
                    widget.task["TaskStatus_task_FK"].last["status"],
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey.shade900),
                  ),
                ],
              ),
            ),

            SizedBox(height: 18),

            /// PRÓXIMO STATUS
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(18),
              decoration: _cardStyle(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Próximo Status:",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                  SizedBox(height: 6),
                  Text(
                    nextStatus ?? "Não disponível",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800),
                  ),
                ],
              ),
            ),

            SizedBox(height: 18),

            /// DESCRIÇÃO
            Text("Descrição",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
            SizedBox(height: 6),
            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Descreva o que foi feito...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),

            SizedBox(height: 20),

            /// FOTO (OPCIONAL)
            Text("Foto (opcional)",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
            SizedBox(height: 6),

            selectedImage == null
                ? OutlinedButton.icon(
                    onPressed: pickImage,
                    icon: Icon(Icons.camera_alt),
                    label: Text("Tirar Foto"),
                  )
                : Column(
                    children: [
                      Image.file(selectedImage!, height: 180),
                      SizedBox(height: 10),
                      TextButton(
                        onPressed: pickImage,
                        child: Text("Trocar foto"),
                      )
                    ],
                  ),

            SizedBox(height: 30),

            /// BOTÃO SALVAR
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: submit,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Color(0xFF1E293B),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  "Confirmar",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardStyle() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4))
      ],
    );
  }
}
