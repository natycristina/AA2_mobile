import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart'; // Reutiliza seu modelo User

class UserApiService {
  // Use 10.0.2.2 para emulador Android
  // Se for dispositivo físico, use o IP real da sua máquina (ex: 192.168.1.100)
  // Certifique-se de que seu backend Node.js está rodando em http://localhost:3001
  static const String _baseUrl = 'http://10.0.2.2:3001';

  Future<User?> registerUser(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        // Supondo que o backend retorna os dados do usuário registrado
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        // Ajuste a criação do User.fromJson conforme o que seu backend retorna.
        // Se seu backend retorna um objeto User com ID, email, senha, etc.
        return User.fromJson(responseBody);
      } else {
        print('Erro no registro via backend: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Erro ao conectar com o backend para registro: $e');
      return null;
    }
  }

  Future<User?> loginUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        // Supondo que o backend retorna os dados do usuário logado
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        // Ajuste a criação do User.fromJson conforme o que seu backend retorna.
        return User.fromJson(responseBody);
      } else {
        print('Erro no login via backend: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Erro ao conectar com o backend para login: $e');
      return null;
    }
  }
}