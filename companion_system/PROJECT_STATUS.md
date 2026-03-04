# companion_system - 七政四余格局数据维护系统

## 已完成的功能

### 1. 数据库层 (Database Layer)
- ✅ Drift ORM 配置完成
- ✅ 五张核心数据表定义：
  - `ge_ju_patterns` - 格局元信息
  - `ge_ju_schools` - 流派/典籍
  - `ge_ju_rules` - 格局规则
  - `ge_ju_versions` - 版本历史
  - `ge_ju_categories` - 分类
- ✅ 生成代码文件 `drift_database.g.dart`

### 2. 模型层 (Model Layer)
- ✅ 枚举定义 (`models/enums.dart`)
- ✅ 数据模型扩展 (`models/model_extensions.dart`)

### 3. Provider层 (State Management)
- ✅ `DBProvider` - 数据库单例管理
- ✅ `RuleProvider` - 规则数据状态管理

### 4. UI层 (Presentation Layer)
- ✅ `MainPage` - 主页面（卡片式导航）
- ✅ `RuleListPage` - 规则列表页（含搜索、筛选功能）
- ✅ `PatternManagementPage` - Pattern管理页（占位）
- ✅ `SchoolManagementPage` - School管理页（占位）

### 5. 应用入口
- ✅ `main.dart` - 应用初始化和Provider配置

## 项目结构

```
companion_system/
├── lib/
│   ├── database/
│   │   ├── drift_database.dart        # 数据库定义
│   │   ├── drift_database.g.dart      # Drift生成代码
│   │   └── tables.dart                # 表结构定义
│   ├── models/
│   │   ├── enums.dart                 # 枚举类型
│   │   └── model_extensions.dart      # 模型扩展
│   ├── providers/
│   │   ├── db_provider.dart           # 数据库Provider
│   │   └── rule_provider.dart         # 规则数据Provider
│   ├── pages/
│   │   ├── main_page.dart            # 主页
│   │   ├── rule_list_page.dart       # 规则列表页
│   │   ├── pattern_management_page.dart # Pattern管理
│   │   └── school_management_page.dart  # School管理
│   └── main.dart                     # 应用入口
├── pubspec.yaml                       # 依赖配置
└── README.md                          # 项目说明
```

## 待完成的功能 (按优先级)

### P0 - 核心功能 (高优先级)
1. **规则编辑功能**
   - [ ] 创建规则编辑弹窗 (BottomSheet)
   - [ ] 实现表单验证
   - [ ] 条件编辑器（JSON格式）
   - [ ] 版本管理（升级/覆盖/历史）

2. **数据初始化**
   - [ ] 修复路径编码问题
   - [ ] 成功运行应用并显示数据
   - [ ] 添加示例规则数据

### P1 - 增强功能 (中优先级)
3. **批量操作**
   - [ ] 批量编辑规则
   - [ ] 批量删除
   - [ ] 批量导出

4. **导入导出**
   - [ ] JSON导出功能
   - [ ] JSON导入功能
   - [ ] 数据验证

5. **Pattern管理**
   - [ ] Pattern列表页
   - [ ] Pattern详情页
   - [ ] PatternCRUD操作

6. **School管理**
   - [ ] School列表页
   - [ ] School编辑功能
   - [ ] School统计信息

### P2 - 高级功能 (低优先级)
7. **版本管理**
   - [ ] 版本历史查看
   - [ ] 版本对比
   - [ ] 版本回滚

8. **搜索筛选增强**
   - [ ] 高级搜索
   - [ ] 保存搜索条件
   - [ ] 搜索历史

9. **UI优化**
   - [ ] 加载动画
   - [ ] 错误提示优化
   - [ ] 空状态插图

## 已知问题

### 编译问题
- **路径编码问题**：由于路径包含中文字符"星命学"，Visual Studio无法正确读取`.dill`文件
- **临时解决方案**：将项目移动到纯英文路径，或使用命令`flutter doctor`检查Flutter环境

### 功能缺失
1. 数据未成功初始化（待编译成功后验证）
2. 示例数据未插入
3. 编辑功能未实现

## 继续开发步骤

### 步骤1：解决编译问题
```bash
# 方案A：复制到纯英文路径
cp -r D:/星命学/xuan-qizhengsiyu/companion_system D:/projects/
cd D:/projects/companion_system
flutter run -d windows

# 方案B：使用Dart命令行运行（绕过路径问题）
flutter run -d windows
```

### 步骤2：验证数据库初始化
运行应用后，确认默认分类和流派数据已创建

### 步骤3：实现规则编辑器
```dart
// lib/widgets/rule_edit_bottom_sheet.dart
// 创建BottomSheet编辑器，包含表单字段：
// - Pattern选择器
// - School选择器
// - 吉凶（吉/平/凶）
// - 层级（小/中/大）
// - 类型选择
// - 范围选择
// - 条件JSON编辑器
// - 断语输入
// - 简介输入
```

### 步骤4：实现示例数据导入
```dart
// 添加一些示例规则数据以便测试
await db.into(db.geJuRules).insert(
  GeJuRulesCompanion.insert(
    patternId: 'ri_yue_jia_ming',
    schoolId: 'guo_lao',
    jixiong: '吉',
    level: '大',
    ...
  ),
);
```

### 步骤5：测试完整流程
1. 启动应用
2. 查看规则列表
3. 测试筛选功能
4. 测试规则详情
5. 测试新建/编辑规则

## 依赖包
```yaml
dependencies:
  flutter:
    sdk: flutter
  drift: ^2.14.0
  sqlite3_flutter_libs: ^0.5.41
  path_provider: ^2.1.0
  provider: ^6.1.0
  file_selector: ^0.9.0

dev_dependencies:
  drift_dev: ^2.14.0
  build_runner: ^2.4.6
  flutter_lints: ^5.0.0
```

## 运行命令
```bash
# 安装依赖
flutter pub get

# 生成代码
flutter pub run build_runner build --delete-conflicting-outputs

# 运行应用
flutter run -d windows

# 构建应用
flutter build windows
```

## 设计文档参考
- PRD: `docs/helper_system/PRDs.md`
- 计划: `docs/helper_system/Plans.md`
- 任务: `docs/helper_system/Tasks.md`
- 格局管理计划: `docs/feature/ge_ju/manager_plans.md`

---
**状态**: 核心架构完成，UI框架就绪，需解决编译问题后继续开发
**完成度**: 约30%
