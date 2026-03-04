/// 数据库Provider

import 'package:flutter/foundation.dart';
import 'package:companion_system/database/drift_database.dart';
import 'package:drift/drift.dart';

class DBProvider extends ChangeNotifier {
  static final DBProvider _instance = DBProvider._internal();
  factory DBProvider() => _instance;

  DBProvider._internal();

  AppDatabase? _database;

  AppDatabase get database {
    _database ??= AppDatabase();
    return _database!;
  }

  Future<void> initialize() async {
    if (_database == null) {
      _database = AppDatabase();
      await _initializeData();
    }
  }

  Future<void> _initializeData() async {
    final db = database;

    // 插入默认分类
    try {
      final existingCategories = await db.select(db.geJuCategories).get();
      if (existingCategories.isEmpty) {
        await db.into(db.geJuCategories).insert(
          GeJuCategoriesCompanion.insert(
            id: 'common',
            name: '通用格局',
            createdAt: DateTime.now(),
          ),
        );
        await db.into(db.geJuCategories).insert(
          GeJuCategoriesCompanion.insert(
            id: 'mutually',
            name: '星曜格局',
            createdAt: DateTime.now(),
          ),
        );
      }
    } catch (e) {
      print('初始化分类时出错: $e');
    }

    // 插入默认流派
    try {
      final existingSchools = await db.select(db.geJuSchools).get();
      if (existingSchools.isEmpty) {
        await db.into(db.geJuSchools).insert(
          GeJuSchoolsCompanion.insert(
            id: 'guo_lao',
            name: '果老星宗',
            type: 'book',
            createdAt: DateTime.now(),
          ),
        );
        await db.into(db.geJuSchools).insert(
          GeJuSchoolsCompanion.insert(
            id: 'custom',
            name: '自定义',
            type: 'custom',
            createdAt: DateTime.now(),
          ),
        );
      }
    } catch (e) {
      print('初始化流派时出错: $e');
    }
  }
}
