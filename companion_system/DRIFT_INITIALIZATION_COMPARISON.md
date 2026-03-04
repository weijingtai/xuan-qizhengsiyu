# Drift 初始化对比：主项目 vs Companion System

## 🔑 核心初始化方式

### 主项目 (xuan-qizhengsiyu)

```dart
// ✅ main.dart - 同步初始化
void main() {
  runApp(MultiProvider(
    providers: [
      Provider<AppDatabase>(
        create: (ctx) => AppDatabase(),  // 直接实例化
        dispose: (ctx, db) => db.close(),
      ),
      // ... 其他 Provider
    ],
    child: const MyApp(),
  ));
}

// ✅ lib/data/datasources/local/app_database.dart
@DriftDatabase(
  tables: [QizhengsiyuPanTable],
  daos: [QiZhengSiYuPanDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e])
      : super(
          e ?? driftDatabase(
            name: 'app_74_database',
            native: const DriftNativeOptions(
              databaseDirectory: getApplicationSupportDirectory,
            ),
            web: DriftWebOptions(
              sqlite3Wasm: Uri.parse('sqlite3.wasm'),
              driftWorker: Uri.parse('drift_worker.js'),
            ),
          ),
        );

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async => await m.createAll(),
      onUpgrade: (Migrator m, int from, int to) async {
        // 升级逻辑
      },
    );
  }
}
```

**特点**:
- 🟢 使用 `driftDatabase()` 跨平台
- 🟢 支持 Web 和 Native
- 🟢 自动处理数据库文件位置
- 🟢 DAO 注解自动生成 accessor

---

### Companion System (当前)

```dart
// ❌ main.dart - 需要改进
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dbProvider = DBProvider();
  await dbProvider.initialize();  // 手动异步初始化

  runApp(MyApp(dbProvider: dbProvider));
}

// ❌ lib/database/drift_database.dart
@DriftDatabase(tables: [
  GeJuPatterns,
  GeJuSchools,
  GeJuRules,
  GeJuVersions,
  GeJuCategories,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());  // LazyDatabase

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration { /* ... */ }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'ge_ju.db'));
    return NativeDatabase.createInBackground(file);
  });
}
```

**问题**:
- 🔴 使用 LazyDatabase（性能稍差）
- 🔴 缺少 DAO 层
- 🔴 main() 需要 async 导致 MyApp 构造复杂化
- 🔴 没有 MigrationStrategy

---

## 📊 关键差异对比

| 特性 | 主项目 | Companion System | 推荐 |
|------|--------|------------------|------|
| 初始化 | `driftDatabase()` | `LazyDatabase()` | 前者更优 |
| 平台 | 跨平台 (Web/Native) | 仅 Native | 基于需要选择 |
| main() | 同步 | 异步 + WidgetsBinding | 保持同步 |
| Provider | MultiProvider | 手动 DBProvider | 用 MultiProvider |
| DAO | 自动注解 `@DriftAccessor` | 缺失 | 必须添加 |
| 迁移策略 | 完整 MigrationStrategy | 无 | 必须添加 |

---

## 🔧 Companion System 改进方案

### 方案 A：完全采用主项目模式（推荐）

**Step 1**: 更新 `lib/database/drift_database.dart`

```dart
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'drift_database.g.dart';

@DriftDatabase(
  tables: [
    GeJuPatterns,
    GeJuSchools,
    GeJuRules,
    GeJuVersions,
    GeJuCategories,
  ],
  daos: [
    GeJuPatternsDao,
    GeJuRulesDao,
    GeJuSchoolsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e])
      : super(
          e ?? driftDatabase(
            name: 'ge_ju_database',
            native: const DriftNativeOptions(
              databaseDirectory: getApplicationSupportDirectory,
            ),
          ),
        );

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // v2: 添加新字段或表
          // await m.addColumn(...);
        }
      },
    );
  }

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

**Step 2**: 创建 DAO 层

```dart
// lib/database/daos/ge_ju_patterns_dao.dart
@DriftAccessor(tables: [GeJuPatterns])
class GeJuPatternsDao extends DatabaseAccessor<AppDatabase>
    with _$GeJuPatternsDaoMixin {
  GeJuPatternsDao(AppDatabase db) : super(db);

  // 插入
  Future<void> insertPattern(Pattern pattern) async {
    await into(geJuPatterns).insert(
      GeJuPatternsCompanion.insert(
        id: pattern.id,
        name: pattern.name,
        englishName: Value(pattern.englishName),
        // ...
      ),
    );
  }

  // 查询所有
  Future<List<Pattern>> getAllPatterns() async {
    return select(geJuPatterns).get();
  }

  // 查询单个
  Future<Pattern?> getPatternById(String id) async {
    return (select(geJuPatterns)..where((p) => p.id.equals(id)))
        .getSingleOrNull();
  }

  // 更新
  Future<void> updatePattern(Pattern pattern) async {
    await update(geJuPatterns).replace(pattern);
  }

  // 删除
  Future<void> deletePattern(String id) async {
    await (delete(geJuPatterns)..where((p) => p.id.equals(id))).go();
  }
}
```

**Step 3**: 更新 `main.dart`

```dart
import 'package:provider/provider.dart';
import 'package:companion_system/database/drift_database.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      Provider<AppDatabase>(
        create: (ctx) => AppDatabase(),
        dispose: (ctx, db) => db.close(),
      ),
      Provider<GeJuPatternsDao>(
        create: (ctx) => GeJuPatternsDao(ctx.read<AppDatabase>()),
      ),
      Provider<GeJuRulesDao>(
        create: (ctx) => GeJuRulesDao(ctx.read<AppDatabase>()),
      ),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});  // 无需 dbProvider 参数

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '七政四余格局数据维护系统',
      home: const MainPage(),
    );
  }
}
```

**Step 4**: 在页面中使用

```dart
class PatternListPage extends StatefulWidget {
  @override
  State<PatternListPage> createState() => _PatternListPageState();
}

class _PatternListPageState extends State<PatternListPage> {
  @override
  Widget build(BuildContext context) {
    final dao = context.read<GeJuPatternsDao>();

    return Scaffold(
      body: FutureBuilder<List<Pattern>>(
        future: dao.getAllPatterns(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView(
              children: snapshot.data!.map((p) => ListTile(
                title: Text(p.name),
              )).toList(),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
```

---

## 🎯 关键要点总结

### ✅ 主项目做对了什么

1. **同步初始化** - main() 不需要 async
2. **Provider 模式** - 依赖注入管理
3. **DAO 层分离** - 业务逻辑与数据库解耦
4. **迁移策略** - 版本管理和升级
5. **跨平台支持** - driftDatabase() 自动适配

### ❌ Companion System 的问题

1. **异步初始化** - 复杂化了启动流程
2. **缺少 DAO** - 直接在 Model 里用 Companion
3. **无迁移策略** - 无法升级数据库结构
4. **DBProvider 多余** - 应该用 Provider 代替

### 🚀 建议行动

1. 采用 **方案 A** (完全采用主项目模式)
2. 创建 **DAO 层** (GeJuPatternsDao 等)
3. 移除 **DBProvider** 改用 **MultiProvider**
4. 添加 **MigrationStrategy**
5. 运行 `flutter pub run build_runner build`

---

## 📁 目录结构对比

### 主项目
```
lib/
  data/
    datasources/
      local/
        app_database.dart      ✅ driftDatabase()
        tables/
          qizhengsiyu_pan_table.dart
        daos/
          qizhengsiyu_pan_dao.dart   ✅ @DriftAccessor
    repositories/
      qizhengsiyu_pan_repository.dart  ✅ 业务层
```

### Companion System (当前)
```
lib/
  database/
    drift_database.dart        ❌ LazyDatabase()
    tables.dart
    migrations/
  providers/
    db_provider.dart           ❌ 多余的包装
```

### 推荐结构
```
lib/
  database/
    drift_database.dart        ✅ driftDatabase()
    tables/
      ge_ju_patterns.dart
      ge_ju_rules.dart
      ...
    daos/                      ✅ 添加 DAO 层
      ge_ju_patterns_dao.dart
      ge_ju_rules_dao.dart
      ...
  services/                    ✅ 业务逻辑层
    pattern_service.dart
    rule_service.dart
```

