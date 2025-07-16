// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_projects/models/job.dart';
import 'package:flutter_projects/repositories/user_repository.dart';
import 'package:flutter_projects/screens/apply_to_job_screen.dart';
import 'package:flutter_projects/screens/register_screen.dart';
import 'package:flutter_projects/viewmodels/register_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart'; // Mantenha este import se ainda usar sqflite diretamente, mas geralmente não é necessário aqui
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; //
import 'l10n/app_localizations.dart';
import 'viewmodels/login_viewmodel.dart';
import 'viewmodels/job_listing_viewmodel.dart';
import 'viewmodels/user_profile_viewmodel.dart';
import 'screens/login_screen.dart';
import 'screens/job_listing_screen.dart';
import 'screens/user_profile_screen.dart';
import 'database/app_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit(); //
  databaseFactory = databaseFactoryFfi; //

  final userRepository = UserRepository();

  await AppDatabase().database; // Isso agora usará o sqflite padrão

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => JobListingViewModel()),
        ChangeNotifierProvider(create: (_) => RegisterViewModel(userRepository: userRepository)),
        ChangeNotifierProvider(
          create: (context) => UserProfileViewModel(userRepository),
        ),
        Provider<UserRepository>.value(value: userRepository),
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
      supportedLocales: AppLocalizations.supportedLocales,
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(
          onLoginSuccess: () => NavigateToJobListing(context),
          onNavigateToRegister: () => NavigateToRegister(context),
        ),
        '/home': (context) => const JobListingScreen(),
        '/register': (context) => RegisterScreen(
          onRegistrationSuccess: () => NavigateToJobListing(context),
          onNavigateToLogin: () => NavigateToLogin(context),
        ),
        '/profile': (context) => UserProfileScreen(onBack: () {
          Navigator.of(context).pop();
        }),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/jobApplication') {
          final args = settings.arguments as Map<String, dynamic>;
          final Job job = args['selectedJob'];

          return MaterialPageRoute(
            builder: (context) =>
                ApplyToJobScreen(
                  selectedJob: job,
                  onBack: () => NavigateToJobListing(context),
                ),
          );
        }
        return null;
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