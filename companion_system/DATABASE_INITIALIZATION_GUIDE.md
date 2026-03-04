# Drift & SQLite3 数据库初始化指南

## 📋 主项目 (xuan-qizhengsiyu) 的初始化方式

### 1. 架构层次

```
main.dart (应用入口)
    ↓
Provider<AppDatabase> (全局数据库实例)
    ↓
AppDatabase extends _$AppDatabase (Drift数据库类)
    ↓
DriftDatabase 初始化 (driftDatabase函数)
    ↓
QiZhengSiYuPanRepository (数据访问层)
    ↓
QiZhengSiYuPanDao (数据库访问对象)
    ↓
QizhengsiyuPanTable (数据库表定义)
```

### 2. 初始化步骤详解

#### Step 1: main.dart 中的 Provider 设置

```dart
void main() {
  runApp(MultiProvider(
    providers: [
      // 创建 AppDatabase 单例
      Provider<AppDatabase>(
        create: (ctx) => AppDatabase(),  // 立即创建，无需 async
        dispose: (ctx, db) => db.close(),  // 关闭时清理资源
      ),
      // 基于 AppDatabase 创建 Repository
      Provider<IQiZhengSiYuPanRepository>(
        create: (ctx) => QiZhengSiYuPanRepository(
          appDatabase: ctx.read<AppDatabase>(),
        ),
      ),
      // 基于 Repository 创建 UseCase
      Provider<SaveCalculatedPanelUseCase>(
        create: (ctx) => SaveCalculatedPanelUseCase(
          qiZhengSiYuPanRepository: ctx.read<IQiZhengSiYuPanRepository>()
        )
      ),
    ],
    child: const MyApp(),
  ));
}
```

**特点**:
- ✅ 同步初始化（无 async/await）
- ✅ Provider 管理生命周期
- ✅ 支持依赖注入链

#### Step 2: AppDatabase 的初始化

**位置**: `lib/data/datasources/local/app_database.dart`

```dart
@DriftDatabase(
  tables: [QizhengsiyuPanTable],
  daos: [QiZhengSiYuPanDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e])
      : super(
          e ??
              driftDatabase(
                name: 'app_74_database',
                // 原生平台配置
                native: const DriftNativeOptions(
                  databaseDirectory: getApplicationSupportDirectory,
                ),
                // Web 平台配置
                web: DriftWebOptions(
                  sqlite3Wasm: Uri.parse('sqlite3.wasm'),
                  driftWorker: Uri.parse('drift_worker.js'),
                  onResult: (result) {
                    if (result.missingFeatures.isNotEmpty) {
                      print('Using ${result.chosenImplementation}...');
                    }
                  },
                ),
              ),
        );

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();  // 首次创建所有表
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // 处理版本升级
        if (from < 2) {
          // await m.addColumn(...);
        }
      },
    );
  }

  // 健康检查方法
  Future<bool> isDatabaseHealthy() async {
    try {
      await customSelect('SELECT 1').getSingle();
      return true;
    } catch (e) {
      return false;
    }
  }
}
```

**关键特性**:
- 🔑 `driftDatabase()` 自动处理平台差异
- 🔑 `native: DriftNativeOptions` 配置 SQLite 位置
- 🔑 `schemaVersion` 管理数据库版本
- 🔑 `MigrationStrategy` 处理数据库迁移
- 🔑 `isDatabaseHealthy()` 健康检查

#### Step 3: 表定义

**位置**: `lib/data/datasources/local/tables/qizhengsiyu_pan_table.dart`

```dart
@UseRowClass(QiZhengSiYuPanEntity)
class QizhengsiyuPanTable extends Table {
  @override
  String get tableName => "t_qizhengsiyu_pans";

  // 基础字段
  TextColumn get uuid => text().withLength(min: 1).named('uuid')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get lastUpdatedAt => dateTime().named('last_updated_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();

  // 关联字段
  TextColumn get divinationRequestInfoUuid =>
      text().named('divination_request_info_uuid')();

  // 使用 Converter 存储复杂对象
  TextColumn get panelConfig =>
      text().map(const PanelConfigConverter()).named('panel_config_json')();

  TextColumn get panelModel =>
      text().map(const BasePanelModelConverter()).named('panel_data_json')();

  TextColumn get divinationDatetimeModel => text()
      .map(const DivinationDatetimeConverter())
      .named('divination_datetime_json')();

  @override
  Set<Column> get primaryKey => {uuid};
}
```

**设计特点**:
- ✅ `@UseRowClass` 直接映射到实体类
- ✅ `.map(const Converter())` 处理 JSON 序列化
- ✅ 自定义列名与数据库表一致
- ✅ 支持软删除 (`deletedAt` 字段)

#### Step 4: DAO 层 (数据访问对象)

**位置**: `lib/data/datasources/local/daos/qizhengsiyu_pan_dao.dart`

```dart
@DriftAccessor(tables: [QizhengsiyuPanTable])
class QiZhengSiYuPanDao extends DatabaseAccessor<AppDatabase>
    with _$QiZhengSiYuPanDaoMixin {
  QiZhengSiYuPanDao(AppDatabase db) : super(db);

  // 插入数据
  Future<void> insertPan(QiZhengSiYuPanEntity entity) async {
    await into(qizhengsiyuPanTable).insert(
      QizhengsiyuPanTableCompanion.insert(
        uuid: entity.uuid,
        divinationRequestInfoUuid: entity.divinationRequestInfoUuid,
        createdAt: entity.createdAt,
        lastUpdatedAt: entity.lastUpdatedAt,
        deletedAt: Value(entity.deletedAt),
        panelModel: entity.panelModel,
        panelConfig: entity.panelConfig,
        divinationDatetimeModel: entity.divinationDatetimeModel,
      ),
    );
  }

  // 查询单条
  Future<QiZhengSiYuPanEntity?> getPanByUuid(String uuid) async {
    final query = select(qizhengsiyuPanTable)
      ..where((tbl) => tbl.uuid.equals(uuid));
    return await query.getSingleOrNull();
  }

  // 查询所有活跃数据
  Future<List<QiZhengSiYuPanEntity>> getAllActivePans() async {
    final query = select(qizhengsiyuPanTable)
      ..where((tbl) => tbl.deletedAt.isNull())
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]);
    return await query.get();
  }

  // 更新数据
  Future<void> updatePan(QiZhengSiYuPanEntity entity) async {
    await (update(qizhengsiyuPanTable)
          ..where((tbl) => tbl.uuid.equals(entity.uuid)))
        .write(QizhengsiyuPanTableCompanion(
          lastUpdatedAt: Value(entity.lastUpdatedAt),
          panelModel: Value(entity.panelModel),
          panelConfig: Value(entity.panelConfig),
          divinationDatetimeModel: Value(entity.divinationDatetimeModel),
        ));
  }

  // 软删除
  Future<void> softDeletePan(String uuid) async {
    await (update(qizhengsiyuPanTable)
          ..where((tbl) => tbl.uuid.equals(uuid)))
        .write(QizhengsiyuPanTableCompanion(
          deletedAt: Value(DateTime.now()),
        ));
  }

  // 永久删除
  Future<void> deletePan(String uuid) async {
    await (delete(qizhengsiyuPanTable)
          ..where((tbl) => tbl.uuid.equals(uuid)))
        .go();
  }
}
```

**DAO 职责**:
- 🎯 数据库操作的具体实现
- 🎯 提供类型安全的 CRUD 方法
- 🎯 支持复杂查询和事务

#### Step 5: Repository 层

**位置**: `lib/data/repositories/qizhengsiyu_pan_repository.dart`

```dart
class QiZhengSiYuPanRepository extends IQiZhengSiYuPanRepository {
  QiZhengSiYuPanDao get _localStorage => _appDatabase.qiZhengSiYuPanDao;
  late final AppDatabase _appDatabase;

  QiZhengSiYuPanRepository({required AppDatabase appDatabase}) {
    _appDatabase = appDatabase;
  }

  /// 保存盘数据
  Future<void> save(QiZhengSiYuPanEntity entity) async {
    try {
      await _localStorage.insertPan(entity);
    } catch (e) {
      throw RepositoryException('保存盘数据失败: $e');
    }
  }

  /// 查询单条
  Future<QiZhengSiYuPanEntity?> findByUuid(String uuid) async {
    try {
      return await _localStorage.getPanByUuid(uuid);
    } catch (e) {
      throw RepositoryException('获取盘数据失败: $e');
    }
  }

  /// 更新数据
  Future<void> update(QiZhengSiYuPanEntity entity) async {
    try {
      await _localStorage.updatePan(entity);
    } catch (e) {
      throw RepositoryException('更新盘数据失败: $e');
    }
  }

  /// 软删除
  Future<void> delete(String uuid) async {
    try {
      await _localStorage.softDeletePan(uuid);
    } catch (e) {
      throw RepositoryException('删除盘数据失败: $e');
    }
  }
}
```

**Repository 职责**:
- 🎯 业务逻辑包装
- 🎯 异常处理和转换
- 🎯 多个 DAO 的协调

---

## 🔧 Companion System 应该采用的初始化方式

### 推荐方案：基于主项目的改进版

```dart
// 1. main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MultiProvider(
    providers: [
      // 创建数据库实例
      Provider<AppDatabase>(
        create: (ctx) => AppDatabase(),
        dispose: (ctx, db) => db.close(),
      ),
      // 基于数据库创建各个 DAO
      Provider<GeJuPatternsDao>(
        create: (ctx) => GeJuPatternsDao(ctx.read<AppDatabase>()),
      ),
      Provider<GeJuRulesDao>(
        create: (ctx) => GeJuRulesDao(ctx.read<AppDatabase>()),
      ),
      // 创建 Service 层
      Provider<PatternService>(
        create: (ctx) => PatternService(ctx.read<GeJuPatternsDao>()),
      ),
      Provider<RuleService>(
        create: (ctx) => RuleService(ctx.read<GeJuRulesDao>()),
      ),
    ],
    child: MyApp(),
  ));
}

// 2. lib/database/drift_database.dart
@DriftDatabase(tables: [
  GeJuPatterns,
  GeJuSchools,
  GeJuRules,
  GeJuVersions,
  GeJuCategories,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // 处理升级逻辑
        if (from < 2) {
          // 添加新表或字段
        }
      },
    );
  }

  // 健康检查
  Future<bool> isDatabaseHealthy() async {
    try {
      await customSelect('SELECT 1').getSingle();
      return true;
    } catch (e) {
      print('Database health check failed: $e');
      return false;
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'ge_ju.db'));
    return NativeDatabase.createInBackground(file);
  });
}

// 3. lib/database/daos/ge_ju_patterns_dao.dart
@DriftAccessor(tables: [GeJuPatterns])
class GeJuPatternsDao extends DatabaseAccessor<AppDatabase>
    with _$GeJuPatternsDaoMixin {
  GeJuPatternsDao(AppDatabase db) : super(db);

  Future<void> insertPattern(Pattern pattern) async {
    await into(geJuPatterns).insert(
      GeJuPatternsCompanion.insert(
        id: pattern.id,
        name: pattern.name,
        englishName: Value(pattern.englishName),
        pinyin: Value(pattern.pinyin),
        // ... 其他字段
      ),
    );
  }

  Future<List<Pattern>> getAllPatterns() async {
    return select(geJuPatterns).get();
  }

  Future<Pattern?> getPatternById(String id) async {
    return (select(geJuPatterns)..where((p) => p.id.equals(id)))
        .getSingleOrNull();
  }

  Future<void> updatePattern(Pattern pattern) async {
    await update(geJuPatterns).replace(pattern);
  }

  Future<void> deletePattern(String id) async {
    await (delete(geJuPatterns)..where((p) => p.id.equals(id))).go();
  }
}

// 4. lib/services/pattern_service.dart
class PatternService {
  final GeJuPatternsDao _dao;

  PatternService(this._dao);

  Future<List<Pattern>> fetchAllPatterns() async {
    try {
      return await _dao.getAllPatterns();
    } catch (e) {
      throw ServiceException('Failed to fetch patterns: $e');
    }
  }

  Future<void> savePattern(Pattern pattern) async {
    try {
      final existing = await _dao.getPatternById(pattern.id);
      if (existing != null) {
        await _dao.updatePattern(pattern);
      } else {
        await _dao.insertPattern(pattern);
      }
    } catch (e) {
      throw ServiceException('Failed to save pattern: $e');
    }
  }
}
```

---

## 📊 初始化对比表

| 方面 | 主项目 (xuan-qizhengsiyu) | Companion System (推荐) |
|------|---------------------------|----------------------|
| 初始化方式 | 同步 (synchronous) | 同步 (synchronous) |
| Provider 使用 | MultiProvider 依赖注入 | 同左 |
| 数据库初始化 | driftDatabase() | LazyDatabase() |
| 平台支持 | Web + Native | Native only |
| DAO 模式 | 使用 @DriftAccessor | 同左 |
| 表定义 | @UseRowClass 映射 | GeJuPatternsCompanion 映射 |
| 软删除支持 | 有 (deletedAt 字段) | 可选 |
| 迁移策略 | MigrationStrategy | 同左 |
| 健康检查 | isDatabaseHealthy() | 可选 |

---

## 🚀 实施步骤

### 1. 创建 DAO 文件

```bash
lib/
  database/
    daos/
      ge_ju_patterns_dao.dart
      ge_ju_schools_dao.dart
      ge_ju_rules_dao.dart
      ge_ju_categories_dao.dart
      ge_ju_versions_dao.dart
```

### 2. 更新 AppDatabase

```dart
@DriftDatabase(tables: [...], daos: [...])
class AppDatabase extends _$AppDatabase {
  // 声明 DAO 访问器
  late final geJuPatternsDao = GeJuPatternsDao(this);
  late final geJuRulesDao = GeJuRulesDao(this);
  // ...
}
```

### 3. 生成代码

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. 创建 Service 层

```bash
lib/
  services/
    pattern_service.dart
    rule_service.dart
    school_service.dart
```

### 5. 更新 main.dart

按上述推荐方案使用 MultiProvider 注入

---

## ✅ 验证清单

- [ ] 运行 `flutter analyze` 无错误
- [ ] 运行 `flutter test` 通过
- [ ] 数据库成功创建
- [ ] CRUD 操作正常
- [ ] 迁移逻辑正确
- [ ] 多数据库并发访问安全

