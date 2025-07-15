// lib/screens/user_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repositories/user_repository.dart';
import '../viewmodels/user_profile_viewmodel.dart';
import '../models/user_profile.dart';
import '../l10n/app_localizations.dart'; // <--- Importe aqui!

class UserProfileScreen extends StatefulWidget {
  final VoidCallback onBack;

  const UserProfileScreen({Key? key, required this.onBack}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Garante que loadUserProfile() é chamado APENAS uma vez quando a tela é construída
      Provider.of<UserProfileViewModel>(context, listen: false).loadUserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Acessa as strings localizadas. O '!' é seguro aqui porque se não houver,
    // o app não funcionaria de qualquer forma devido à configuração de localização.
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;

    final Color voeBlueLight = Colors.blue.shade100;
    final Color voeTextBlack = Colors.black87;
    final Color voeTextGrey = Colors.grey.shade600;

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.profile_title), // <--- Usando string localizada
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
          tooltip: appLocalizations.back_button_desc, // <--- Usando string localizada
        ),
      ),
      body: Consumer<UserProfileViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (viewModel.errorMessage != null) {
            return Center(
              child: Text(
                viewModel.errorMessage!, // Exibe a mensagem de erro do ViewModel
                style: TextStyle(color: Theme.of(context).colorScheme.error),
                textAlign: TextAlign.center,
              ),
            );
          } else if (viewModel.userProfile != null) {
            final UserProfile userProfile = viewModel.userProfile!;
            return Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 200.0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [voeBlueLight, Colors.white],
                      ),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 60.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                          elevation: 8.0,
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 96.0,
                                  height: 96.0,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: voeBlueLight.withOpacity(0.3),
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    size: 64.0,
                                    color: voeTextBlack,
                                    semanticLabel: appLocalizations.profile_picture_desc, // <--- Usando string localizada
                                  ),
                                ),
                                const SizedBox(height: 16.0),
                                Text(
                                  userProfile.user.nome,
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: voeTextBlack,
                                  ),
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  userProfile.user.email,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: voeTextGrey,
                                  ),
                                ),
                                // Adicione o botão de logout aqui, por exemplo
                                const SizedBox(height: 16.0),
                                ElevatedButton(
                                  onPressed: () async {
                                    await Provider.of<UserRepository>(context, listen: false).clearLoggedUserEmail();
                                    // Adicione a lógica de navegação para a tela de login
                                    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red.shade400,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: Text(appLocalizations.logout_button_text), // String localizada para "Sair"
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            appLocalizations.applied_jobs_title, // <--- Usando string localizada
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: voeTextBlack,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      userProfile.jobs.isEmpty
                          ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          appLocalizations.no_applied_jobs, // <--- Usando string localizada
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: voeTextGrey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                          : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: userProfile.jobs.length,
                        itemBuilder: (context, index) {
                          final job = userProfile.jobs[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              elevation: 2.0,
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      job.titulo,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: voeTextBlack,
                                      ),
                                    ),
                                    const SizedBox(height: 4.0),
                                    Text(
                                      job.empresa,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: voeTextGrey,
                                      ),
                                    ),
                                    // Se você tiver localização no modelo Job:
                                    // if (job.localizacao != null && job.localizacao!.isNotEmpty)
                                    //   Text(
                                    //     job.localizacao!,
                                    //     style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    //           color: voeTextGrey,
                                    //         ),
                                    //   ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24.0),
                    ],
                  ),
                ),
              ],
            );
          } else {
            // Caso não haja dados ou algum erro não capturado, exibir mensagem genérica de erro
            return Center(
              child: Text(
                appLocalizations.profile_load_error, // <--- Usando string localizada
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            );
          }
        },
      ),
    );
  }
}