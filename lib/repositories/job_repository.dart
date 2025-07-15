// lib/repositories/job_repository.dart
import '../models/job.dart';
import '../database/app_database.dart'; // Importe o banco de dados

class JobRepository {
  final AppDatabase _appDatabase; // Instância do banco de dados

  JobRepository({
    AppDatabase? database
  }) : _appDatabase = database ?? AppDatabase();

  // O método getJobs agora busca do banco de dados SQLite
  Future<List<Job>> getJobs() async {
    // Você pode decidir se busca da API (futuramente) ou do local
    // Por enquanto, vamos buscar do local
    print("BRUH2");
    return await _appDatabase.getJobs();
  }

  // O método getJobById também busca do banco de dados
  Future<Job?> getJobById(int id) async {
    return await _appDatabase.getJobById(id);
  }

  // Adicione um método para inserir uma vaga (se você tiver um admin para isso)
  Future<int> insertJob(Job job) async {
    return await _appDatabase.insertJob(job);
  }

// Futuramente, você pode integrar com seu backend Node.js aqui:
// Future<List<Job>> fetchJobsFromApi() async {
//   final response = await http.get(Uri.parse('http://10.0.2.2:3001/jobs'));
//   if (response.statusCode == 200) {
//     List<dynamic> jsonList = jsonDecode(response.body);
//     return jsonList.map((json) => Job.fromJson(json)).toList();
//   } else {
//     throw Exception('Failed to load jobs');
//   }
// }
}