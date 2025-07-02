// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'People Register';

  @override
  String get nameLabel => 'Name';

  @override
  String get ageLabel => 'Age';

  @override
  String get addButton => 'Add';

  @override
  String get peopleListTitle => 'List of People';

  @override
  String get invalidAge => 'Please enter a valid age';

  @override
  String get emptyName => 'Name cannot be empty';
}
