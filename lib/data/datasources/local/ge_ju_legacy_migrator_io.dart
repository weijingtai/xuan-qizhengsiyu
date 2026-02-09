import 'dart:io';

import 'package:path_provider/path_provider.dart';

const String _userRulesDirName = 'ge_ju';
const String _userRulesFileName = 'user_rules.json';
const String _migratedSuffix = '.migrated.bak';

/// 将旧用户规则文件重命名为备份文件
Future<void> markUserRulesAsMigrated() async {
  final directory = await getApplicationDocumentsDirectory();
  final filePath = '${directory.path}/$_userRulesDirName/$_userRulesFileName';
  final file = File(filePath);

  if (await file.exists()) {
    final backupPath = '$filePath$_migratedSuffix';
    await file.rename(backupPath);
  }
}
