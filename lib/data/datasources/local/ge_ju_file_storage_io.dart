import 'dart:io';

import 'package:path_provider/path_provider.dart';

const String _userRulesDirName = 'ge_ju';
const String _userRulesFileName = 'user_rules.json';

Future<String?> readUserRulesFile() async {
  final filePath = await getUserRulesFilePath();
  final file = File(filePath);

  if (!await file.exists()) {
    return null;
  }

  return file.readAsString();
}

Future<void> writeUserRulesFile(String content) async {
  final filePath = await getUserRulesFilePath();
  final file = File(filePath);

  final directory = file.parent;
  if (!await directory.exists()) {
    await directory.create(recursive: true);
  }

  await file.writeAsString(content, flush: true);
}

Future<String> getUserRulesFilePath() async {
  final directory = await getApplicationDocumentsDirectory();
  return '${directory.path}/$_userRulesDirName/$_userRulesFileName';
}

Future<bool> userRulesFileExists() async {
  final filePath = await getUserRulesFilePath();
  return File(filePath).exists();
}
