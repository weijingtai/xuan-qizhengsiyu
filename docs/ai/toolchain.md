# 开发环境与工具链

## Flutter/Dart SDK 版本

MUST: SDK 版本以 `pubspec.yaml` 中 `environment` 声明为准
MUST: 推荐使用 FVM (Flutter Version Management) 管理 Flutter 版本
MUST: Dart SDK 版本由 Flutter 版本隐含确定，不在 pubspec 中单独指定不兼容版本
MUST NOT: 随意升级 `pubspec.yaml` 中的 SDK 版本约束（需经过 SPEC Coding）

## 依赖管理

MUST: 所有依赖通过 `pubspec.yaml` 声明
MUST: 主版本锁定（使用 `^` 兼容范围或精确版本）
MUST: `pubspec.lock` MUST 提交到 Git（应用项目，非 package）
MUST NOT: 引入未使用的依赖
MUST NOT: 直接修改 `pubspec.lock`（使用 `flutter pub get` 生成）

## 开发前检查清单

每次开发会话启动时，MUST 运行以下 4 个命令：

```
[ ] flutter clean          ← 清理上次构建缓存
[ ] flutter pub get        ← 同步依赖
[ ] flutter analyze        ← 确认起点无 lint 错误
[ ] flutter test           ← 确认起点测试全通过
```

MUST: 在开始修改代码前运行上述 4 个命令
MUST: 如 `flutter analyze` 在修改前已有错误，MUST 先报告用户再继续

## 构建与运行

MUST: 开发阶段使用 `flutter run --debug`（不发布 release 构建）
MUST: 测试使用 `flutter test`（不依赖特定设备）
MUST NOT: 在开发分支上执行发布构建（release build 仅在 main/release 分支上）

## 隔离承诺

MUST: 每个功能在独立分支开发
MUST: 不修改 `.gitignore` 排除规则以绕过规范
MUST NOT: 在多个分支间共享未提交的改动（`git stash` 除外）
MUST NOT: 提交 `.flutter-plugins-dependencies`（已在 .gitignore 中）

## 项目专有约定（qizhengsiyu）

### 同级 package 依赖

MUST: `../xuan-common` 必须存在于工作区同级目录，本项目通过相对路径引用其 `common` 与 `persistence_core` 子 package
MUST: 拉取 `xuan-common` 后 MUST 同步执行 `flutter pub get`，避免 path 依赖未解析
MUST NOT: 将 `common` / `persistence_core` 改为 git 源以外的本地 fork（除非整组 package 同步切换）

### 代码生成

MUST: 修改任何含 `@JsonSerializable()` 或 drift `@DriftDatabase` 注解的源文件后，MUST 重新运行：

```bash
dart run build_runner build --delete-conflicting-outputs
```

MUST NOT: 手动编辑 `*.g.dart` 生成文件
MUST: 生成产物 `*.g.dart` MUST 提交到 Git（消费方无需再次执行 build_runner）

### Drift 数据库迁移

MUST: 新增/修改 Drift 表结构时，MUST 同步：
- 在 `AppDatabase` 上调升 `schemaVersion`
- 在 `MigrationStrategy.onUpgrade` 中实现对应 from→to 的迁移
- 已发布版本的 schema MUST NOT 直接改动，MUST 通过迁移实现

MUST: `AppDatabase` 在本项目内为单例（`factory AppDatabase()` 共享实例）
MUST NOT: 在 Provider 中 dispose / close 该实例

### 嵌入式 Flutter Module 边界

MUST: 本项目以 Flutter module 形式嵌入原生宿主（非独立 app）；调试可用 `cd example && flutter run`
MUST NOT: 在 lib/ 顶层直接写入 `runApp()` 等期望独立 app 的代码（保留在 `example/` 中）

### 上游 docs/ 子树

MUST: `docs/` 来自 `https://github.com/weijingtai/docs.git`（subtree, branch=master），仅允许 pull
MUST NOT: 执行 `git subtree push --prefix=docs ...`（永远不向上游写回）
MUST: 项目对该框架的本地适配（如 Plans.md、project/README.md）随本仓库 commit 即可
