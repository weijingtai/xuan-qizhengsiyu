# 阶段二修正 · 修分层边界违规 + 补收口（一页小计划）

> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:subagent-driven-development 或 executing-plans。逐 Task TDD。

**Goal:** 消除阶段二引入的 2 处 Clean Architecture 边界违规（domain→data、UI→data），让 `flutter test` 真全绿，并补上被跳过的 Task 9 收口。

**根因（已坐实）：**
- `lib/domain/services/user_school_profile_service.dart:3-4` 在 **domain** 层 import 了 data 层 `AppDatabase`/DAO → 触发 `domain_to_data_test`、`import_boundary_test`。
- `lib/presentation/pages/qi_zheng_si_yu_config_page.dart:11,604` 在 **UI** 层直接 `AppDatabase().userSchoolProfileDao` → 触发 `ui_boundary_test`、`import_boundary_test`。

**方案：** 抄既有仓储缝范式（`ShenShaRepository`(domain 接口) + `shen_sha_repository_impl.dart`(data 实现) + `di.dart` 里 `Provider<接口>`）。domain 只依赖接口；data 实现独占 DAO；UI 经 Provider 取。

## Global Constraints

- 分支 `feat/chidao-huangdao-tuibian`；只改本计划点名文件；暂存只 `git add` 点名文件，禁止 `git add -A`、禁止 push。
- **不改** DAO/表/`app_database.dart`（Task 4 已对）；**不动** xuan-common 的 `QiZhengSiYuStorageDependencies`。
- **省 token 铁律**：迭代期只跑 `test/architecture/` + `test/domain/engines/school/ test/domain/services/ test/data/user_school_profile_dao_test.dart test/presentation/viewmodels/panel_config_viewmodel_school_test.dart`；**只在最后 Task 4 跑一次全量** `flutter test`。
- 遇任何计划未写死的决定 → 停下报用户。

---

## Task 1: domain 侧仓储接口 + 领域模型

**Files:**
- Create: `lib/domain/repositories/user_school_profile_repository.dart`

**做：** 定义领域模型 + 抽象接口（**只用 domain 类型**，不出现任何 `data/` import）：

```dart
// lib/domain/repositories/user_school_profile_repository.dart
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';

/// 一条已保存的自定义流派档案（领域视图，脱离 Drift 行类）。
class SavedSchoolProfile {
  final String id, name, school, classicBook;
  final BasePanelConfig config;
  const SavedSchoolProfile({
    required this.id, required this.name, required this.school,
    required this.classicBook, required this.config,
  });
}

abstract class UserSchoolProfileRepository {
  Future<String> save({
    required String name, required String school,
    required String classicBook, required BasePanelConfig config,
  });
  Future<List<SavedSchoolProfile>> listAll();
  Future<void> delete(String id);
}
```

- [ ] analyze 该文件 0 error → 提交：
```bash
git add lib/domain/repositories/user_school_profile_repository.dart
git commit -m "feat(school): 用户流派仓储接口 + SavedSchoolProfile 领域模型"
```

---

## Task 2: data 侧实现（独占 DAO，映射行↔领域模型）

**Files:**
- Create: `lib/data/repositories/user_school_profile_repository_impl.dart`
- Test: `test/data/user_school_profile_repository_impl_test.dart`

**Step 1 失败测试**（内存库；断言 save→listAll 往返、config 保真、delete 后消失）：
```dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/data/datasources/local/app_database.dart';
import 'package:qizhengsiyu/data/repositories/user_school_profile_repository_impl.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';

void main() {
  test('save → listAll 往返，config 保真；delete 后消失', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final repo = UserSchoolProfileRepositoryImpl(db.userSchoolProfileDao);
    final id = await repo.save(
      name: '我的琴堂', school: '琴堂派', classicBook: '星学大成',
      config: BasePanelConfig.defaultBasicPanelConfig().copyWith(
          celestialCoordinateSystem: CelestialCoordinateSystem.SkyEquatorial),
    );
    final list = await repo.listAll();
    expect(list.length, 1);
    expect(list.first.name, '我的琴堂');
    expect(list.first.config.celestialCoordinateSystem,
        CelestialCoordinateSystem.SkyEquatorial);
    await repo.delete(id);
    expect((await repo.listAll()), isEmpty);
  });
}
```

**Step 2** 跑红。**Step 3 实现**（data 层，**允许** import DAO/AppDatabase）：
```dart
// lib/data/repositories/user_school_profile_repository_impl.dart
import 'package:uuid/uuid.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';
import 'package:qizhengsiyu/domain/repositories/user_school_profile_repository.dart';
import '../datasources/local/daos/user_school_profile_dao.dart';

class UserSchoolProfileRepositoryImpl implements UserSchoolProfileRepository {
  final UserSchoolProfileDao _dao;
  const UserSchoolProfileRepositoryImpl(this._dao);

  @override
  Future<String> save({
    required String name, required String school,
    required String classicBook, required BasePanelConfig config,
  }) async {
    final id = 'user_${const Uuid().v4()}';
    await _dao.upsert(
      uuid: id, name: name, school: school,
      classicBook: classicBook, config: config,
    );
    return id;
  }

  @override
  Future<List<SavedSchoolProfile>> listAll() async {
    final rows = await _dao.listAll();
    return rows
        .map((r) => SavedSchoolProfile(
              id: r.uuid, name: r.name, school: r.school,
              classicBook: r.classicBook, config: r.panelConfig,
            ))
        .toList();
  }

  @override
  Future<void> delete(String id) => _dao.softDelete(id);
}
```
> 核对：Drift 行类 `UserSchoolProfileTableData` 的 getter 名（`uuid`/`name`/`school`/`classicBook`/`panelConfig`）与实际生成一致；`panelConfig` 经 converter 已是 `BasePanelConfig`。不符则停下报用户。

**Step 4** 跑绿 → 提交：
```bash
git add lib/data/repositories/user_school_profile_repository_impl.dart test/data/user_school_profile_repository_impl_test.dart
git commit -m "feat(school): 用户流派仓储实现（data 层独占 DAO）"
```

---

## Task 3: service 改依赖接口 + DI 注册 + UI 经 Provider 取（清违规）

**Files:**
- Modify: `lib/domain/services/user_school_profile_service.dart`（**删** data import，改依赖接口）
- Modify: `lib/di.dart`（注册 `Provider<UserSchoolProfileRepository>`）
- Modify: `lib/presentation/pages/qi_zheng_si_yu_config_page.dart`（删 data import，改 `context.read`）
- Modify: `test/domain/services/user_school_profile_service_test.dart`（注入 fake repo 而非 AppDatabase）

**3a. service**（domain→domain，合规）：
```dart
// user_school_profile_service.dart —— 删掉 app_database / dao 两条 import，改为：
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';
import 'package:qizhengsiyu/domain/repositories/user_school_profile_repository.dart';

class UserSchoolProfileService {
  final UserSchoolProfileRepository _repo;
  const UserSchoolProfileService(this._repo);

  Future<String> saveCurrentAsProfile({
    required String name, required String school,
    required String classicBook, required BasePanelConfig config,
  }) => _repo.save(name: name, school: school, classicBook: classicBook, config: config);

  Future<List<SavedSchoolProfile>> listAll() => _repo.listAll();
  Future<void> delete(String id) => _repo.delete(id);
}
```
> service 测试改为传入手写 fake `UserSchoolProfileRepository`（内存 List 实现），去掉对 `AppDatabase` 的依赖。

**3b. di.dart**（`createProviders` 的 provider 列表里加，**lazy 默认**避免 bootstrap 触库）：
```dart
Provider<UserSchoolProfileRepository>(
  create: (_) => UserSchoolProfileRepositoryImpl(AppDatabase().userSchoolProfileDao),
),
```
顶部 import 接口 + 实现 + `AppDatabase`。
> 核对：`lib/di.dart` 是否被任何 `test/architecture/*` 扫描为 domain/UI（应为组合根、豁免）。若 `provider_bootstrap_test` 因新 provider 变红（fakeDeps 下触真库），改为在该 provider 用 `lazy: true` 或从 `deps` 取——**若 deps 无此项，停下报用户**（勿擅改 xuan-common）。

**3c. config 页**（line 11 删 `import '../../data/datasources/local/app_database.dart';`；line 604 改）：
```dart
final svc = UserSchoolProfileService(
    context.read<UserSchoolProfileRepository>());
```
顶部改 import 为 `package:provider/provider.dart`（若未导）+ 接口路径。

- [ ] 跑边界 + school 相关子集：
```
flutter test test/architecture/ test/domain/engines/school/ test/domain/services/user_school_profile_service_test.dart test/presentation/viewmodels/panel_config_viewmodel_school_test.dart
```
Expected: 4 个边界测试转绿；school 子集全绿。
- [ ] 提交：
```bash
git add lib/domain/services/user_school_profile_service.dart lib/di.dart lib/presentation/pages/qi_zheng_si_yu_config_page.dart test/domain/services/user_school_profile_service_test.dart
git commit -m "fix(school): 仓储接口缝解除 domain→data / UI→data 边界违规"
```

---

## Task 4: 全量收口 + 补提交 Task 9 金标

- [ ] `flutter analyze lib/`（0 error）
- [ ] **本计划唯一一次全量**：`flutter test` → 期望 `All tests passed!`、`-0` 失败。
- [ ] 补提交阶段二未落盘的金标（原 Task 9）：
```bash
git add test/domain/engines/school/school_orchestration_golden_test.dart
git commit -m "test(school): 流派套配金标 + 默认路径回归红线（补 Task 9）"
```
- [ ] `detect_changes({scope: "compare", base_ref: "main"})` 复核无意外扩散。
- [ ] 忽略 gitignore 产物 `example/assets/tmp/ge_ju_1_converted.json`，勿提交。

## DoD

- [ ] 4 个 `test/architecture/*` 边界测试全绿；`flutter test` 整体全绿、0 失败。
- [ ] domain / UI 层不再 import 任何 `data/` 符号（接口缝到位）。
- [ ] Task 9 金标已提交；`detect_changes` 无意外扩散。
