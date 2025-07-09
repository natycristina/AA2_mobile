// Remova os imports de http se você só for usar o DB local por enquanto
// import 'package:http/http.dart' as http;
// import 'dart:convert';
import '../models/user.dart';
import '../database/app_database.dart'; // Importe o banco de dados
import '../services/user_api_service.dart'; // Importe o serviço de API
import 'package:shared_preferences/shared_preferences.dart'; // Para persistir o ID do usuário logado
import '../models/job.dart'; // <--- ADICIONADO: Importe o modelo Job
// import '../models/job_user.dart'; // <--- Se você realmente precisar deste modelo, descomente e crie-o.
//      Para os erros atuais, ele não é necessário aqui.

class UserRepository {
  final AppDatabase _appDatabase = AppDatabase();
  final UserApiService _userApiService = UserApiService();

  // Método de login (agora com backend e banco de dados local)
  Future<User?> login(String email, String password) async {
    // Tenta primeiro o login via backend (R3)
    try {
      final User? backendUser = await _userApiService.loginUser(email, password);

      if (backendUser != null) {
        // Se o backend validou, garantimos que o usuário existe localmente (R4)
        final String passwordToStoreLocally = password; // Ou o hash se você estiver usando BCrypt

        User? localUser = await _appDatabase.getUserByEmail(email);

        if (localUser != null) {
          localUser.idUser = backendUser.idUser;
          localUser.nome = backendUser.nome;
          localUser.senha = passwordToStoreLocally;
          await _appDatabase.insertUser(localUser);
        } else {
          final newUser = User(
            idUser: backendUser.idUser,
            nome: backendUser.nome,
            email: backendUser.email,
            senha: passwordToStoreLocally,
          );
          await _appDatabase.insertUser(newUser);
          localUser = newUser;
        }

        if (localUser != null && localUser.idUser != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('logged_user_id', localUser.idUser!);
        }
        return localUser;
      }
    } catch (e) {
      print('Erro de conexão com o backend. Tentando login local: $e');
    }

    // Se o login via backend falhou ou deu erro, tenta o login apenas localmente (R4)
    final User? localUser = await _appDatabase.getUserByEmail(email);
    if (localUser != null) {
      if (localUser.senha == password) { // Por enquanto, comparação direta para teste
        print('Login local bem-sucedido via SQLite.');
        if (localUser.idUser != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('logged_user_id', localUser.idUser!);
        }
        return localUser;
      }
    }
    return null;
  }

  // Método de registro (agora com backend e banco de dados local)
  Future<bool> register(String nome, String email, String password) async {
    try {
      final User? backendUser = await _userApiService.registerUser(nome, email, password);

      if (backendUser != null) {
        final hashedPassword = password;

        final newUser = User(
          idUser: backendUser.idUser,
          nome: nome,
          email: email,
          senha: hashedPassword,
        );
        final id = await _appDatabase.insertUser(newUser);
        print('Usuário registrado no backend e salvo localmente com ID: $id');
        return id > 0;
      } else {
        print('Falha ao registrar no backend. Não salvando localmente.');
        return false;
      }
    } catch (e) {
      print('Erro ao registrar usuário (tentando backend): $e');
      return false;
    }
  }

  // Adicione um método para aplicar a uma vaga
  Future<bool> applyToJob(int userId, int jobId) async {
    try {
      // A linha "final jobUser = JobUser(...);" FOI REMOVIDA
      // pois o seu AppDatabase.applyToJob espera userId e jobId diretamente.
      final id = await _appDatabase.applyToJob(userId, jobId); // <--- CORRIGIDO AQUI!
      return id > 0;
    } catch (e) {
      print('Erro ao aplicar à vaga: $e');
      return false;
    }
  }

  // Adicione um método para obter vagas aplicadas por um usuário
  Future<List<Job>> getAppliedJobs(int userId) async {
    return await _appDatabase.getAppliedJobsForUser(userId); // <--- CORRIGIDO AQUI!
  }

  // Método para limpar o ID do usuário logado (usado ao fazer logout)
  Future<void> clearLoggedUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('logged_user_id');
  }

  // Método para obter o ID do usuário logado
  Future<int?> getLoggedUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('logged_user_id');
  }
}