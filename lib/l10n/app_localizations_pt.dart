// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Cadastro de Pessoas';

  @override
  String get nameLabel => 'Nome';

  @override
  String get ageLabel => 'Idade';

  @override
  String get addButton => 'Adicionar';

  @override
  String get peopleListTitle => 'Lista de Pessoas';

  @override
  String get invalidAge => 'Por favor, insira uma idade válida';

  @override
  String get emptyName => 'O nome não pode estar vazio';
}
