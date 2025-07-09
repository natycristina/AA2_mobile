import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../viewmodels/login_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onLoginSuccess;
  final VoidCallback? onNavigateToRegister;

  const LoginScreen({super.key, this.onLoginSuccess, this.onNavigateToRegister});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LoginViewModel>(context);
    final texts = AppLocalizations.of(context); // Mantenha sem '!' aqui

    // --- ADIÇÕES PARA DEPURAR O AppLocalizations ---
    print('BUILD LoginScreen: texts object is null? ${texts == null}');
    if (texts == null) {
      // Se 'texts' for nulo, significa que AppLocalizations.of(context) falhou.
      // Isso é um problema fundamental na configuração de internacionalização ou no contexto.
      return const Center(
        child: Text(
          'Erro Crítico: As localizações não foram carregadas. Verifique main.dart e l10n.yaml.',
          style: TextStyle(color: Colors.red, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }
    print('DEBUG: AppLocalizations.of(context) is NOT null.');
    print('DEBUG: texts.fillAllTheFields: "${texts.fillAllTheFields}"');
    // --- FIM DAS ADIÇÕES PARA DEPURAR ---


    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF9FC9EB), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 100),
                Text(
                  texts.login_title,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 48,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  texts.login_subtitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 64),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextField(
                          onChanged: viewModel.onEmailChanged,
                          decoration: InputDecoration(
                            labelText: texts.email,
                            border: InputBorder.none,
                            filled: true,
                            fillColor: Colors.white,
                            // MUDANÇA MAIS ROBUSTA NO errorText:
                            errorText: (viewModel.errorMessage != null && viewModel.email.isEmpty)
                                ? (texts.fillAllTheFields) // Garante que é String
                                : null,
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          onChanged: viewModel.onPasswordChanged,
                          obscureText: !_passwordVisible,
                          decoration: InputDecoration(
                            labelText: texts.password,
                            border: InputBorder.none,
                            filled: true,
                            fillColor: Colors.white,
                            // MUDANÇA MAIS ROBUSTA NO errorText:
                            errorText: (viewModel.errorMessage != null && viewModel.password.isEmpty)
                                ? (texts.fillAllTheFields) // Garante que é String
                                : null,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _passwordVisible ? Icons.visibility : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              },
                            ),
                          ),
                          keyboardType: TextInputType.visiblePassword,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Este bloco de erro já está seguro
                if (viewModel.errorMessage != null && viewModel.errorMessage!.isNotEmpty)
                  Text(
                    viewModel.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: viewModel.isLoading
                      ? null
                      : () async {
                    final ok = await viewModel.login();
                    if (ok && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(texts.login_success_message)),
                      );
                      Navigator.pushReplacementNamed(context, '/home');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    minimumSize: const Size.fromHeight(56),
                  ),
                  child: viewModel.isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : Text(
                    texts.login,
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: widget.onNavigateToRegister ?? () { /* Implementar navegação para registro */ },
                  child: Text(texts.dont_have_account),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}