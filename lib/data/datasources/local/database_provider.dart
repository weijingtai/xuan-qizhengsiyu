import 'app_database.dart';

class DatabaseProvider {
  static AppDatabase? _database;
  
  static AppDatabase get database {
    _database ??= AppDatabase();
    return _database!;
  }
  
  static Future<void> closeDatabase() async {
    await _database?.close();
    _database = null;
  }
  
  static Future<void> resetDatabase() async {
    await closeDatabase();
    // 可以在这里删除数据库文件进行完全重置
  }
  
  static Future<bool> isDatabaseReady() async {
    try {
      return await database.isDatabaseHealthy();
    } catch (e) {
      return false;
    }
  }
}