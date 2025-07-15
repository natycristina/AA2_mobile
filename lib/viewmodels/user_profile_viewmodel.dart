// lib/viewmodels/user_profile_viewmodel.dart
import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../repositories/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isApplying = false;

  UserProfileViewModel(this._userRepository);

  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isApplying => _isApplying;

  Future<void> loadUserProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final String? userEmail = await _userRepository.getLoggedUserEmail(); // Obtém o EMAIL

      if (userEmail != null) {
        _userProfile = await _userRepository.getUserProfile(userEmail); // Passa o EMAIL
      } else {
        _errorMessage = 'Usuário não logado. Por favor, faça login.';
      }
    } catch (e) {
      _errorMessage = 'Erro ao carregar perfil: $e';
      print('Erro ao carregar perfil: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Novo método para aplicar a uma vaga
  Future<bool> applyToJob(String userEmail, int jobId) async { // Agora aceita email
    print('UserProfileViewModel: applyToJob START - isApplying = $_isApplying');
    _isApplying = true;
    notifyListeners();
    print('UserProfileViewModel: applyToJob after set true - isApplying = $_isApplying');

    try {
      final bool success = await _userRepository.applyToJob(userEmail, jobId); // Passa o EMAIL
      print('UserProfileViewModel: applyToJob success=$success');

      if (success) {
        await loadUserProfile(); // Recarregar o perfil após aplicar
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Erro ao aplicar à vaga: $e';
      print('UserProfileViewModel: Erro ao aplicar à vaga: $e');
      return false;
    } finally {
      _isApplying = false;
      print('UserProfileViewModel: applyToJob FINALLY - isApplying = $_isApplying');
      notifyListeners();
    }
  }

  // Este método não é mais tão crucial se loadUserProfile já obtém o email.
  // Ele pode ser removido ou adaptado para apenas retornar o email logado.
  Future<String?> getLoggedUserEmail() async {
    return await _userRepository.getLoggedUserEmail();
  }
}