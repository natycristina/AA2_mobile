import 'package:flutter/material.dart';
import '../repositories/user_repository.dart'; // O SEU REPOSITÓRIO DE USUÁRIO
import '../models/user.dart'; // Para o tipo User

class LoginViewModel extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository(); // Instância do seu repositório

  String _email = '';
  String _password = '';
  bool _isLoading = false;
  String? _errorMessage;
  bool _loginSuccess = false;
  User? _loggedInUser; // Para armazenar o usuário logado

  String get email => _email;
  String get password => _password;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get loginSuccess => _loginSuccess;
  User? get loggedInUser => _loggedInUser;

  void onEmailChanged(String value) { // Alterado de setEmail para onEmailChanged
    _email = value;
    _errorMessage = null; // Limpa a mensagem de erro ao digitar
    notifyListeners();
  }

  void onPasswordChanged(String value) { // Alterado de setPassword para onPasswordChanged
    _password = value;
    _errorMessage = null; // Limpa a mensagem de erro ao digitar
    notifyListeners();
  }

  Future<bool> login() async {
    _isLoading = true;
    _errorMessage = null;
    _loginSuccess = false;
    notifyListeners();

    if (_email.isEmpty || _password.isEmpty) {
      _errorMessage = 'Por favor, preencha todos os campos.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    try {
      print("${_email}, ${_password}");
      final user = await _userRepository.login(_email, _password);
      if (user != null) {
        _loginSuccess = true;
        _loggedInUser = user;
        print('Login bem-sucedido para: ${user.email}');
        return true;
      } else {
        _errorMessage = 'Credenciais inválidas.'; // Isso é para quando o login falha (local ou backend)
        print('Falha no login.');
        return false;
      }
    } catch (e) {
      // GARANTA QUE _errorMessage RECEBE UMA STRING VÁLIDA AQUI
      _errorMessage = 'Ocorreu um erro inesperado. Tente novamente. Detalhes: ${e.toString() ?? 'Erro desconhecido'}';
      print('Erro de login (catch no ViewModel): $e');
      return false; // Retorna false em caso de exceção
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  void resetLoginState() {
    _email = '';
    _password = '';
    _isLoading = false;
    _errorMessage = null;
    _loginSuccess = false;
    _loggedInUser = null;
    notifyListeners();
  }
}