// lib/viewmodels/login_viewmodel.dart
import 'package:flutter/material.dart';
import '../repositories/user_repository.dart';
import '../models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginViewModel extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository(); // Instancia aqui

  String _email = '';
  String _password = '';
  bool _isLoading = false;
  String? _errorMessage;
  bool _loginSuccess = false;
  User? _loggedInUser;

  String get email => _email;
  String get password => _password;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get loginSuccess => _loginSuccess;
  User? get loggedInUser => _loggedInUser;

  void onEmailChanged(String value) {
    _email = value;
    _errorMessage = null;
    notifyListeners();
  }

  void onPasswordChanged(String value) {
    _password = value;
    _errorMessage = null;
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
      print("Tentando login para: ${_email}");
      final user = await _userRepository.loginUser(_email, _password); // CHAMA O NOVO MÉTODO loginUser
      if (user != null) {
        _loginSuccess = true;
        _loggedInUser = user;
        print('Login bem-sucedido para: ${user.email}');
        // O UserRepository já deve ter salvo o email em SharedPreferences.
        return true;
      } else {
        _errorMessage = 'Credenciais inválidas.';
        print('Falha no login.');
        return false;
      }
    } catch (e) {
      _errorMessage = 'Ocorreu um erro inesperado. Tente novamente. Detalhes: ${e.toString()}';
      print('Erro de login (catch no ViewModel): $e');
      return false;
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