// lib/repositories/user_repository.dart
import '../models/user.dart';
import '../database/app_database.dart';
import '../models/user_profile.dart';
import '../services/user_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/job.dart';

class UserRepository {
  final AppDatabase _appDatabase;
  final UserApiService _userApiService;

  UserRepository({
    AppDatabase? database,
    UserApiService? apiService,
  }) : _appDatabase = database ?? AppDatabase(),
       _userApiService = apiService ?? UserApiService();

  Future<User?> loginUser(String email, String password) async { // Renomeado para loginUser para evitar conflito com 'login'
    // Tenta primeiro o login via backend (R3)
    try {
      // O backend apenas retorna o que foi mandado
      // Então, é necessário pegar o usuário do banco de dados e comparar com
      // as credenciais enviadas
      final User? backendUser = await _userApiService.loginUser(email, password);
      final User? dbUser = await _appDatabase.getUserByEmail(email);

      if (backendUser != null && dbUser != null) {
        // Se o backend validou, garantimos que o usuário existe localmente (R4)
        // O usuário do backend já deve ter nome, email e senha.
        if (backendUser.senha == dbUser.senha) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('logged_user_email', backendUser.email); // Salva o EMAIL

          print('Login via backend bem-sucedido. Email salvo em SharedPreferences: ${backendUser.email}');
          return backendUser;
        }
        return null;
      }
    } catch (e) {
      print('Erro de conexão com o backend ou falha no backend login. Tentando login local: $e');
    }

    // Se o login via backend falhou ou deu erro, tenta o login apenas localmente (R4)
    final User? localUser = await _appDatabase.getUserByEmailAndSenha(email, password); // Usa o método com senha
    if (localUser != null) {
      print('Login local via SQLite bem-sucedido.');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('logged_user_email', localUser.email); // Salva o EMAIL
      return localUser;
    }
    print('Login falhou (backend e local).');
    return null;
  }

  Future<bool> registerUser(String nome, String email, String password) async { // Renomeado para registerUser
    try {
      final User? backendUser = await _userApiService.registerUser(nome, email, password);
      print(backendUser?.email ?? "brull");
      if (backendUser != null) {
        // Se o backend registrou com sucesso, insere ou atualiza no DB local
        await _appDatabase.insertUser(backendUser);
        print('Usuário registrado no backend e salvo/atualizado localmente: ${backendUser.email}');
        return true;
      } else {
        print('Falha ao registrar no backend. Não salvando localmente.');
        return false;
      }
    } catch (e) {
      print('Erro ao registrar usuário (tentando backend): $e');
      return false;
    }
  }

  // Novo método para obter o perfil completo do usuário
  Future<UserProfile?> getUserProfile(String userEmail) async { // Agora recebe email
    final User? user = await _appDatabase.getUserByEmail(userEmail);
    if (user != null) {
      final List<Job> appliedJobs = await _appDatabase.getAppliedJobsForUser(userEmail); // Agora passa email
      return UserProfile(user: user, jobs: appliedJobs);
    }
    return null;
  }

  // Adicione um método para aplicar a uma vaga
  Future<bool> applyToJob(String userEmail, int jobId) async { // Agora recebe email
    try {
      await _appDatabase.applyToJob(userEmail, jobId);
      return true;
    } catch (e) {
      print('Erro ao aplicar à vaga no UserRepository: $e');
      return false;
    }
  }

  // Métodos para SharedPreferences
  Future<void> saveLoggedUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('logged_user_email', email);
    print('Email do usuário logado salvo: $email');
  }

  Future<String?> getLoggedUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('logged_user_email');
    print('Email do usuário logado recuperado: $email');
    return email;
  }

  Future<void> clearLoggedUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('logged_user_email');
    print('Email do usuário logado removido.');
  }
}