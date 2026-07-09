# 任务: 004-drag-calibration-tool
负责: opencode ｜ 分支: agent/opencode/004-drag-calibration-tool ｜ 开工: 2026-07-09
状态: 进行中

## 目标
开发周天对齐点拖拽校准工具: 拖动二十八宿环相对十二宫环旋转, 实时读数(某宿某度), 松手写入 BasePanelConfig.alignmentPointOverride。三层架构(①纯几何/②语义适配/③Painter手势)隔离 chart-ui 迁移风险。

## 计划
（阶段拆解权威版见 docs/project/tasks/003-004-sanchen-zhoutian-task.md 方向二）
- [x] 2-A ①层 纯几何环形角度增量库 (OpenCode)
- [x] 2-B ②层 语义适配 + BasePanelConfig 字段 + applyOverrides 扩参 + manager 传入 (Claude)
- [ ] 2-C ③-甲 Painter + GestureDetector 拼装 (OpenCode)
- [ ] 2-D ③-乙 用户自建候选对齐点持久化 (Claude 写SOP + OpenCode 取数)
- [ ] 2-E 集成测试 + Widget 测试收尾 (OpenCode)

## 验收标准
- [ ] <规划Agent填写: 合并前必须满足的硬性标准, 执行Agent无权修改本区条目>
验收命令: <一条可执行命令, 如 npm test; aiwt check 会在worktree内自动运行>

## 当前状态
刚完成: 2-B 全三步 + 配套测试, 我的改动 flutter analyze 0-issue、相关测试全绿。
产物: lib/domain/calibration/alignment_point_resolver.dart (②层, 角度增量→宿度绝对值);
  panel_config.dart+.g.dart 新增 alignmentPointOverride; zhou_tian_model.dart:155 applyOverrides 扩参;
  zhou_tian_model_manager.dart:107 传参。测试: test/domain/calibration/, zhou_tian_model_alignment_override_test.dart,
  test/integration/alignment_override_calculator_integration_test.dart, panel_config_serialization_test.dart。
下一步: 2-C(OpenCode) 与 2-D(Claude 写SOP) 可并行, 均依赖已就绪的 2-A/2-B。
微观意图: 2-C 直接复用 resolveAlignmentPointFromDrag(①②串联) 驱动 StarXiuRingPainter 重绘+实时读数,
  文件顶部标 // TECHNICAL DEBT (chart-ui 就绪后整层替换); onPanEnd 写 alignmentPointOverride。
验证: flutter test test/domain/calibration test/domain/entities/zhou_tian_model_alignment_override_test.dart test/integration/alignment_override_calculator_integration_test.dart
注意: 全量 flutter test 有 7 例预存失败, 全在兄弟包(calendar/xuan-storage/xuan-metaphysics-core 编译错误), 非本任务引入。

## 决定记录
<只追加不删改, 一行一条: 日期: 决定了什么, 理由(为什么选A不选B)>
- 2026-07-09: alignmentPointOverride 优先于 constellationOffsetDeg 岁差偏移(override 直接给绝对值, zeroPoint 不再叠加 offset)。理由: 004设计§9 明确 override 优先, 避免两个覆写语义打架。
- 2026-07-09: ②层角度→度换算基准用"逐宿宽度之和 ringSpan"而非 totalDegree。理由: 环视觉占满整圆, 用宽度和才能保证整圈旋转精确回原点; 与 totalDegree 的 0.6° 差不引入。
- 2026-07-09: 本 worktree 手工补 .g.dart 而非跑 build_runner。理由: build_runner 在本 worktree 全量解析包图会失败(见墓地), 生成产物确定性强, 按 json_serializable 既有 projectionOverride 模式手补即可。

## 踩坑墓地
<只追加不删改。每次失败的尝试必须入墓, 一行一条:
日期: 尝试了X, 失败原因Y, 结论(别再试/换Z方向)。防止后任重蹈覆辙的负向记忆>
- 2026-07-09: 跑 `dart run build_runner build` 重生成 .g.dart, 失败: 全量包图解析撞未落地兄弟包路径 .worktrees/xuan-divination-case, 且把 .dart_tool/package_graph.json 写坏导致 flutter test 全崩。结论: 本 worktree 别跑 build_runner, .g.dart 手改。
- 2026-07-09: 根因是 .worktrees/ 缺 13 个兄弟包 symlink(xuan-divination-case / repository-interface-* / xuan-common-ui / xuan-taiyishenshu 等)。修复: 在 .worktrees/ 补齐指向真实兄弟目录的 symlink + `flutter pub get --enforce-lockfile` 重建 package_graph.json(不动 pubspec.lock)。后任若遇同类崩溃照此修。

## 冷冻快照
<仅在搁置时由 /hibernate 填写: 业务背景 / 架构决定摘要 / 精确断点 / 重启第一步 / 环境要求>
