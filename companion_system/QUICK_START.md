# companion_system 快速开始指南

## 解决编译路径问题的方法

### 方法1: 使用纯英文路径 (推荐)

由于路径"星命学"包含中文字符，Visual Studio编译时会遇到编码问题。

```bash
# 1. 复制项目到纯英文路径
mkdir D:/projects
xcopy /E /I "D:\星命学\xuan-qizhengsiyu\companion_system" D:/projects/companion_system

# 2. 进入新目录
cd D:/projects/companion_system

# 3. 清理并重新编译
flutter clean
flutter pub get
flutter run -d windows
```

### 方法2: 修改环境设置

在PowerShell中设置UTF-8编码：

```powershell
# 设置系统语言为UTF-8
[System.Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$env:LANG = 'en_US.UTF-8'
```

### 方法3: 使用其他设备

在Mac/Linux或纯英文路径的Windows机器上开发。

---

## 首次运行步骤

### 1. 安装依赖

```bash
cd companion_system
flutter pub get
```

### 2. 生成Drift代码

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. 运行应用

```bash
flutter run -d windows
# 或
flutter run -d macos
# 或
flutter run -d chrome
```

---

## 功能使用指南

### 1. 进入规律列表

启动应用后，点击主页的"所有格局"卡片进入规则列表页。

### 2. 筛选规则

- **搜索**: 在搜索框输入关键词（如"日"、"月"、"夹"）
- **流派**: 下拉选择具体流派（如果已加载规则）
- **吉凶**: 选择"吉"、"平"、"凶"进行筛选

### 3. 查看规则详情

点击规则卡片会弹出详情对话框，显示：
- Pattern ID
- School ID
- 吉凶和层级
- 条件（JSON格式）
- 断语和简介
- 版本信息

### 4. 编辑规则（待实现）

点击详情对话框的"编辑"按钮（或列表项的操作），打开编辑BottomSheet。

### 5. Pattern管理

点击主页的"Pattern管理"卡片，查看和管理格局元信息。

### 6. School管理

点击主页的"School管理"卡片，查看和管理流派信息。

---

## 代码结构快速定位

### 查看数据库表定义
```
lib/database/tables.dart
lib/database/drift_database.dart
```

### 查看页面UI
```
lib/pages/main_page.dart              - 主页
lib/pages/rule_list_page.dart         - 规则列表
lib/pages/pattern_management_page.dart - Pattern管理
lib/pages/school_management_page.dart  - School管理
```

### 查看状态管理
```
lib/providers/db_provider.dart   - 数据库Provider
lib/providers/rule_provider.dart - 规则数据Provider
```

### 查看数据模型
```
lib/models/enums.dart          - 枚举类型
lib/models/model_extensions.dart - 模型扩展
```

---

## 调试技巧

### 查看数据库位置

数据库文件位置在应用的文档目录：
```dart
// Windows: C:\Users\<用户名>\Documents\ge_ju.db
// 路径可通过 path_provider 包获取
```

### 使用命令行工具

```bash
# 查看Flutter版本
flutter --version

# 检查依赖
flutter doctor

# 查看已安装包
flutter pub deps
```

### 查看Drift生成代码

```bash
# 重新生成
flutter pub run build_runner build --delete-conflicting-outputs

# 查看生成的文件
ls lib/database/drift_database.g.dart
```

---

## 常见问题

### Q1: 编译失败，提示路径错误
**A**: 使用方法1将项目复制到纯英文路径。

### Q2: 应用启动但数据为空
**A**: 第一次启动会自动插入默认分类和流派数据。如果是空的，检查DBProvider的_initializeData方法。

### Q3: 规则筛选不生效
**A**: 检查RuleProvider中的_filteredRules getter逻辑，确保所有筛选条件都正确实现。

### Q4: 如何修改数据库表结构
**A**:
1. 修改tables.dart中的表定义
2. 增加schemaVersion
3. 实现onUpgrade迁移逻辑
4. 重新生成Drift代码

### Q5: 如何添加新的枚举值
**A**: 修改models/enums.dart中的枚举定义，然后在UI中使用。

---

## 下一步行动

1. 解决编译问题（见方法1）
2. 成功运行应用
3. 验证数据库初始化
4. 开始实现剩余功能

参考文档：
- PROJECT_STATUS.md - 项目进度
- ARCHITECTURE.md - 架构详细说明
- docs/helper_system/PRDs.md - 产品需求
