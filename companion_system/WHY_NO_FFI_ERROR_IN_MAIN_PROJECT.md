# 🔍 为什么主项目在 Chrome 上没有 FFI 错误？

## 📌 核心原因：`driftDatabase()` 的平台自适应

### 主项目：智能平台检测

**主项目代码**:
```dart
AppDatabase([QueryExecutor? e])
    : super(
        e ??
            driftDatabase(  // ✅ 关键！这个函数做平台检测
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
                  print('Using ${result.chosenImplementation}...');
                },
              ),
            ),
      );
```

**运行流程**:
```
flutter run -d chrome
  ↓
Dart 编译为 JavaScript
  ↓
driftDatabase() 检测当前平台
  ↓
🔍 检测到：Web 平台 (JavaScript)
  ↓
✅ 自动选择 DriftWebOptions
  ↓
加载 sqlite3.wasm (WebAssembly)
  ↓
使用 WASM 版 SQLite，无需原生 FFI
  ↓
Chrome 中正常运行！✨
```

---

### Companion System：固定原生实现

**Companion System 代码**:
```dart
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();  // ❌ 这只支持 Native
    final file = File(p.join(dbFolder.path, 'ge_ju.db'));      // ❌ 这只支持 Native
    return NativeDatabase.createInBackground(file);             // ❌ 硬编码 Native
  });
}
```

**运行流程**:
```
flutter run -d chrome
  ↓
Dart 编译为 JavaScript
  ↓
执行 _openConnection()
  ↓
❌ 调用 getApplicationDocumentsDirectory()
   └─ 在 Web 上不可用！没有 "Documents" 文件夹
  ↓
❌ 创建 File(...) 对象
   └─ 在 Web 上不可用！没有文件系统
  ↓
❌ NativeDatabase.createInBackground()
   └─ 这要求 FFI（Foreign Function Interface）
   └─ 但 JavaScript 环境中没有 FFI！
  ↓
💥 Runtime Error / FFI 错误
```

---

## 🔑 两种方式的根本区别

### 方式 1：`driftDatabase()` - 智能适配

| 平台 | 自动选择 | 实现 | 依赖 |
|------|--------|------|------|
| **Windows** | DriftNativeOptions | NativeDatabase | sqlite3_flutter_libs (FFI) |
| **macOS** | DriftNativeOptions | NativeDatabase | sqlite3_flutter_libs (FFI) |
| **Linux** | DriftNativeOptions | NativeDatabase | sqlite3_flutter_libs (FFI) |
| **iOS** | DriftNativeOptions | NativeDatabase | sqlite3_flutter_libs (FFI) |
| **Android** | DriftNativeOptions | NativeDatabase | sqlite3_flutter_libs (FFI) |
| **Chrome** | **DriftWebOptions** | **WASM** | **sqlite3.wasm** |
| **Safari** | **DriftWebOptions** | **WASM** | **sqlite3.wasm** |
| **Firefox** | **DriftWebOptions** | **WASM** | **sqlite3.wasm** |

```dart
driftDatabase() 的伪代码逻辑：

if (kIsWeb) {
  // Web 平台
  return DriftWebOptions 的实现
} else {
  // Native 平台
  return DriftNativeOptions 的实现
}
```

### 方式 2：`NativeDatabase()` - 只支持 Native

```dart
NativeDatabase.createInBackground(file)  // ❌ 只能在原生平台

// 等价于：
if (kIsWeb) {
  throw UnsupportedError('Web platform not supported');
}
return NativeDatabase(file);
```

---

## 🚀 为什么主项目这样设计？

主项目支持跨平台：

```bash
# 主项目可以运行：
flutter run -d chrome        # ✅ Web
flutter run -d edge          # ✅ Web
flutter run -d windows       # ✅ Native
flutter run -d android       # ✅ Native
flutter pub run webdev serve # ✅ Web 开发服务器

# 使用同一套代码，Drift 自动适配！
```

---

## 💡 关键代码片段解析

### 主项目：driftDatabase() 提供双配置

```dart
driftDatabase(
  name: 'app_74_database',

  // 配置 1：原生平台
  native: const DriftNativeOptions(
    databaseDirectory: getApplicationSupportDirectory,
  ),

  // 配置 2：Web 平台
  web: DriftWebOptions(
    sqlite3Wasm: Uri.parse('sqlite3.wasm'),      // WASM 版 SQLite
    driftWorker: Uri.parse('drift_worker.js'),   // Web Worker
  ),
)
```

**好处**:
- ✅ 一个 AppDatabase 类
- ✅ 所有平台共用
- ✅ 自动检测和适配
- ✅ 零额外代码

### Companion System：hardcoded Native

```dart
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    // 这些在 Web 上都不可用：
    final dbFolder = await getApplicationDocumentsDirectory();  // ❌
    final file = File(p.join(dbFolder.path, 'ge_ju.db'));     // ❌
    return NativeDatabase.createInBackground(file);             // ❌
  });
}
```

**问题**:
- ❌ 只能在原生平台运行
- ❌ `flutter run -d chrome` 必然失败
- ❌ 无法跨平台共享代码
- ❌ FFI 错误不可避免

---

## 📊 运行命令对比

### 主项目

```bash
# ✅ Windows
flutter run -d windows        # 成功（使用 NativeDatabase）

# ✅ Chrome
flutter run -d chrome         # 成功（使用 WASM）

# ✅ Android
flutter run -d android        # 成功（使用 NativeDatabase）

# 🎯 同一套代码，多个平台！
```

### Companion System（当前）

```bash
# ✅ Windows
flutter run -d windows        # 成功（使用 NativeDatabase）

# ❌ Chrome
flutter run -d chrome         # 失败！FFI 错误
# 错误原因：NativeDatabase 在 Web 上不可用

# ✅ Android
flutter run -d android        # 成功（使用 NativeDatabase）

# 🔴 只能在原生平台运行
```

---

## 🔧 修复 Companion System 的方案

### 选项 1：采用主项目的 driftDatabase()（推荐）

```dart
import 'package:drift_flutter/drift_flutter.dart';

@DriftDatabase(tables: [...])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e])
      : super(
          e ??
              driftDatabase(
                name: 'ge_ju_database',
                native: const DriftNativeOptions(
                  databaseDirectory: getApplicationSupportDirectory,
                ),
                // 如果将来需要 Web 支持
                web: DriftWebOptions(
                  sqlite3Wasm: Uri.parse('sqlite3.wasm'),
                  driftWorker: Uri.parse('drift_worker.js'),
                ),
              ),
        );

  @override
  int get schemaVersion => 1;
}
```

**优点**:
- ✅ 与主项目一致
- ✅ 未来可支持 Web
- ✅ 清晰的平台配置
- ✅ 零额外复杂性

### 选项 2：仅支持原生，条件导入

```dart
import 'package:drift/drift.dart';
import 'package:drift/native.dart';

@DriftDatabase(tables: [...])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'ge_ju.db'));
    return NativeDatabase.createInBackground(file);
  });
}
```

**限制**:
- ❌ 只支持原生平台
- ❌ 无法 `flutter run -d chrome`
- ❌ 不符合现代应用需求

---

## 🎯 总结

| 功能 | 主项目 | Companion System |
|------|--------|-----------------|
| Windows 运行 | ✅ | ✅ |
| Chrome 运行 | ✅ (WASM) | ❌ (FFI Error) |
| macOS 运行 | ✅ | ✅ |
| Android 运行 | ✅ | ✅ |
| 平台自适应 | ✅ `driftDatabase()` | ❌ 硬编码 `NativeDatabase` |
| 代码复用 | ✅ 单一实现 | ❌ 多套实现 |
| FFI 依赖 | 仅在原生平台 | 总是必需 |

---

## 📝 关键代码对比

### 主项目：完整的平台支持

```dart
driftDatabase(
  name: 'database_name',
  native: DriftNativeOptions(...),  // Native 平台
  web: DriftWebOptions(...),         // Web 平台
)
```

### Companion System：仅原生支持

```dart
NativeDatabase(file)  // ❌ 只支持原生
// ❌ Web 平台会报 FFI 错误
```

---

## 🚀 建议行动

将 Companion System 改为：

```dart
// 添加导入
import 'package:drift_flutter/drift_flutter.dart';

// 更新 AppDatabase
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e])
      : super(
          e ??
              driftDatabase(
                name: 'ge_ju_database',
                native: const DriftNativeOptions(
                  databaseDirectory: getApplicationSupportDirectory,
                ),
                web: DriftWebOptions(
                  sqlite3Wasm: Uri.parse('sqlite3.wasm'),
                  driftWorker: Uri.parse('drift_worker.js'),
                ),
              ),
        );
}
```

这样就能像主项目一样：
- ✅ 支持所有平台
- ✅ 无 FFI 错误
- ✅ 代码统一管理
- ✅ 未来可轻松添加 Web 支持

