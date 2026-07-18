// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navigatorParamError => 'Parameter Error';

  @override
  String get navigatorUnknownPage => 'Unknown Page';

  @override
  String get geJuDetail => 'Pattern Detail';

  @override
  String get edit => 'Edit';

  @override
  String get copy => 'Copy';

  @override
  String get saveAs => 'Save As';

  @override
  String get copyJson => 'Copy JSON';

  @override
  String get delete => 'Delete';

  @override
  String get retry => 'Retry';

  @override
  String get ruleNotFound => 'Pattern not found';

  @override
  String get copiedToClipboard => 'JSON copied to clipboard';

  @override
  String get confirmDelete => 'Confirm Delete';

  @override
  String confirmDeleteRule(String name) {
    return 'Are you sure you want to delete pattern \"$name\"? This action cannot be undone.';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get deleteFailed => 'Delete failed';

  @override
  String get deleteAnnotation => 'Delete Note';

  @override
  String get confirmDeleteAnnotation =>
      'Are you sure you want to delete this note?';

  @override
  String get deleteConditionSet => 'Delete Condition Set';

  @override
  String confirmDeleteConditionSet(String label) {
    return 'Are you sure you want to delete \"$label\"?';
  }

  @override
  String get noSchools => 'No schools';

  @override
  String confirmDeleteSchool(String name) {
    return 'Are you sure you want to delete school \"$name\"?';
  }

  @override
  String get back => 'Back';

  @override
  String get save => 'Save';

  @override
  String get timezoneAutoSet =>
      '• Timezone is automatically set based on location';

  @override
  String get customSchoolSaved => 'Custom school saved';

  @override
  String get configSaved => 'Configuration saved';

  @override
  String saveFailed(String error) {
    return 'Save failed: $error';
  }

  @override
  String generateChartFailed(String error) {
    return 'Chart generation failed: $error';
  }
}
