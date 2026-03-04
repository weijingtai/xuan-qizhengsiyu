# ✅ Companion System - Drift 初始化修复指南

## 🎯 目标

将 Companion System 从 **仅支持原生** 改为 **跨平台支持**（与主项目一致）

---

## 📋 修复清单

- [ ] **Step 1**: 更新依赖 (pubspec.yaml)
- [ ] **Step 2**: 修改 AppDatabase (drift_database.dart)
- [ ] **Step 3**: 更新 main.dart
- [ ] **Step 4**: 删除旧的初始化代码 (DBProvider)
- [ ] **Step 5**: 测试验证

---

## 🔧 详细修复步骤

### Step 1: 更新依赖

**当前状态**:
```yaml
dependencies:
  drift: ^2.30.1
  sqlite3_flutter_libs: ^0.5.41
```

**修复后**:
```yaml
dependencies:
  drift: ^2.30.1
  drift_flutter: ^2.30.1  # ✅ 添加这行！
  sqlite3_flutter_libs: ^0.5.41
```

**说明**:
- `drift_flutter` 包含 `driftDatabase()` 函数
- 它提供跨平台的数据库初始化

**命令**:
```bash
cd companion_system
flutter pub add drift_flutter:^2.30.1
```

---

### Step 2: 修改 AppDatabase

**文件**: `lib/database/drift_database.dart`

**当前代码** ❌:
```dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables.dart';

part 'drift_database.g.dart';

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
        // 升级逻辑
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'ge_ju.db'));
    return NativeDatabase.createInBackground(file);
  });
}
```

**修复后代码** ✅:
```dart
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'tables.dart';

part 'drift_database.g.dart';

@DriftDatabase(
  tables: [
    GeJuPatterns,
    GeJuSchools,
    GeJuRules,
    GeJuVersions,
    GeJuCategories,
  ],
)
class AppDatabase extends _$AppDatabase {
  // ✅ 改为：支持可选的 QueryExecutor
  AppDatabase([QueryExecutor? e])
      : super(
          e ??
              driftDatabase(
                name: 'ge_ju_database',
                // 原生平台配置
                native: const DriftNativeOptions(
                  databaseDirectory: getApplicationSupportDirectory,
                ),
                // Web 平台配置（可选，未来使用）
                web: DriftWebOptions(
                  sqlite3Wasm: Uri.parse('sqlite3.wasm'),
                  driftWorker: Uri.parse('drift_worker.js'),
                  onResult: (result) {
                    if (result.missingFeatures.isNotEmpty) {
                      print(
                        'Using ${result.chosenImplementation} due to '
                        'unsupported browser features: ${result.missingFeatures}',
                      );
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
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // 处理数据库升级
        if (from < 2) {
          // 示例：添加新字段的迁移
          // await m.addColumn(geJuRulesTable, geJuRulesTable.newField);
        }
      },
    );
  }

  // ✅ 可选：添加健康检查
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
```

**关键改动**:
1. ✅ 导入 `drift_flutter/drift_flutter.dart`
2. ✅ 使用 `driftDatabase()` 而不是 `LazyDatabase()`
3. ✅ 配置 `native` 和 `web` 选项
4. ✅ 支持可选的 `QueryExecutor` 参数（便于测试）
5. ✅ 添加 `isDatabaseHealthy()` 方法

---

### Step 3: 更新 main.dart

**当前代码** ❌:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dbProvider = DBProvider();
  await dbProvider.initialize();

  runApp(MyApp(dbProvider: dbProvider));
}

class MyApp extends StatelessWidget {
  final DBProvider dbProvider;

  const MyApp({super.key, required this.dbProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppDatabase>.value(value: dbProvider.database),
        ChangeNotifierProvider<RuleProvider>(
          create: (_) => RuleProvider(dbProvider.database),
        ),
      ],
      // ...
    );
  }
}
```

**修复后代码** ✅:
```dart
import 'package:provider/provider.dart';
import 'package:companion_system/database/drift_database.dart';
import 'package:companion_system/providers/rule_provider.dart';
import 'package:companion_system/pages/main_page.dart';

void main() {
  // ✅ 改为同步初始化（无需 async）
  runApp(MultiProvider(
    providers: [
      // ✅ 直接创建 AppDatabase（driftDatabase() 自动处理异步）
      Provider<AppDatabase>(
        create: (ctx) => AppDatabase(),
        dispose: (ctx, db) => db.close(),
      ),
      // ✅ 基于 AppDatabase 创建其他 Provider
      ChangeNotifierProvider<RuleProvider>(
        create: (ctx) => RuleProvider(ctx.read<AppDatabase>()),
      ),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});  // ✅ 无需 dbProvider 参数

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '七政四余格局数据维护系统',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
```

**关键改动**:
1. ✅ 移除 `async main()`
2. ✅ 移除 `DBProvider` 和初始化逻辑
3. ✅ 使用 `MultiProvider` 直接创建 `AppDatabase`
4. ✅ 简化 `MyApp` 构造（无需 dbProvider 参数）

---

### Step 4: 删除旧的初始化代码

**删除文件**:
```bash
lib/providers/db_provider.dart  # ❌ 删除
```

**或者，如果还要保留，改为**:
```dart
// lib/providers/db_provider.dart
import 'package:companion_system/database/drift_database.dart';

class DBProvider {
  late final AppDatabase _database;

  AppDatabase get database => _database;

  // ✅ 已不需要这个方法了（AppDatabase 自动初始化）
  Future<void> initialize() async {
    _database = AppDatabase();
    final healthy = await _database.isDatabaseHealthy();
    print('Database initialized: ${healthy ? 'healthy' : 'unhealthy'}');
  }
}
```

但更简洁的做法就是直接删除 DBProvider。

---

### Step 5: 更新使用数据库的地方

**在 DAO/Service 中使用**:

```dart
// ✅ 在任何需要数据库的地方
final db = context.read<AppDatabase>();
final patterns = await db.select(db.geJuPatterns).get();
```

**或通过 DAO**:

```dart
// ✅ 如果有 DAO（推荐）
final dao = GeJuPatternsDao(context.read<AppDatabase>());
final patterns = await dao.getAllPatterns();
```

---

## 🧪 验证修复

### 步骤 1: 获取依赖

```bash
cd companion_system
flutter pub get
```

### 步骤 2: 生成代码

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 步骤 3: 运行代码分析

```bash
flutter analyze
```

**预期结果**: `0 errors`

### 步骤 4: 在 Windows 上测试

```bash
flutter run -d windows
```

**预期结果**: ✅ 应用启动正常

### 步骤 5: 在浏览器上测试（可选）

```bash
flutter run -d chrome
```

**预期结果**:
- 之前会失败（FFI 错误）
- 现在应该正常运行（使用 WASM）

---

## 📊 修复对比

| 方面 | 修复前 ❌ | 修复后 ✅ |
|------|---------|--------|
| 依赖 | 仅 drift | drift + drift_flutter |
| main() | async | 同步 |
| 初始化 | LazyDatabase + async | driftDatabase() + 同步 |
| DBProvider | 需要 | 不需要 |
| Chrome 支持 | ❌ FFI 错误 | ✅ WASM 支持 |
| 与主项目一致 | ❌ 不同 | ✅ 一致 |

---

## 🚀 最终效果

修复完成后，你可以：

```bash
# ✅ 都能正常运行
flutter run -d windows    # Native + FFI
flutter run -d android    # Native + FFI
flutter run -d chrome     # Web + WASM
flutter run -d safari     # Web + WASM

# 完全同一套代码！
```

---

## 💾 完整的修改总结

### 需要修改的文件

1. **pubspec.yaml**: 添加 `drift_flutter`
2. **lib/database/drift_database.dart**: 使用 `driftDatabase()`
3. **lib/main.dart**: 简化初始化
4. **lib/providers/db_provider.dart**: 删除（可选）

### 需要删除的文件

- `lib/providers/db_provider.dart` (可选，如果只是初始化器)

### 代码行数

```
添加: ~30 行 (drift_flutter 配置)
删除: ~50 行 (DBProvider + 复杂初始化)
净变化: -20 行（代码更简洁！）
```

---

## ✨ 完成后的优势

1. **跨平台支持** - 支持 Web、Windows、Android 等
2. **代码更简洁** - 无需 DBProvider
3. **启动更快** - 同步初始化，无额外 async
4. **与主项目一致** - 遵循相同的设计模式
5. **未来准备就绪** - 如果需要 Web，零额外改动

