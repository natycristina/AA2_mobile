import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_projects/database/app_database.dart';
import 'package:flutter_projects/models/job.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApplyToJobScreen extends StatefulWidget {
  final Job? selectedJob;
  final VoidCallback? onBack;

  const ApplyToJobScreen({super.key, this.selectedJob, this.onBack});

  @override
  State<ApplyToJobScreen> createState() => _ApplyToJobScreenState();
}

class _ApplyToJobScreenState extends State<ApplyToJobScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _portfolioController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Enviar Candidatura"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _fullNameController,
              decoration: const InputDecoration(
                labelText: "Nome completo",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _portfolioController,
              decoration: const InputDecoration(
                labelText: "Link para o portfólio",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            GestureDetector(
              onTap: () {
                // widget.applyToJob(widget.jobId);
              },
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF00BFA6), width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.cloud_upload, size: 32, color: Color(0xFF00BFA6)),
                    SizedBox(height: 8),
                    Text(
                      "Enviar currículo",
                      style: TextStyle(
                        color: Color(0xFF00BFA6),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _messageController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: "Carta de apresentação",
                border: OutlineInputBorder(),
              ),
            ),
            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  final prefs     = await SharedPreferences.getInstance();
                  final userEmail = prefs.getString('logged_user_email');
                  final jobId     = widget.selectedJob!.idJob;

                  if (userEmail != null && jobId != null) {
                    await AppDatabase().insertUserJob(userEmail, jobId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Candidatura enviada com sucesso'),)
                    );
                    Navigator.pushReplacementNamed(context, "/home");
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Erro ao enviar candidatura"))
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD600),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Enviar Candidatura",
                  style: TextStyle(color: Color(0xFF1A1A1A)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}