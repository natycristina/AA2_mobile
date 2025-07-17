// lib/viewmodels/register_viewmodel.dart
import 'package:flutter/material.dart';
// import 'package:flutter_projects/l10n/app_localizations_pt.dart'; // Removido, use AppLocalizations geral
import 'package:flutter_projects/repositories/user_repository.dart';

class RegisterViewModel extends ChangeNotifier {
  final UserRepository userRepository;

  RegisterViewModel({required this.userRepository});

  String _nome              = '';
  String _email             = '';
  String _password          = '';
  String _confirmPassword   = '';
  bool _isLoading           = false;
  bool _registrationSuccess = false;
  String? _errorMessage;

  String get nome => _nome;
  String get email => _email;
  String get password => _password;
  String get confirmPassword => _confirmPassword;
  bool get isLoading => _isLoading;
  bool get registrationSuccess => _registrationSuccess;
  String? get errorMessage => _errorMessage;

  void onNomeChange(String value) {
    _nome = value;
    _errorMessage = null;
    notifyListeners();
  }

  void onEmailChange(String value) {
    _email = value;
    _errorMessage = null;
    notifyListeners();
  }

  void onPasswordChange(String value) {
    _password = value;
    _errorMessage = null;
    notifyListeners();
  }

  void onConfirmPasswordChange(String value) {
    _confirmPassword = value;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> register() async {
    debugPrint("RegisterViewModel: register method called");

    _isLoading = true;
    _errorMessage = null;
    _registrationSuccess = false;
    notifyListeners();

    if (_nome.isEmpty || _email.isEmpty || _password.isEmpty || _confirmPassword.isEmpty) {
      _errorMessage = "Preencha todos os campos"; // Você pode usar appLocalizations aqui
      _isLoading = false;
      notifyListeners();
      return;
    }

    if (_password != _confirmPassword) {
      _errorMessage = "As senhas não coincidem."; // Você pode usar appLocalizations aqui
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      debugPrint("RegisterViewModel: tentando registrar $_nome / $_email");

      // CORREÇÃO AQUI: Chamar registerUser em vez de register
      final result = await userRepository.registerUser(
        _nome,
        _email,
        _password,
      );

      _isLoading = false;
      if (result) { // 'result' agora é um booleano (true/false)
        _registrationSuccess = true;
        debugPrint("RegisterViewModel: registro com sucesso");
        final perform_login = await userRepository.loginUser(_email, _password);
        if(perform_login == null) {
          _registrationSuccess = false;
          _errorMessage = "Login após registro mal sucedido";
        }
      } else {
        _errorMessage = "Erro ao registrar. Tente novamente."; // Você pode usar appLocalizations aqui
        debugPrint("RegisterViewModel: erro no registro");
      }
    } catch (e) {
      _errorMessage = "Erro inesperado: ${e.toString()}"; // Você pode usar appLocalizations aqui
      _isLoading = false;
      debugPrint("RegisterViewModel: exceção: $e");
    }

    notifyListeners();
  }

  void resetRegistrationState() {
    _registrationSuccess = false;
    _errorMessage = null;
    notifyListeners();
  }
}