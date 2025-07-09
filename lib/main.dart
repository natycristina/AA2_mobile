import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_projects/repositories/user_repository.dart';
import 'package:flutter_projects/screens/register_screen.dart';
import 'package:flutter_projects/viewmodels/register_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'l10n/app_localizations.dart'; // Certifique-se de que está correto
import 'viewmodels/login_viewmodel.dart';
import 'viewmodels/job_listing_viewmodel.dart'; // O SEU JOB LISTING VIEWMODEL
import 'screens/login_screen.dart';
import 'screens/job_listing_screen.dart'; // SUA TELA JOB LISTING SCREEN
import 'database/app_database.dart'; // Importe seu banco de dados

void main() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  final userRepository = UserRepository();
  WidgetsFlutterBinding.ensureInitialized(); // Garante que o Flutter esteja inicializado
  await AppDatabase().database; // <<< Inicializa o banco de dados antes de rodar o app
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => JobListingViewModel()),
        ChangeNotifierProvider(create: (_) => RegisterViewModel(userRepository: userRepository))
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JobTree',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales, // Já está correto
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(
          onLoginSuccess: () => NavigateToJobListing(context),
          onNavigateToRegister: () => NavigateToRegister(context),
        ),
        '/home': (context) => const JobListingScreen(),
        // Adicione aqui a rota para a tela de registro, se tiver
        '/register': (context) => RegisterScreen(
          onRegistrationSuccess: () => NavigateToJobListing(context),
          onNavigateToLogin: () => NavigateToLogin(context)
          ),
      },
    );
  }
}

void NavigateToJobListing(BuildContext context) {
  Navigator.pushReplacementNamed(context, '/home');
}

void NavigateToRegister(BuildContext context) {
  Navigator.pushReplacementNamed(context, '/register');
}

void NavigateToLogin(BuildContext context) {
  Navigator.pushReplacementNamed(context, '/');
}