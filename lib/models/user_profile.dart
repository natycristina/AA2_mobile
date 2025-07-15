// lib/models/user_profile.dart
import 'user.dart'; // Certifique-se de que o modelo User existe e está correto
import 'job.dart';  // Certifique-se de que o modelo Job existe e está correto

class UserProfile {
  final User user;
  final List<Job> jobs;

  UserProfile({
    required this.user,
    required this.jobs,
  });

// Remova o fromMap/toMap se não for usar. Se for usar, adapte para o novo User.
// Neste caso, você provavelmente vai construir UserProfile diretamente
// a partir de um User e uma lista de Jobs obtidos do repositório.
}