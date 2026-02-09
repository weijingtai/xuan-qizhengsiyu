/// Web stub for legacy migrator file operations
/// These functions are never called on web (guarded by kIsWeb)

Future<void> markUserRulesAsMigrated() async {
  throw UnsupportedError('File operations not supported on web');
}
