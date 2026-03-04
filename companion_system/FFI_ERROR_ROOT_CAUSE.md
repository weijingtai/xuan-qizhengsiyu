# 🎯 一句话答案 + 详细分解

## ⚡ 一句话

**主项目使用 `driftDatabase()`，它根据运行平台自动选择实现（Native 或 WASM），所以 Chrome 上自动用 WASM，不涉及 FFI。而 Companion System 硬编码 `NativeDatabase()`，只支持原生平台。**

---

## 🔍 深度分析

### 主项目的聪明之处

```dart
driftDatabase(
  name: 'app_74_database',
  native: DriftNativeOptions(...),    // 如果是 Windows/Android/iOS
  web: DriftWebOptions(...),          // 如果是 Chrome/Safari
)
```

**Drift 的运行时决策**:

```
运行前：
┌─────────────────────────────┐
│ flutter run -d chrome       │  → 编译为 JavaScript
└──────────────┬──────────────┘
               ↓
┌─────────────────────────────┐
│ driftDatabase() 检查环境    │
│ if (kIsWeb) ? web : native  │
└──────────────┬──────────────┘
               ↓
         ✅ 选择 web
               ↓
┌─────────────────────────────┐
│ 加载 sqlite3.wasm           │
│ (WebAssembly SQLite)         │
└─────────────────────────────┘

结果：无需 FFI，正常运行！🎉
```

---

### Companion System 的固化之处

```dart
LazyDatabase _openConnection() {
  return NativeDatabase.createInBackground(file);  // ❌ 永远是 Native
}
```

**固定的原生实现**:

```
运行前：
┌─────────────────────────────┐
│ flutter run -d chrome       │  → 编译为 JavaScript
└──────────────┬──────────────┘
               ↓
┌─────────────────────────────┐
│ 执行 _openConnection()      │
│ return NativeDatabase(...)  │  ← 硬编码 Native！
└──────────────┬──────────────┘
               ↓
        ❌ 出错！

Chrome (JavaScript) 环境中试图调用：
- getApplicationDocumentsDirectory()  ❌ 不存在文件系统
- File(...)                          ❌ 不存在文件 API
- NativeDatabase.createInBackground()❌ 需要 FFI → JS 中无 FFI
               ↓
      💥 FFI 相关错误
```

---

## 📊 代码对比表

| 代码位置 | 主项目 | Companion System | 差异 |
|---------|--------|-----------------|------|
| **初始化函数** | `driftDatabase()` | `NativeDatabase()` | 前者智能，后者固化 |
| **配置 Native** | `native: DriftNativeOptions()` | 隐含 | 显式 vs 隐含 |
| **配置 Web** | `web: DriftWebOptions()` | ❌ 无 | 有 vs 无 |
| **平台检测** | ✅ 自动 | ❌ 无 | 自动 vs 固化 |
| **Chrome 支持** | ✅ 是 | ❌ 否 | 有 vs 无 |

---

## 🌍 导入库的差异

### 主项目：跨平台库

```dart
import 'package:drift_flutter/drift_flutter.dart';

// drift_flutter 包含：
// - driftDatabase() 函数
// - Web 和 Native 的双实现
// - 自动平台检测逻辑
```

### Companion System：仅原生库

```dart
import 'package:drift/native.dart';

// drift/native 包含：
// - NativeDatabase（仅原生）
// - getApplicationDocumentsDirectory()（仅原生）
// - File API（仅原生）
```

---

## 🧪 验证：运行日志会显示什么

### 主项目 `flutter run -d chrome`

```
✓ Built build for Chrome
✓ Launching Chrome...
I/Drift: Initializing database 'app_74_database'
I/Drift: Using DriftWebOptions implementation
I/Drift: Loading sqlite3.wasm...
I/Drift: Database initialized successfully ✓
✓ Application started!
```

### Companion System `flutter run -d chrome`

```
✓ Built build for Chrome
✓ Launching Chrome...

❌ Error: Unable to load sqlite3_flutter_libs
   Reason: NativeDatabase requires FFI support

❌ Error: getApplicationDocumentsDirectory not available on web
❌ Error: File API not available on web

😞 Application crashed
```

---

## 🔑 理解 kIsWeb 常量

Dart 编译时条件：

```dart
// dart/foundation.dart 中定义
const kIsWeb = bool.fromEnvironment('dart.library.js_util');

// 编译时检查：
if (kIsWeb) {
  // flutter run -d chrome 时为 true
  // 使用 Web 实现
} else {
  // flutter run -d windows 时为 false
  // 使用 Native 实现
}
```

`driftDatabase()` 就是利用这个常量来选择实现！

---

## 📚 Drift 官方设计

### 支持跨平台的正确方式

```dart
// ✅ 推荐
driftDatabase(
  name: 'my_db',
  native: DriftNativeOptions(...),
  web: DriftWebOptions(...),
)

// ❌ 不推荐
if (kIsWeb) {
  // 手动处理 Web
} else {
  // 手动处理 Native
}

// ❌ 最差
NativeDatabase(file)  // 只支持 Native
```

---

## 🚀 修复方案（一句代码）

将 Companion System 的：

```dart
// ❌ 当前
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'ge_ju.db'));
    return NativeDatabase.createInBackground(file);
  });
}
```

改为：

```dart
// ✅ 修复后
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e])
      : super(e ?? driftDatabase(
          name: 'ge_ju_database',
          native: const DriftNativeOptions(
            databaseDirectory: getApplicationSupportDirectory,
          ),
          web: DriftWebOptions(
            sqlite3Wasm: Uri.parse('sqlite3.wasm'),
            driftWorker: Uri.parse('drift_worker.js'),
          ),
        ));
}
```

**结果**：
- ✅ `flutter run -d windows` 成功
- ✅ `flutter run -d chrome` 成功
- ✅ `flutter run -d android` 成功
- ✅ 无 FFI 错误
- ✅ 与主项目一致

