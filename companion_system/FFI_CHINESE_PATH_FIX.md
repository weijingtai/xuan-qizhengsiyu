# Companion System FFI 中文路径问题修复

## 问题描述

当项目位于含有中文字符的路径下（如 `D:\星命学\xuan-qizhengsiyu\companion_system`）时，构建 Windows 版本会失败：

```
CUSTOMBUILD : error : Unable to read file: D:\锟斤拷锟斤拷学\xuan-qizhengsiyu\companion_system\.dart_tool\flutter_build\...
```

这是因为 sqlite3_flutter_libs（FFI 库）在编译时无法正确处理中文路径的编码。

## 根本原因

- Flutter Windows 构建过程中 Dart VM 生成的 `.dart_tool` 文件路径被错误编码
- sqlite3_flutter_libs 的原生编译阶段无法正确处理 UTF-8 编码的中文路径

## 解决方案

### 方案 1：使用 ASCII 路径（推荐）

在不包含中文字符的路径下运行项目：

```bash
cp -r "D:\星命学\xuan-qizhengsiyu\companion_system" "D:\companion_system"
cd "D:\companion_system"
flutter build windows
```

### 方案 2：修改 CMakeLists.txt（当前已实现）

已在 `windows/CMakeLists.txt` 中添加 UTF-8 编译选项：

```cmake
if(MSVC)
  add_compile_options(/utf-8)
endif()
```

但这仅限于 C++ 编译，Dart VM 的编码问题仍可能存在。

### 方案 3：设置 Windows 代码页

在 PowerShell 中运行：

```powershell
chcp 65001  # 设置为 UTF-8 代码页
flutter clean
flutter build windows
```

## 当前状态

✅ **代码依赖问题已全部解决：**
- Drift 版本已更新至 2.30.1（与主项目一致）
- 所有 Companion 类已正确生成
- 代码分析无错误

✅ **构建测试：**
- 在 `D:\companion_system_temp` (ASCII 路径)下构建成功
- 输出: `build\windows\x64\runner\Release\companion_system.exe`

## 建议

1. **短期**：在 ASCII 路径下开发和构建
2. **长期**：
   - 将项目文件夹改名为英文（如 `xuan-qizhengsiyu`）
   - 或升级 Flutter 到最新版本（可能已修复此问题）

## 已修改的文件

- `windows/CMakeLists.txt` - 添加 UTF-8 编译选项
- `pubspec.yaml` - Drift 版本更新
- `lib/models/model_extensions.dart` - 修复 Companion 类名称
- `lib/database/drift_database.dart` - 已重新生成
- `test/widget_test.dart` - 修复测试代码

