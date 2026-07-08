import 'dart:convert';
import 'dart:io';

Future<List<Map<String, dynamic>>> loadUserSchemesFromFiles() async {
  final userSchemesDir = Directory('user_schemes');
  if (!await userSchemesDir.exists()) {
    return [];
  }

  final List<Map<String, dynamic>> results = [];
  final List<FileSystemEntity> entities = await userSchemesDir.list().toList();
  for (var entity in entities) {
    if (entity is File && entity.path.endsWith('.json')) {
      final String content = await entity.readAsString();
      final model = json.decode(content);
      results.add(model as Map<String, dynamic>);
    }
  }
  return results;
}
