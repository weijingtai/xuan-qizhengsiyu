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
