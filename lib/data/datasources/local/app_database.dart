import 'package:metaphysics_core/models/divination_datetime.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../../../domain/entities/models/base_panel_model.dart';
import '../../../domain/entities/models/pan_entity.dart';
import '../../../domain/entities/models/panel_config.dart';
import 'daos/qizhengsiyu_pan_dao.dart';
import 'daos/ge_ju_dao.dart';
import 'daos/user_school_profile_dao.dart';
import 'tables/qizhengsiyu_pan_table.dart';
import 'tables/ge_ju_tables.dart';
import 'tables/user_school_profile_table.dart';
import '../../models/converters/divination_datetime_converter.dart';
import '../../models/converters/panel_config_converter.dart';
import '../../models/converters/panel_model_converter.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    QizhengsiyuPanTable,
    GeJuRulesTable,
    GeJuAnnotationsTable,
    GeJuConditionSetsTable,
    GeJuUserPreferencesTable,
    GeJuDeletionRecordsTable,
    GeJuSchoolsTable,
    UserSchoolProfileTable,
  ],
  daos: [QiZhengSiYuPanDao, GeJuDao, UserSchoolProfileDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase._([QueryExecutor? e])
      : super(
          e ??
              driftDatabase(
                name: 'app_74_database',
                native: const DriftNativeOptions(
                  databaseDirectory: getApplicationSupportDirectory,
                ),
                web: DriftWebOptions(
                  sqlite3Wasm: Uri.parse('sqlite3.wasm'),
                  driftWorker: Uri.parse('drift_worker.js'),
                  onResult: (result) {
                    if (result.missingFeatures.isNotEmpty) {
                      print(
                        'Using ${result.chosenImplementation} due to unsupported '
                        'browser features: ${result.missingFeatures}',
                      );
                    }
                  },
                ),
              ),
        );

  static AppDatabase? _instance;

  /// 单例访问（同一个数据库文件只能打开一次）
  factory AppDatabase() => _instance ??= AppDatabase._();

  /// 仅用于测试：注入自定义 QueryExecutor
  factory AppDatabase.forTesting(QueryExecutor e) => AppDatabase._(e);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // v2: Add GeJu tables
          await m.createTable(geJuRulesTable);
          await m.createTable(geJuAnnotationsTable);
          await m.createTable(geJuConditionSetsTable);
          await m.createTable(geJuUserPreferencesTable);
          await m.createTable(geJuDeletionRecordsTable);
        }
        if (from < 3) {
          // v3: Add GeJu Schools table
          await m.createTable(geJuSchoolsTable);
        }
        if (from < 4) {
          // v4: 用户自定义流派档案表
          await m.createTable(userSchoolProfileTable);
        }
      },
    );
  }

  // 数据库健康检查
  Future<bool> isDatabaseHealthy() async {
    try {
      await customSelect('SELECT 1').getSingle();
      return true;
    } catch (e) {
      return false;
    }
  }
}
