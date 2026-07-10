# 2-D 取数报告：GeJu 用户自建数据现状

## 元信息

- 创建日期: 2026-07-09
- 文档类型: 取数报告（逐条回答 SOP Q1–Q6，不做选型）
- 所属阶段: 方向二 2-D（004 周天对齐点拖拽校准 · ③-乙）
- 执行者: OpenCode
- 上游 SOP: `docs/project/tasks/2D-geju-research-sop.md`

---

## 一句话结论

GeJu 用户自建数据**以 Drift SQLite 为主通道**，JSON 文件 (`user_rules.json`) 仅作为旧格式遗留，通过 `GeJuLegacyMigrator` 单向迁移到 Drift 后即被重命名为 `.migrated.bak` 归档。**新建数据的代码全部走 Drift**（GeJuDao + GeJuSchoolService + UserSchoolProfileDao），Web 平台用 stub 跳过 JSON 文件 I/O。

判定依据：`lib/data/datasources/local/app_database.dart:21-32` — `@DriftDatabase(tables: [...], daos: [...])` 注册了 8 张表 + 3 个 DAO；`lib/data/datasources/local/ge_ju_legacy_migrator.dart:19-21` — `GeJuLegacyMigrator` 职责是「旧 JSON → Drift」。

---

## Q1 存储介质：Drift 还是 JSON？

**均为 Drift，JSON 仅存于旧迁移路径。**

### Drift（主线，现行）

- `lib/data/datasources/local/app_database.dart:21-33` — `@DriftDatabase` 注解，注册 8 张表 + 3 个 DAO（`QiZhengSiYuPanDao`、`GeJuDao`、`UserSchoolProfileDao`）
- `lib/data/datasources/local/ge_ju_local_data_source.dart:246-247` — 旧 `GeJuLocalDataSourceImpl` 类标记为 `@Deprecated('Use GeJuBuiltInDataSourceImpl + GeJuDao instead')`

### JSON（旧格式，已废弃但代码保留）

- `lib/data/datasources/local/ge_ju_file_storage_io.dart:5-6` — 文件路径 `{app_documents}/ge_ju/user_rules.json`
- `lib/data/datasources/local/ge_ju_legacy_migrator.dart:19-21` — `GeJuLegacyMigrator` 将旧 JSON 迁移到 Drift 后，重命名旧文件为 `.migrated.bak`
- Web 平台：`ge_ju_file_storage_stub.dart`（无真实文件 I/O），仅在内存缓存

### 并存判定

两条链路**曾经并存**（JSON 为旧格式，Drift 为现行），但**非双写**——迁移是单向的（JSON → Drift），迁移完成后 JSON 被归档。新数据**不走 JSON**。

---

## Q2 Drift 现状

### Q2.1 表结构

#### 格局相关表 (`ge_ju_tables.dart`)

**GeJuRulesTable** (`lib/data/datasources/local/tables/ge_ju_tables.dart:4-21`):

```dart
class GeJuRulesTable extends Table {
  @override
  String get tableName => 't_ge_ju_rules';

  TextColumn get id => text().withLength(min: 1)();
  TextColumn get name => text()();
  TextColumn get aliasesJson => text().withDefault(const Constant('[]')).named('aliases_json')();
  TextColumn get disambiguationNote => text().nullable().named('disambiguation_note')();
  TextColumn get scope => text().withDefault(const Constant('natal'))();
  TextColumn get coordinateSystem => text().nullable().named('coordinate_system')();
  TextColumn get authorType => text().withDefault(const Constant('user')).named('author_type')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column> get primaryKey => {id};
}
```

**其余 5 张 GeJu 表**（同上文件）:
- `GeJuAnnotationsTable`（:24-54）— 注解，含 `ruleId` 外键、`schoolsJson`、`sourceJson`、`description`、`jiXiong`、`createdAt`、`updatedAt`
- `GeJuConditionSetsTable`（:57-81）— 条件组，含 `ruleId`、`label`、`conditionsJson`、`createdAt`、`updatedAt`
- `GeJuUserPreferencesTable`（:84-101）— 单行偏好，含 `hiddenConditionSetIdsJson`、`hiddenAnnotationIdsJson`
- `GeJuSchoolsTable`（:104-116）— 流派，含 `id`、`name`、`brief`、`featuresJson`
- `GeJuDeletionRecordsTable`（:119-132）— 删除审计，含 `deletedEntityType`、`deletedEntityId`、`snapshotJson`

#### 用户自定义流派档案表 (`user_school_profile_table.dart`)

```dart
// lib/data/datasources/local/tables/user_school_profile_table.dart:4-21
class UserSchoolProfileTable extends Table {
  @override
  String get tableName => 't_user_school_profiles';

  TextColumn get uuid => text().withLength(min: 1).named('uuid')();
  TextColumn get name => text().named('name')();
  TextColumn get school => text().named('school')();
  TextColumn get classicBook => text().named('classic_book')();
  TextColumn get panelConfig => text().map(const PanelConfigConverter()).named('panel_config_json')();

  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get lastUpdatedAt => dateTime().named('last_updated_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();

  @override
  Set<Column> get primaryKey => {uuid};
}
```

### Q2.2 DAO 接口形状

**GeJuDao** (`lib/data/datasources/local/daos/ge_ju_dao.dart:29`):

```dart
@DriftAccessor(tables: [GeJuRulesTable, GeJuAnnotationsTable, GeJuConditionSetsTable, ...])
class GeJuDao extends DatabaseAccessor<AppDatabase> with _$GeJuDaoMixin {
  // Rule CRUD
  Future<void> insertRule(GeJuRule rule);
  Future<GeJuRule?> getRuleById(String id);
  Future<List<GeJuRule>> getAllRules();
  Future<void> updateRule(GeJuRule rule);
  Future<void> deleteRule(String id);

  // ConditionSet CRUD
  Future<void> insertConditionSet(GeJuConditionSet cs);
  Future<List<GeJuConditionSet>> getConditionSetsForRule(String ruleId);
  Future<GeJuConditionSet?> getConditionSetById(String id);
  Future<void> updateConditionSet(GeJuConditionSet cs);
  Future<void> deleteConditionSet(String id);
  Future<List<GeJuConditionSet>> getAllConditionSets();

  // Annotation CRUD
  Future<void> insertAnnotation(GeJuAnnotation ann);
  Future<List<GeJuAnnotation>> getAnnotationsForRule(String ruleId);
  Future<GeJuAnnotation?> getAnnotationById(String id);
  Future<void> updateAnnotation(GeJuAnnotation ann);
  Future<void> deleteAnnotation(String id);
  Future<List<GeJuAnnotation>> getAllAnnotations();

  // Schools
  Future<void> insertSchool(GeJuSchool school);
  Future<List<GeJuSchool>> getAllSchools();
  Future<GeJuSchool?> getSchoolById(String id);
  Future<void> updateSchool(GeJuSchool school);
  Future<void> deleteSchool(String id);

  // Preferences
  Future<GeJuUserPreference> getPreference();
  Future<void> savePreference(GeJuUserPreference pref);

  // Deletion
  Future<void> insertDeletionRecord(GeJuDeletionRecord record);
}
```

**UserSchoolProfileDao** (`lib/data/datasources/local/daos/user_school_profile_dao.dart:9-45`):

```dart
@DriftAccessor(tables: [UserSchoolProfileTable])
class UserSchoolProfileDao extends DatabaseAccessor<AppDatabase> with _$UserSchoolProfileDaoMixin {
  Future<void> upsert({required String uuid, required String name, required String school,
      required String classicBook, required BasePanelConfig config});
  Future<List<UserSchoolProfileTableData>> listAll();  // where deletedAt.isNull, orderBy lastUpdatedAt DESC
  Future<void> softDelete(String uuid);  // 设置 deletedAt = now()
}
```

### Q2.3 迁移机制

`lib/data/datasources/local/app_database.dart:67-94`:

```dart
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
        await m.createTable(geJuRulesTable);
        await m.createTable(geJuAnnotationsTable);
        await m.createTable(geJuConditionSetsTable);
        await m.createTable(geJuUserPreferencesTable);
        await m.createTable(geJuDeletionRecordsTable);
      }
      if (from < 3) {
        await m.createTable(geJuSchoolsTable);
      }
      if (from < 4) {
        await m.createTable(userSchoolProfileTable);
      }
    },
  );
}
```

**新增一张 Drift 表的操作清单**:
1. 在 `lib/data/datasources/local/tables/` 下新建 table 类（`extends Table`）
2. 在 `app_database.dart` 的 `@DriftDatabase(tables: [...])` 中注册
3. 在 `app_database.dart` 的 `MigrationStrategy.onUpgrade` 中，为 **下一版** schemaVersion 添加 `await m.createTable(yourNewTable);`
4. **bump `schemaVersion`**

### Q2.4 单例/连接装配

`lib/data/datasources/local/database_provider.dart:3-10`:

```dart
class DatabaseProvider {
  static AppDatabase? _database;
  static AppDatabase get database {
    _database ??= AppDatabase();
    return _database!;
  }
}
```

`AppDatabase` 自身也是单例（`lib/data/datasources/local/app_database.dart:58-61`）:

```dart
static AppDatabase? _instance;
factory AppDatabase() => _instance ??= AppDatabase._();
```

数据库名: `app_74_database`（:39），存放于 `getApplicationSupportDirectory()`。Web 平台通过 `DriftWebOptions(sqlite3Wasm: ..., driftWorker: ...)` 支持（:43-55）。

---

## Q3 JSON 现状

### Q3.1 文件路径模式

`lib/data/datasources/local/ge_ju_file_storage_io.dart:5-33`:

```dart
const String _userRulesDirName = 'ge_ju';
const String _userRulesFileName = 'user_rules.json';

Future<String> getUserRulesFilePath() async {
  final directory = await getApplicationDocumentsDirectory();
  return '${directory.path}/$_userRulesDirName/$_userRulesFileName';
}
```

完整路径: `{app_documents}/ge_ju/user_rules.json`

### Q3.2 读写接口

```dart
Future<String?> readUserRulesFile() async { ... file.readAsString(); }
Future<void> writeUserRulesFile(String content) async { ... file.writeAsString(content, flush: true); }
Future<bool> userRulesFileExists() async { ... File(filePath).exists(); }
```

Web 平台 (`ge_ju_file_storage_stub.dart`): 无文件 I/O，使用内存 `String?` 模拟。

### Q3.3 命名约定

- 旧格式：`user_rules.json`（文件名固定，不按 UUID 拆分）
- 迁移时只迁移 `id.startsWith('user_')` 的规则（`ge_ju_legacy_migrator.dart:70`）
- 迁移后重命名为 `user_rules.json.migrated.bak`（`ge_ju_legacy_migrator_io.dart`）
- 内置数据与用户数据区分：**JSON 文件只存用户数据**，内置数据从 assets bundle 加载

---

## Q4 上层 CRUD 接口签名

### Q4.1 GeJuCrudService（核心 CRUD 门面）

`lib/domain/services/ge_ju_crud_service.dart:21`:

```dart
class GeJuCrudService {
  static const _uuid = Uuid();

  // Rule
  Future<GeJuRule> createRule(GeJuRuleCreateParams params);       // id: 'user_${_uuid.v4()}'
  Future<GeJuRule?> getRule(String id);
  Future<List<GeJuRule>> getAllRules();
  Future<void> updateRule(GeJuRule rule);
  Future<void> deleteRule(String id);

  // ConditionSet
  Future<GeJuConditionSet> createConditionSet(ConditionSetCreateParams params);  // id: 'user_${_uuid.v4()}'
  Future<List<GeJuConditionSet>> getConditionSetsForRule(String ruleId);
  Future<GeJuConditionSet?> getConditionSetById(String id);
  Future<void> updateConditionSet(GeJuConditionSet cs);
  Future<void> deleteConditionSet(String id);
  Future<GeJuConditionSet> forkConditionSet(String originalId);

  // Annotation
  Future<GeJuAnnotation> createAnnotation(AnnotationCreateParams params);  // id: 'user_${_uuid.v4()}'
  Future<List<GeJuAnnotation>> getAnnotationsForRule(String ruleId);
  Future<void> updateAnnotation(GeJuAnnotation ann);
  Future<void> deleteAnnotation(String id);

  // Compound
  Future<GeJuRule> duplicateRule(String ruleId);
  Future<GeJuRule> saveRuleAs(GeJuRuleSaveAsParams params);

  // Preference
  Future<GeJuUserPreference> getPreference();
  Future<void> savePreference(GeJuUserPreference pref);

  // Query
  Future<List<GeJuRule>> searchRules(String keyword);
  bool isBuiltInRule(String ruleId);
  void clearCache();
}
```

**UUID 生成模式** (`ge_ju_crud_service.dart`): 所有新建实体 ID 均为 `'user_${_uuid.v4()}'`，共 9 处。

### Q4.2 GeJuProductRepository（Domain 抽象层）

`lib/domain/repositories/ge_ju_product_repository.dart:9`:

```dart
abstract class GeJuProductRepository {
  Future<List<GeJuRule>> loadAllRules();
  Future<GeJuRule?> getRuleById(String id);
  Future<void> saveUserRule(GeJuRule rule);
  Future<void> deleteUserRule(String id);
  bool isBuiltInRule(String ruleId);

  Future<List<GeJuConditionSet>> getConditionSetsForRule(String ruleId);
  Future<void> saveUserConditionSet(GeJuConditionSet cs);
  Future<void> deleteUserConditionSet(String id);

  Future<List<GeJuAnnotation>> getAnnotationsForRule(String ruleId);
  Future<void> saveUserAnnotation(GeJuAnnotation ann);
  Future<void> deleteUserAnnotation(String id);

  Future<void> recordDeletion(Map<String, dynamic> record);
  void clearCache();
}
```

### Q4.3 GeJuSchoolService

`lib/data/datasources/local/services/ge_ju_school_service.dart:7`:

```dart
class GeJuSchoolService implements GeJuSchoolServicePort {
  static const _uuid = Uuid();
  Future<List<GeJuSchoolContract>> getAllSchools();
  Future<GeJuSchoolContract?> getSchoolById(String id);
  Future<GeJuSchoolContract> createSchool({required String name, String? brief, List<String> features});  // id: 'user_school_${_uuid.v4()}'
  Future<void> updateSchool(GeJuSchoolContract contract);
  Future<void> deleteSchool(String id);
}
```

**注意**: `GeJuSchoolService` 使用 `user_school_` 前缀（不是 `user_`），区别于 `GeJuCrudService` 的 `user_` 前缀。

### Q4.4 UserSchoolProfileService

`lib/data/services/user_school_profile_service.dart:7`:

```dart
class UserSchoolProfileService implements UserSchoolProfileServicePort {
  Future<String> saveCurrentAsProfile({required String name, required EnumSchoolType school,
      required String classicBook, required BasePanelConfig config});  // id: 'user_${const Uuid().v4()}'
  Future<List<SavedSchoolProfile>> listAll();
  Future<void> delete(String uuid);  // soft delete
}
```

---

## Q5 `user_school_profile` 参照样本

### 表结构

`lib/data/datasources/local/tables/user_school_profile_table.dart:4-21`:

| 列 | 类型 | 约束 | 说明 |
|---|---|---|---|
| `uuid` | TextColumn | PK, min:1 | 主键，`user_<uuid>` |
| `name` | TextColumn | | 档案名称 |
| `school` | TextColumn | | 流派枚举名 |
| `classic_book` | TextColumn | | 经典典籍引用 |
| `panel_config_json` | TextColumn | PanelConfigConverter | 完整排盘配置（JSON） |
| `created_at` | DateTimeColumn | | 创建时间 |
| `last_updated_at` | DateTimeColumn | | 最后更新时间 |
| `deleted_at` | DateTimeColumn | nullable | 软删除标记 |

### DAO

`lib/data/datasources/local/daos/user_school_profile_dao.dart:9-45`:

```dart
// upsert: 插入或更新（insertOnConflictUpdate）
// listAll: 仅返回 deletedAt 为空的行，按 lastUpdatedAt 降序
// softDelete: 设 deletedAt = now()
```

### 与 2-D 候选对齐点场景的对比（事实描述，不下结论）

| 维度 | GeJu Rule | user_school_profile | 2-D 候选对齐点 |
|---|---|---|---|
| 字段复杂度 | 高（8+ 字段，含 JSON 子字段） | **低**（7 字段，一条独立记录） | **极低**（候选名称 + ConstellationDegree + 时间 + 备注 = 4 核心字段） |
| 是否需要外键 | 是（ruleId 关联 annotation/conditionSet） | **否**（独立记录） | **否**（独立候选点，无需外键） |
| 是否有 CRUD 方法 | create/read/update/delete 完整 | **upsert/list/softDelete** | 需要 create/list/delete |
| 是否有软删除 | 有（DeletionRecords 表） | **有**（deletedAt 字段） | 可能需要 |
| ID 命名 | `user_<uuid>` | `user_<uuid>` | 应复用 `user_<uuid>` |
| UUID 来源 | `Uuid().v4()` | `Uuid().v4()` | 应复用 `Uuid().v4()` |

**`user_school_profile` 在「一条轻量命名记录」这个维度上，比 GeJu Rule（含三实体级联）更接近 2-D 候选对齐点场景。** 但 `user_school_profile` 存储的是 `BasePanelConfig`（完整 JSON 序列化），而候选对齐点需存 `ConstellationDegree` + 备注文本 —— 字段更扁平。

---

## Q6 字段命名对照小结

| 语义 | GeJu Rules 表 | UserSchoolProfile 表 | GeJu Schools 表 | 2-D 候选对齐点建议对齐 |
|---|---|---|---|---|
| **主键** | `id` (TextColumn) | `uuid` (TextColumn) | `id` (TextColumn) | `id` 或 `uuid`（TextColumn） |
| **显示名称** | `name` | `name` | `name` | `name` |
| **创建时间** | `created_at` (DateTimeColumn) | `created_at` (DateTimeColumn) | 无 | `created_at` (DateTimeColumn) |
| **更新时间** | `updated_at` | `last_updated_at` | 无 | `updated_at` |
| **作者/来源类型** | `author_type` | 无（仅存用户数据） | 无 | `author_type`（如需要区分用户/内置） |
| **备注/来源文本** | `disambiguation_note` | `classic_book` | `brief` | `source_note`（自由文本字段） |
| **内容体（JSON）** | `aliases_json`、`conditions_json` 等 | `panel_config_json` | `features_json` | `alignment_point_json`（序列化 `ConstellationDegree`） |

**命名规律总结**：
- 时间字段：`created_at`、`updated_at`（snake_case，下划线分隔）
- 备注类字段：`disambiguation_note`、`classic_book`、`change_note` → 风格为 `<作用>_note` 或 `<主语>_book`
- JSON 类字段：`aliases_json`、`conditions_json`、`features_json`、`panel_config_json` → 后缀 `_json`
- 主键风格不统一：`id`（GeJu 大部分表）vs `uuid`（UserSchoolProfile）

---

## 搜索足迹

### 精确打开并通读的文件

| 文件 | 行数 |
|---|---|
| `lib/data/datasources/local/app_database.dart` | 105 |
| `lib/data/datasources/local/database_provider.dart` | 28 |
| `lib/data/datasources/local/tables/ge_ju_tables.dart` | 132 |
| `lib/data/datasources/local/tables/user_school_profile_table.dart` | 21 |
| `lib/data/datasources/local/daos/ge_ju_dao.dart` | 522 |
| `lib/data/datasources/local/daos/user_school_profile_dao.dart` | 45 |
| `lib/data/datasources/local/ge_ju_sqlite_data_source.dart` | 140 |
| `lib/data/datasources/local/ge_ju_file_storage_io.dart` | 39 |
| `lib/data/datasources/local/ge_ju_legacy_migrator.dart` | 195 |
| `lib/data/datasources/local/ge_ju_local_data_source.dart` | 323 |
| `lib/domain/repositories/ge_ju_product_repository.dart` | ~60 |
| `lib/domain/repositories/ge_ju_repository_adapter.dart` | ~170 |
| `lib/domain/services/ge_ju_crud_service.dart` | ~460 |
| `lib/data/datasources/local/services/ge_ju_school_service.dart` | ~90 |
| `lib/data/services/user_school_profile_service.dart` | ~45 |
| `lib/domain/services/user_school_profile_service_port.dart` | ~30 |

### 跑过的 grep 命令

```bash
grep -rn "user_" lib/ --include='*.dart' | grep -iv '\.g\.dart' | grep -iE "user_rules|user_school|'user_|\"user_|isUserCreated|isBuiltIn|authorType"
grep -rn "extends Table" lib/data --include='*.dart' | grep -v '\.g\.dart'
grep -rn "schemaVersion\|onUpgrade\|MigrationStrategy" lib/data --include='*.dart' | grep -iv '\.g\.dart'
```

---

## 未决 / 未找到

- 无。SOP 要求的 Q1–Q6 均已找到对应代码证据。
- `IGeJuRepository`（外部包接口）不在 worktree 可见范围内，确切定义在 `repository-interface-qizhengsiyu` 外部包中。本报告以 `GeJuProductRepository`（domain 层抽象）和 `GeJuRepositoryAdapter`（适配器实现）为权威来源。
