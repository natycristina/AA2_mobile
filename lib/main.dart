import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart'; // Certifique-se de que está correto
import 'viewmodels/login_viewmodel.dart';
import 'viewmodels/job_listing_viewmodel.dart'; // O SEU JOB LISTING VIEWMODEL
import 'screens/login_screen.dart';
import 'screens/job_listing_screen.dart'; // SUA TELA JOB LISTING SCREEN
import 'database/app_database.dart'; // Importe seu banco de dados

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Garante que o Flutter esteja inicializado
  await AppDatabase().database; // <<< Inicializa o banco de dados antes de rodar o app
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => JobListingViewModel()),
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
        '/': (context) => const LoginScreen(),
        '/home': (context) => const JobListingScreen(),
        // Adicione aqui a rota para a tela de registro, se tiver
        // '/register': (context) => const RegisterScreen(),
      },
    );
  }
}