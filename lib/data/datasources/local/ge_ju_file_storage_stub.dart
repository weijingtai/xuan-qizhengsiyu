/// Web stub for file storage operations
/// These functions are never called on web (guarded by kIsWeb)

Future<String?> readUserRulesFile() async {
  throw UnsupportedError('File storage not supported on web');
}

Future<void> writeUserRulesFile(String content) async {
  throw UnsupportedError('File storage not supported on web');
}

Future<String> getUserRulesFilePath() async {
  return '';
}

Future<bool> userRulesFileExists() async {
  return false;
}
