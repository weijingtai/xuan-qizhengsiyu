# 原子化待办事项 (Todo List)

## 第一组: 数据结构与迁移

- [ ] 创建 `patterns_index.json` 空骨架。
- [ ] 创建 `definitions.json` 空骨架。
- [ ] 编写脚本从旧文件中提取唯一的 Pattern ID -> 填充 `patterns_index.json`。
- [ ] 编写脚本将旧条目转换为 `Definition` 对象 -> 填充 `definitions.json`。
- [ ] 人工核对前 20 个核心格局（如命宫主格）的“通用 (Universal)”标记。

## 第二组: 引擎实现

- [ ] 创建 `GeJuRepository` 类以处理数据加载。
- [ ] 实现 `GeJuRepository.getDefinition(patternId, schoolContext)` 方法。
- [ ] 单元测试: 验证“通用回退”机制（当流派缺少定义时）。
- [ ] 单元测试: 验证“流派遮蔽”机制（当流派有特定定义时）。
- [ ] 重构 `ConditionParser` 以使用基于字符串的功能码，而不是硬编码的类名。

## 第三组: 逻辑 DSL

- [ ] 实现 `starInGong` (星在宫) 处理器。
- [ ] 实现 `gongDegree` (宫度) 处理器。
- [ ] 实现 `angleBetween` (相位夹角) 处理器。
- [ ] 实现 `starGuardLife` (命主星) 处理器。
- [ ] 实现 `threeNineHarmony` (三方四正) 处理器。

## 第四组: 用户系统

- [ ] 定义 `UserDefinition` 模型类。
- [ ] 创建 `UserDefinitionService` 以从本地存储保存/加载 JSON。
- [ ] 实现 `forkDefinition(sourceId)` 函数。

## 第五组: UI 实现

- [ ] 创建 `SchoolSelectionWidget` (流派选择组件)。
- [ ] 更新 `GeJuListTile` 以显示“原始出处”（例如：“来源：果老星宗”）。
- [ ] 在格局详情页添加“编辑/Fork”按钮。
