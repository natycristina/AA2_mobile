import 'package:flutter/material.dart';
import 'package:flutter_projects/viewmodels/register_viewmodel.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback onRegistrationSuccess;
  final VoidCallback onNavigateToLogin;

  const RegisterScreen({
    required this.onRegistrationSuccess,
    required this.onNavigateToLogin,
    super.key,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nomeController            = TextEditingController();
  final _emailController           = TextEditingController();
  final _passwordController        = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RegisterViewModel>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (viewModel.registrationSuccess) {
        widget.onRegistrationSuccess();
        viewModel.resetRegistrationState();
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFB3E5FC), Colors.white], // VoeBlueLight -> White
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
                const Text(
                  'Crie sua conta',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Preencha os dados para continuar',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 64),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildTextField(
                          label: 'Nome',
                          controller: _nomeController,
                          error: viewModel.errorMessage != null && _nomeController.text.isEmpty,
                          onChanged: viewModel.onNomeChange,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          label: 'Email',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          error: viewModel.errorMessage != null && _emailController.text.isEmpty,
                          onChanged: viewModel.onEmailChange,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          label: 'Senha',
                          controller: _passwordController,
                          obscureText: !_passwordVisible,
                          toggleVisibility: () => setState(() => _passwordVisible = !_passwordVisible),
                          error: viewModel.errorMessage != null && _passwordController.text.isEmpty,
                          onChanged: viewModel.onPasswordChange,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          label: 'Confirmar Senha',
                          controller: _confirmPasswordController,
                          obscureText: !_confirmPasswordVisible,
                          toggleVisibility: () => setState(() => _confirmPasswordVisible = !_confirmPasswordVisible),
                          error: viewModel.errorMessage != null &&
                              (_confirmPasswordController.text.isEmpty ||
                                  _confirmPasswordController.text != _passwordController.text),
                          onChanged: viewModel.onConfirmPasswordChange,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (viewModel.errorMessage != null)
                  Column(
                    children: [
                      Text(
                        viewModel.errorMessage!,
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ElevatedButton(
                  onPressed: viewModel.isLoading ? null : viewModel.register,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    backgroundColor: const Color(0xFFFFD600), // VoeYellow
                  ),
                  child: viewModel.isLoading
                      ? const CircularProgressIndicator(color: Colors.black87)
                      : const Text(
                    'Registrar',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: widget.onNavigateToLogin,
                  child: const Text(
                    'Já tem conta? Faça login',
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required Function(String) onChanged,
    bool error = false,
    bool obscureText = false,
    VoidCallback? toggleVisibility,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        errorText: error ? 'Campo obrigatório' : null,
        suffixIcon: toggleVisibility != null
            ? IconButton(
          icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: toggleVisibility,
        )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
