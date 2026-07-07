# 阶段三 · 收官（可配置盘制最终目标的收尾小项目）

> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:subagent-driven-development 或 executing-plans。逐 Task TDD。

**Goal:** 补齐可配置盘制「最终目标」里剩下的良定义小项：流派→四余星历联动、端到端集成金标、端口类型收紧、死副本清理。让全量 `flutter test` 退出码 0。

**范围之外（明确不做，各有阻塞）：**
- **① 起点春分↔冬至几何化**：依赖未定的锚点真值 O1（元代春分点悬案），**须用户先定锚**，不写猜测公式。
- **② 自定义星盘（选/建用户 ZhouTianModel）**：`getZhouTianModelBy` 按(坐标×星盘×星宿)三元组选模型，`BasePanelConfig` 无指向具体用户方案的字段——需新增 config 字段 + 改选择管线 + UI，属**独立设计**，另起计划。

## Global Constraints

- 分支 `feat/chidao-huangdao-tuibian`；只改本计划点名文件；暂存只 `git add` 点名文件，禁止 `git add -A`、禁止 push。
- **收口硬门（吸取前教训）**：每个改必填签名/删文件的 Task，提交前必须 `flutter test` **退出码 0**（不是只跑子集）；命令须 `flutter test; echo "RC=$?"` 亲眼确认 `RC=0` 才算完。
- 省 token：**日常迭代**只跑相关子集；**Task D 结束**跑一次全量 exit 0 收口。
- 遇任何计划未写死的决定/签名不符 → 停下报用户，勿自决。
- 忽略 gitignore 产物 `example/assets/tmp/ge_ju_1_converted.json`，勿提交。

---

## Task A: 流派套配联动四余星历（G4 语义补口）

**问题：** `SchoolConfigResolver.applyProfile` 现保留 `base.siYuProfileId`，导致选琴堂后坐标/周天切了、但罗计月孛紫气的四余星历没跟着切。`SchoolProfile.siYuProfileId` 已带正确值（果老`guolao_ecliptic`/琴堂`qintang_chidao`）。

**Files:**
- Modify: `lib/domain/engines/school/school_config_resolver.dart`
- Modify: `test/domain/engines/school/school_config_resolver_test.dart`（追加）

- [ ] **Step 1: 追加失败测试**
```dart
test('套琴堂档案 → siYuProfileId 跟随切换为 qintang_chidao', () {
  final base = BasePanelConfig.defaultBasicPanelConfig();
  final qt = BuiltInSchoolProfiles.defaultForSchool(EnumSchoolType.QinTang);
  final out = SchoolConfigResolver().applyProfile(base, qt);
  expect(out.siYuProfileId, 'qintang_chidao');
});

test('档案 siYuProfileId 为 null 时保留 base 值', () {
  final base = BasePanelConfig.defaultBasicPanelConfig(); // base=guolao_ecliptic
  // 构造一个 siYuProfileId=null 的档案做保护性断言（用果老默认档案若其 siYuProfileId 非 null 则跳过此断言）
  final gl = BuiltInSchoolProfiles.defaultForSchool(EnumSchoolType.GuoLao);
  final out = SchoolConfigResolver().applyProfile(base, gl);
  expect(out.siYuProfileId, gl.siYuProfileId ?? base.siYuProfileId);
});
```

- [ ] **Step 2: 跑红** `flutter test test/domain/engines/school/school_config_resolver_test.dart`

- [ ] **Step 3: 改 resolver** —— 把 `applyProfile` 里 `siYuProfileId: base.siYuProfileId,` 改为：
```dart
siYuProfileId: p.siYuProfileId ?? base.siYuProfileId,
```
（其余字段不动。）

- [ ] **Step 4: 跑绿 + 全量 exit 0**
```
flutter test test/domain/engines/school/school_config_resolver_test.dart && flutter test; echo "RC=$?"
```
Expected: 子集绿；全量 `RC=0`（确认四余联动未破坏既有金标/默认路径）。

- [ ] **Step 5: 提交**
```bash
git add lib/domain/engines/school/school_config_resolver.dart test/domain/engines/school/school_config_resolver_test.dart
git commit -m "feat(school): 流派套配联动四余星历 siYuProfileId"
```

---

## Task B: 端口 `listAll()` 类型收紧（去 dynamic）

**问题：** `UserSchoolProfileServicePort.listAll()` 返回 `Future<List<dynamic>>`，类型太松。改为返回领域模型。

**Files:**
- Modify: `lib/domain/services/user_school_profile_service_port.dart`（加领域模型 `SavedSchoolProfile` + 收紧签名）
- Modify: `lib/data/services/user_school_profile_service.dart`（`listAll` 映射行→模型）
- Modify: `test/domain/services/user_school_profile_service_test.dart`（断言元素类型/字段）

- [ ] **Step 1: 追加失败测试**（断言 `listAll()` 元素是 `SavedSchoolProfile` 且字段可读）
```dart
test('listAll 返回 SavedSchoolProfile 且字段可读', () async {
  // 用既有 fake/内存 repo 存一条后 listAll，断言 first.name / first.config 可直接读，无需 as dynamic
});
```

- [ ] **Step 2: 跑红**

- [ ] **Step 3: 端口加模型 + 收紧签名**
```dart
// user_school_profile_service_port.dart 顶部区加：
class SavedSchoolProfile {
  final String id, name, school, classicBook;
  final BasePanelConfig config;
  const SavedSchoolProfile({
    required this.id, required this.name, required this.school,
    required this.classicBook, required this.config,
  });
}
```
接口签名 `Future<List<dynamic>> listAll();` → `Future<List<SavedSchoolProfile>> listAll();`

- [ ] **Step 4: data service 映射** —— `listAll()` 里把 Drift 行类映射为 `SavedSchoolProfile`（字段名核对 `UserSchoolProfileTableData` 的 `uuid/name/school/classicBook/panelConfig`；`panelConfig` 经 converter 已是 `BasePanelConfig`）。
> 核对点：行类 getter 名与实际生成不符 → 停下报用户。

- [ ] **Step 5: 跑绿 + analyze**
```
flutter test test/domain/services/user_school_profile_service_test.dart && flutter analyze lib/domain/services/user_school_profile_service_port.dart lib/data/services/user_school_profile_service.dart
```
Expected: 绿；0 error。

- [ ] **Step 6: 提交**
```bash
git add lib/domain/services/user_school_profile_service_port.dart lib/data/services/user_school_profile_service.dart test/domain/services/user_school_profile_service_test.dart
git commit -m "refactor(school): 端口 listAll 收紧为 SavedSchoolProfile"
```

---

## Task C: 端到端集成金标（选流派 → 排盘模型真反映配置）

**目的：** 现有测试都在单元级；补一条贯通金标，证「选琴堂 config → `ZhouTianModelManager.getZhouTianModelBy` 得到的模型确为天赤道/365.25」，钉死配置真的流到排盘选择。

**Files:**
- Create: `test/integration/school_to_zhoutian_integration_test.dart`

- [ ] **Step 1: 写集成金标**
```dart
// 结构参考 test/domain/engines/backward_compat_golden_test.dart 的 _FakeRepo + setModelsForTesting 装载方式：
// 1) 用 ZhouTianModelManager 装入至少两把模型：
//    key '黄道制_回归制_古宿制'(果老,totalDegree=360) 与 天赤道对应 key(琴堂,totalDegree=365.2575)。
// 2) base = defaultBasicPanelConfig()。
// 3) 果老档案套配 → getZhouTianModelBy → 断言 systemType==Ecliptic、totalDegree==360。
// 4) 琴堂档案套配 → getZhouTianModelBy → 断言 systemType==SkyEquatorial、totalDegree==365.2575。
```
> 施工者按 `SchoolConfigResolver().applyProfile(base, BuiltInSchoolProfiles.defaultForSchool(...))` 得配置，再喂 `getZhouTianModelBy`。天赤道模型的 mapper key 用 `_createMapperKey(SkyEquatorial, Sidereal, Classical)` 对应的三元组字符串（值以 `.name` 拼接实际为准）。若琴堂档案的三元组在测试装载里无对应模型，**先在测试内构造该模型**（仿 backward_compat 的 `_buildBaselineModel`，改 systemType/panelSystemType/totalDegree），不要改生产码。

- [ ] **Step 2: 跑绿**
```
flutter test test/integration/school_to_zhoutian_integration_test.dart
```
Expected: 绿（若红说明配置未真正驱动模型选择——据此定位，报用户）。

- [ ] **Step 3: 提交**
```bash
git add test/integration/school_to_zhoutian_integration_test.dart
git commit -m "test(integration): 选流派→排盘模型端到端金标"
```

---

## Task D: 清理死副本 + 全量收口

**Files:**
- Delete: `lib/viewmodels/panel_config_viewmodel.dart`（死副本，213 行）

- [ ] **Step 1: 确认零引用**（安全前置）
```
grep -rln "package:qizhengsiyu/viewmodels/panel_config_viewmodel.dart\|'\.\./\.\./viewmodels/panel_config_viewmodel.dart'" lib/ test/ example/
```
> 期望：空（活副本在 `presentation/viewmodels/`，无人 import 死副本）。**若有任何引用，停下报用户，勿删。**

- [ ] **Step 2: 删除并全量验证**
```
git rm lib/viewmodels/panel_config_viewmodel.dart
flutter analyze lib/ ; flutter test; echo "RC=$?"
```
Expected: analyze 0 error；全量 `All tests passed!`、`RC=0`。

- [ ] **Step 3: `detect_changes` 复核**
Run: `detect_changes({scope: "compare", base_ref: "main"})`
Expected: 无意外扩散。

- [ ] **Step 4: 提交**
```bash
git add -u lib/viewmodels/panel_config_viewmodel.dart
git commit -m "chore: 删除死副本 panel_config_viewmodel（lib/viewmodels）"
```

---

## DoD（收官）

- [ ] 选流派联动四余星历（`siYuProfileId` 跟随）；端口 `listAll` 强类型；端到端集成金标绿；死副本已删。
- [ ] `flutter analyze lib/` 0 error；`flutter test` **退出码 0**、0 失败；`detect_changes` 无意外扩散。

## 收官后仍剩（须你输入，不属本计划）

1. **① 起点几何化** —— 等你定元代春分点锚点真值 O1，再单出。
2. **② 自定义星盘** —— 需新增 config 字段 + 改 `getZhouTianModelBy` 选择管线 + 导入/编辑 UI，另起设计。

这两项落地后，可配置盘制的「最终目标」G1–G5 才算 100% 齐活。
