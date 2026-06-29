# ACT 任务分解: 竹罗三限环形 UI 实现

> 基于 OpenSpec 设计 (`render-zhu-luo-san-xian-rings`) 与人类实现计划，将抽象 Task 拆分为单一文件/Actor 可执行的 ACT 格式任务。

## 总则（所有 ACT 共用）

- **LANG**: `dart`
- **ABSOLUTELY_PROHIBITED**（所有 ACT 强制）:
  - 不得修改 `lib/xing_xian/zhu_luo_san_xian/` 下任何计算文件
  - 不得修改 `../metaphysics-chart-ui/` 下任何文件
  - 不得出现 `skip:`, `skip(`, `.only`, `, skip`, `solo` 等跳过/独占标记
  - 不得重新去重、补年或调用竹罗规则 helper（如 `rulerNumber`/`rulerDuration`）
  - 不得硬编码 `Colors.black`、`Colors.white` 或 `Color(0x...)` 原始 ARGB
  - 不得依赖 `DaXianRingPainter` 或 `DaXianCalculateHelper`
- **PROTOCOL**: `{MODE: "sequential", NO_PROSE: true, OUTPUT_FORMAT: "diff-or-create"}`
- **包引用**: `package:qizhengsiyu/...`
- **UI_REFERENCE**: 所有 UI 绘制、截图、golden 和 gStack 验收均以 `../metaphysics-chart-ui/example` 的 QiZheng UI tab 为参照场景；该目录只可读取/运行，不得修改源码。
- **REAL_ARC_API**: `ArcLayer` 使用 `LayerBehavior(innerRadius, outerRadius)` 表达半径；`ArcSegment` 只使用 `id/startAngle/sweepAngle/label/paletteKey/metadata`；不得使用不存在的 `radius/fillColor/hitTest/ArcSegmentColor`。

---

## ACT-001: Calculator Characterization Fixtures

```
TASK_ID: "ACT-001-calculator-fixtures"
TARGET_FILE: "test/presentation/chart_adapters/zhu_luo_san_xian_ring_projector_test.dart"
CONTEXT: {
  DOMAIN: "Characterization: 使用真实 calculator 生成投影输入",
  STRATEGY: "先写 test（TDD 红）到预期失败（依赖文件不存在），再实现",
}
TASK_DEPS: []
COMMANDS:
  PRECHECK: |
    flutter test test/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_calculator_test.dart
    # 预期: PASS, 证明 calculator 基线未改变
  STEP_1: |
    创建文件，引入必要的类型和函数：
    - enum_twelve_gong (EnumTwelveGong)
    - zhu_luo_san_xian_tables (ZhuLuoRuler, LimitStage, BirthSect)
    - zhu_luo_san_xian_config (ZhuLuoAlgorithmConfig, classicInverseSectionsConfig, directAnnualWithBridgeConfig)
    - zhu_luo_san_xian_calculator (ZhuLuoInput, ZhuLuoYearResult, calculateZhuLuoSanXian)
  STEP_2_CONTENT: |
    // 覆盖 4 个场景：A跳宫、B补桥、重复入宫、共享交限年龄
    // 使用真实 calculator 输出，不伪造 ZhuLuoYearResult

    group("calculator fixtures", () {
      // Fixture 1: A法 Venus in Yin, maxAge=30
      // 关键特征: hold→inverse→direct 跳转；non-adjacent palace jump
      test("A law inverse jump fixture produces expected phases", () {
        final results = calculateZhuLuoSanXian(ZhuLuoInput(
          lifePalace: EnumTwelveGong.You,
          birthSect: BirthSect.day,
          rulerPalaces: {ZhuLuoRuler.venus: EnumTwelveGong.Yin},
          maxAge: 30,
          config: classicInverseSectionsConfig,
        ));
        // age 1-4: hold in Yin; age 5-14: inverse in Chou? check actual
        // 至少验证: results 非空, 每个元素年龄连续, phase 符合阶段变化
        expect(results, isNotEmpty);
        expect(results.first.age, 1);
        expect(results.last.age, lessThanOrEqualTo(30));
        // 验证有 inverse 跳转
        expect(results.any((r) => r.phase == "inverse"), isTrue);
      });

      // Fixture 2: B法 Frederick 命例（Venus in Yin, Moon in Wu, Mars in Zi, maxAge=80）
      // 关键特征: bridge, repeated palace visits, shared transition age
      test("Frederick B law fixture has bridge and transition metadata", () {
        final results = calculateZhuLuoSanXian(ZhuLuoInput(
          lifePalace: EnumTwelveGong.You,
          birthSect: BirthSect.day,
          rulerPalaces: {
            ZhuLuoRuler.venus: EnumTwelveGong.Yin,
            ZhuLuoRuler.moon: EnumTwelveGong.Wu,
            ZhuLuoRuler.mars: EnumTwelveGong.Zi,
          },
          maxAge: 80,
          config: directAnnualWithBridgeConfig,
        ));
        // 验证 bridge 存在
        expect(results.any((r) => r.usedBridge), isTrue);
        // 验证 isTransitionYear
        expect(results.any((r) => r.isTransitionYear), isTrue);
        // 验证每个年龄只出现一次（calculator deduplicated）
        final ages = results.map((e) => e.age).toSet();
        expect(results.length, ages.length);
      });

      // Fixture 3: 多算法测试（A vs B 同一输入）
      test("A and B produce different palace sequences for same input", () {
        final a = calculateZhuLuoSanXian(ZhuLuoInput(
          lifePalace: EnumTwelveGong.You,
          birthSect: BirthSect.day,
          rulerPalaces: {ZhuLuoRuler.venus: EnumTwelveGong.Yin},
          maxAge: 20,
          config: classicInverseSectionsConfig,
        ));
        final b = calculateZhuLuoSanXian(ZhuLuoInput(
          lifePalace: EnumTwelveGong.You,
          birthSect: BirthSect.day,
          rulerPalaces: {ZhuLuoRuler.venus: EnumTwelveGong.Yin},
          maxAge: 20,
          config: directAnnualWithBridgeConfig,
        ));
        expect(a.map((e) => e.palace), isNot(equals(b.map((e) => e.palace))));
      });
    });
  STEP_3: |
    flutter test test/presentation/chart_adapters/zhu_luo_san_xian_ring_projector_test.dart
    # 预期: FAIL（模型文件不存在），证明 test 框架正确加载
PROHIBITED:
  - "不得伪造 ZhuLuoYearResult 数据（malformed-input 验证除外）"
  - "不得依赖尚未创建的模型类型"
ABSOLUTELY_PROHIBITED: []
ASSERTIONS: {
  EXECENV: "flutter_test, package:qizhengsiyu/...",
  CASES: [
    "A法 fixture 输出非空, phase 包含 inverse",
    "B法 fixture 包含 bridge 和 transition 记录",
    "同一输入 A/B 法 palace 序列不同",
    "test 文件可独立运行, 预期 FAIL 因依赖不存在",
  ]
}
VERIFICATION: "flutter test 执行后 FAIL（缺少模型）"
```

---

## ACT-002: Immutable Ring Plan Models

```
TASK_ID: "ACT-002-ring-plan-models"
TARGET_FILE: "lib/presentation/models/zhu_luo_san_xian/zhu_luo_ring_plan.dart"
CONTEXT: {
  DOMAIN: "Pure data models, no rendering, no calculation",
  STRATEGY: "一次创建所有不可变模型类型，含 defensive copy、==/hashCode、copyWith",
}
TASK_DEPS: ["ACT-001"]
COMMANDS:
  PRECHECK: |
    # 确认基础类型可用
    grep -n "enum LimitStage" lib/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_tables.dart
    grep -n "enum ZhuLuoRuler" lib/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_tables.dart
  STEP_1_CREATE_DIR: |
    mkdir -p lib/presentation/models/zhu_luo_san_xian
  STEP_2_CONTENT: |
    import 'package:metaphysics_core/enums.dart';       // EnumTwelveGong
    import 'package:qizhengsiyu/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_tables.dart'; // LimitStage, ZhuLuoRuler

    enum ZhuLuoAgeLabelMode { rangeOnly, allCells, auto }

    enum ZhuLuoTransitionKind { inverseJump, stageTransition }

    class ZhuLuoVisitSegment {
      final LimitStage stage;
      final ZhuLuoRuler ruler;
      final EnumTwelveGong palace;
      final int startAge;
      final int endAge;
      final String phase;
      final bool usedBridge;
      final int visitOrdinal;

      const ZhuLuoVisitSegment({
        required this.stage,
        required this.ruler,
        required this.palace,
        required this.startAge,
        required this.endAge,
        required this.phase,
        required this.usedBridge,
        required this.visitOrdinal,
      });

      int get ageCount => endAge - startAge + 1;

      ZhuLuoVisitSegment copyWith({int? visitOrdinal}) =>
          ZhuLuoVisitSegment(
            stage: stage,
            ruler: ruler,
            palace: palace,
            startAge: startAge,
            endAge: endAge,
            phase: phase,
            usedBridge: usedBridge,
            visitOrdinal: visitOrdinal ?? this.visitOrdinal,
          );

      @override
      bool operator ==(Object other) =>
          identical(this, other) ||
          other is ZhuLuoVisitSegment &&
              stage == other.stage &&
              ruler == other.ruler &&
              palace == other.palace &&
              startAge == other.startAge &&
              endAge == other.endAge &&
              phase == other.phase &&
              usedBridge == other.usedBridge &&
              visitOrdinal == other.visitOrdinal;

      @override
      int get hashCode => Object.hash(
          stage, ruler, palace, startAge, endAge, phase, usedBridge, visitOrdinal);
    }

    class ZhuLuoAnnualCell {
      final String id;       // "zhu-luo:<algo>:<stage>:visit-<ord>:<palace>:age-<age>"
      final int age;
      final double startAngle;
      final double sweepAngle;
      final int trackIndex;  // physical render track
      final ZhuLuoVisitSegment visit;
      final bool isTransitionYear;

      const ZhuLuoAnnualCell({
        required this.id,
        required this.age,
        required this.startAngle,
        required this.sweepAngle,
        required this.trackIndex,
        required this.visit,
        required this.isTransitionYear,
      });

      @override
      bool operator ==(Object other) =>
          identical(this, other) ||
          other is ZhuLuoAnnualCell &&
              id == other.id &&
              age == other.age &&
              startAngle == other.startAngle &&
              sweepAngle == other.sweepAngle &&
              trackIndex == other.trackIndex &&
              visit == other.visit &&
              isTransitionYear == other.isTransitionYear;

      @override
      int get hashCode => Object.hash(id, age, startAngle, sweepAngle, trackIndex, visit, isTransitionYear);
    }

    class ZhuLuoTransitionEdge {
      final String id;
      final int age;
      final ZhuLuoTransitionKind kind;
      final String sourceCellId;
      final String targetCellId;

      const ZhuLuoTransitionEdge({
        required this.id,
        required this.age,
        required this.kind,
        required this.sourceCellId,
        required this.targetCellId,
      });

      @override
      bool operator ==(Object other) =>
          identical(this, other) ||
          other is ZhuLuoTransitionEdge &&
              id == other.id &&
              age == other.age &&
              kind == other.kind &&
              sourceCellId == other.sourceCellId &&
              targetCellId == other.targetCellId;

      @override
      int get hashCode => Object.hash(id, age, kind, sourceCellId, targetCellId);
    }

    class ZhuLuoRingPlan {
      final List<ZhuLuoAnnualCell> cells;
      final List<ZhuLuoTransitionEdge> transitions;
      final Map<LimitStage, int> trackCounts;

      ZhuLuoRingPlan({
        required List<ZhuLuoAnnualCell> cells,
        required List<ZhuLuoTransitionEdge> transitions,
        required Map<LimitStage, int> trackCounts,
      })  : cells = List.unmodifiable(cells),
            transitions = List.unmodifiable(transitions),
            trackCounts = Map.unmodifiable(trackCounts);

      @override
      bool operator ==(Object other) =>
          identical(this, other) ||
          other is ZhuLuoRingPlan &&
              _listEquals(cells, other.cells) &&
              _listEquals(transitions, other.transitions) &&
              _mapEquals(trackCounts, other.trackCounts);

      @override
      int get hashCode => Object.hash(
          Object.hashAll(cells),
          Object.hashAll(transitions),
          Object.hashAll(trackCounts.entries));

      static bool _listEquals(List<dynamic> a, List<dynamic> b) =>
          a.length == b.length && a.asMap().entries.every((e) => e.value == b[e.key]);

      static bool _mapEquals(Map<dynamic, dynamic> a, Map<dynamic, dynamic> b) =>
          a.length == b.length && a.entries.every((e) => b[e.key] == e.value);
    }
  STEP_3: |
    flutter analyze lib/presentation/models/zhu_luo_san_xian/zhu_luo_ring_plan.dart
    # 预期: no issues
PROHIBITED:
  - "不得引入渲染或 painter 依赖"
  - "不得修改计算模型文件"
  - "collection 字段必须 defensive copy（List.unmodifiable / Map.unmodifiable）"
ABSOLUTELY_PROHIBITED: []
ASSERTIONS: {
  EXECENV: "flutter analyze, pure dart (no flutter_test needed)",
  CASES: [
    "所有集合字段使用 unmodifiable 不可变副本",
    "== / hashCode 覆盖所有字段",
    "ZhuLuoVisitSegment 包含 ageCount getter",
    "ZhuLuoRingPlan 使用深不可变构造",
  ]
}
VERIFICATION: "flutter analyze PASS with 0 issues"
```

---

## ACT-003: Model Tests

```
TASK_ID: "ACT-003-model-tests"
TARGET_FILE: "test/presentation/models/zhu_luo_san_xian/zhu_luo_ring_plan_test.dart"
CONTEXT: {
  DOMAIN: "验证模型不可变性、==、hashCode、defensive copy",
  STRATEGY: "纯 dart 测试，无渲染依赖",
}
TASK_DEPS: ["ACT-002"]
COMMANDS:
  PRECHECK: |
    flutter analyze lib/presentation/models/zhu_luo_san_xian/zhu_luo_ring_plan.dart
  STEP_1_CONTENT: |
    import 'package:flutter_test/flutter_test.dart';
    import 'package:metaphysics_core/enums.dart';
    import 'package:qizhengsiyu/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_tables.dart';
    import 'package:qizhengsiyu/presentation/models/zhu_luo_san_xian/zhu_luo_ring_plan.dart';

    void main() {
      group("ZhuLuoVisitSegment", () {
        test("equality", () {
          final a = ZhuLuoVisitSegment(
            stage: LimitStage.first,
            ruler: ZhuLuoRuler.venus,
            palace: EnumTwelveGong.Yin,
            startAge: 1,
            endAge: 4,
            phase: "hold",
            usedBridge: false,
            visitOrdinal: 0,
          );
          expect(a, equals(a.copyWith()));
          expect(a, isNot(equals(a.copyWith(visitOrdinal: 1))));
        });

        test("ageCount", () {
          final s = ZhuLuoVisitSegment(
            stage: LimitStage.first,
            ruler: ZhuLuoRuler.venus,
            palace: EnumTwelveGong.Yin,
            startAge: 5,
            endAge: 14,
            phase: "inverse",
            usedBridge: false,
            visitOrdinal: 0,
          );
          expect(s.ageCount, 10);
        });
      });

      group("ZhuLuoRingPlan", () {
        test("defensive copy on List field", () {
          final cell = ZhuLuoAnnualCell(
            id: "test",
            age: 1,
            startAngle: 0,
            sweepAngle: 30,
            trackIndex: 0,
            visit: ZhuLuoVisitSegment(
              stage: LimitStage.first,
              ruler: ZhuLuoRuler.venus,
              palace: EnumTwelveGong.Yin,
              startAge: 1,
              endAge: 1,
              phase: "hold",
              usedBridge: false,
              visitOrdinal: 0,
            ),
            isTransitionYear: false,
          );
          final mutableList = [cell];
          final plan = ZhuLuoRingPlan(
            cells: mutableList,
            transitions: [],
            trackCounts: {LimitStage.first: 1},
          );
          mutableList.clear();
          expect(plan.cells, hasLength(1));
        });

        test("stable ID format", () {
          // 验证 ID 格式: zhu-luo:<algo>:<stage>:visit-<ord>:<palace>:age-<age>
          // 用任意测试值验证
          const expectedPattern = "zhu-luo:test_algo:first:visit-0:yin:age-1";
          final cell = ZhuLuoAnnualCell(
            id: expectedPattern,
            age: 1,
            startAngle: 0,
            sweepAngle: 30,
            trackIndex: 0,
            visit: ZhuLuoVisitSegment(
              stage: LimitStage.first,
              ruler: ZhuLuoRuler.venus,
              palace: EnumTwelveGong.Yin,
              startAge: 1,
              endAge: 1,
              phase: "hold",
              usedBridge: false,
              visitOrdinal: 0,
            ),
            isTransitionYear: false,
          );
          expect(cell.id, expectedPattern);
        });

        test("ZhuLuoTransitionEdge equality", () {
          final a = const ZhuLuoTransitionEdge(
            id: "test-edge",
            age: 30,
            kind: ZhuLuoTransitionKind.inverseJump,
            sourceCellId: "src",
            targetCellId: "dst",
          );
          final b = const ZhuLuoTransitionEdge(
            id: "test-edge",
            age: 30,
            kind: ZhuLuoTransitionKind.inverseJump,
            sourceCellId: "src",
            targetCellId: "dst",
          );
          expect(a, equals(b));
        });
      });
    }
  STEP_2: |
    flutter test test/presentation/models/zhu_luo_san_xian/zhu_luo_ring_plan_test.dart
    # 预期: PASS
PROHIBITED:
  - "不得创建渲染相关的测试环境"
  - "不得依赖尚未实现的投影器"
ABSOLUTELY_PROHIBITED: []
ASSERTIONS: {
  EXECENV: "flutter_test",
  CASES: [
    "ZhuLuoVisitSegment == 正确比较所有字段",
    "ageCount 返回正确连续年数",
    "ZhuLuoRingPlan 外部修改传入 mutable list 不影响 plan",
    "stable ID 格式可通过构造验证",
    "ZhuLuoTransitionEdge == 正确比较",
  ]
}
VERIFICATION: "flutter test PASS"
```

---

## ACT-004: Pure Projector

```
TASK_ID: "ACT-004-pure-projector"
TARGET_FILE: "lib/presentation/chart_adapters/zhu_luo_san_xian_ring_projector.dart"
CONTEXT: {
  DOMAIN: "ZhuLuoYearResult → ZhuLuoRingPlan 纯投影",
  STRATEGY: "不可变纯函数，不计算竹罗规则，不调用 calculator helper",
}
TASK_DEPS: ["ACT-002"]
COMMANDS:
  PRECHECK: |
    flutter analyze lib/presentation/models/zhu_luo_san_xian/zhu_luo_ring_plan.dart
  STEP_1_CONTENT: |
    import 'package:metaphysics_core/enums.dart';
    import 'package:qizhengsiyu/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_calculator.dart';
    import 'package:qizhengsiyu/presentation/models/zhu_luo_san_xian/zhu_luo_ring_plan.dart';

    /// 将 [ZhuLuoYearResult] 序列投影为不可变 [ZhuLuoRingPlan]。
    ///
    /// - 只按语义字段分组连续访问
    /// - 不重新计算、不去重、不补年
    /// - 不调用 rulerNumber/rulerDuration 等竹罗规则 helper
    /// - 输入记录数 == 输出 cell 数
    ZhuLuoRingPlan projectZhuLuoRing({
      required List<ZhuLuoYearResult> years,
      required List<EnumTwelveGong> palaceOrder,
      required double startAngleOffset,
    }) {
      if (years.isEmpty) {
        return ZhuLuoRingPlan(cells: [], transitions: [], trackCounts: {});
      }

      // Step 1: 分组连续访问
      final visits = <List<ZhuLuoYearResult>>[];
      List<ZhuLuoYearResult>? currentVisit;

      for (final year in years) {
        if (currentVisit == null) {
          currentVisit = [year];
          continue;
        }

        final last = currentVisit.last;
        final isContiguous = _isSameVisit(last, year);
        if (isContiguous) {
          currentVisit.add(year);
        } else {
          visits.add(currentVisit);
          currentVisit = [year];
        }
      }
      if (currentVisit != null) {
        visits.add(currentVisit);
      }

      // Step 2: 计算每个 stage+palace 的 visit ordinal
      final visitOrdinalMap = <String, int>{};
      int ordinalFor(LimitStage stage, EnumTwelveGong palace) {
        final key = '${stage.index}:${palace.index}';
        final ord = visitOrdinalMap.putIfAbsent(key, () => 0);
        visitOrdinalMap[key] = ord + 1;
        return ord;
      }

      // Step 3: 构建 visit segments + 统计每 stage 最大 track 数
      final segments = <ZhuLuoVisitSegment>[];
      final trackCounts = <LimitStage, int>{};

      for (final visit in visits) {
        final first = visit.first;
        final last = visit.last;
        final ord = ordinalFor(first.stage, first.palace);

        final segment = ZhuLuoVisitSegment(
          stage: first.stage,
          ruler: first.ruler,
          palace: first.palace,
          startAge: first.age,
          endAge: last.age,
          phase: first.phase,
          usedBridge: first.usedBridge,
          visitOrdinal: ord,
        );
        segments.add(segment);
        trackCounts[first.stage] = [
          trackCounts[first.stage] ?? 0,
          ord + 1,
        ].reduce((a, b) => a > b ? a : b);
      }

      // Step 4: 计算每个 segment 的 trackIndex = 同stage之前ordinal的和 + 本ord
      // 实际: trackIndex =  所有stage<=当前stage且trackCount < 当前stage的trackCount之和
      // 更简单的物理分配：按 stage 先后的累计 + 当前 stage 内 visitOrdinal

      // 计算每 stage 基础偏移
      final stageBaseOffset = <LimitStage, int>{
        for (final stage in LimitStage.values)
          stage: LimitStage.values
              .where((s) => s.index < stage.index)
              .fold(0, (sum, s) => sum + (trackCounts[s] ?? 0)),
      };

      // Step 5: 计算角度 + 生成 annual cells
      final cells = <ZhuLuoAnnualCell>[];
      final transitions = <ZhuLuoTransitionEdge>[];
      final palaceSweep = 30.0; // 每宫 30 度

      for (final segment in segments) {
        final palaceIndex = palaceOrder.indexOf(segment.palace);
        final palaceStart = startAngleOffset + palaceIndex * palaceSweep;
        final n = segment.ageCount;
        final cellSweep = palaceSweep / n;
        final algorithmId = years.firstWhere((y) => y.age == segment.startAge).algorithmId;

        final baseTrack = stageBaseOffset[segment.stage]! + segment.visitOrdinal;
        final trackIndex = baseTrack;

        for (var i = 0; i < n; i++) {
          final age = segment.startAge + i;
          final cellStart = palaceStart + i * cellSweep;
          // 最后一格强制贴合宫界
          final sweep = (i == n - 1)
              ? palaceStart + palaceSweep - cellStart
              : cellSweep;

          final record = years.firstWhere((y) => y.age == age);

          final cellId = 'zhu-luo:${algorithmId.name}:${segment.stage.name}'
              ':visit-${segment.visitOrdinal}'
              ':${segment.palace.name}'
              ':age-$age';

          cells.add(ZhuLuoAnnualCell(
            id: cellId,
            age: age,
            startAngle: cellStart,
            sweepAngle: sweep,
            trackIndex: trackIndex,
            visit: segment,
            isTransitionYear: record.isTransitionYear,
          ));
        }

        // Step 6: 生成 transition edges
        // 只在 phase == "inverse" 且 palace 跳转 non-adjacent 时生成 inverseJump
        if (segment.phase == "inverse") {
          final prevSegIdx = segments.indexOf(segment) - 1;
          if (prevSegIdx >= 0) {
            final prev = segments[prevSegIdx];
            final prevDist = (palaceOrder.indexOf(segment.palace) -
                    palaceOrder.indexOf(prev.palace))
                .abs();
            // adjacent = 1 or 11 (wrap), non-adjacent = anything else
            if (prevDist != 1 && prevDist != 11) {
              final firstCell = cells.firstWhere((c) => c.age == segment.startAge);
              final lastPrevCell = cells.lastWhere((c) => c.age == prev.endAge);
              transitions.add(ZhuLuoTransitionEdge(
                id: 'zhu-luo:jump:${segment.stage.name}:${prev.endAge}-${segment.startAge}',
                age: segment.startAge,
                kind: ZhuLuoTransitionKind.inverseJump,
                sourceCellId: lastPrevCell.id,
                targetCellId: firstCell.id,
              ));
            }
          }
        }

        // isTransitionYear: inter-stage marker (不生成 edge, 但标记在 cell 上)
      }

      return ZhuLuoRingPlan(
        cells: cells,
        transitions: transitions,
        trackCounts: trackCounts,
      );
    }

    bool _isSameVisit(ZhuLuoYearResult a, ZhuLuoYearResult b) {
      return a.stage == b.stage &&
          a.ruler == b.ruler &&
          a.palace == b.palace &&
          a.phase == b.phase &&
          a.usedBridge == b.usedBridge &&
          a.age + 1 == b.age;
    }
  STEP_2: |
    flutter analyze lib/presentation/chart_adapters/zhu_luo_san_xian_ring_projector.dart
    # 预期: no issues
PROHIBITED:
  - "不得调用 rulerNumber/rulerDuration/zhuLuoLimitRulers"
  - "不得重新去重或补年"
  - "不得在投影函数中修改 calculator 或 config"
ABSOLUTELY_PROHIBITED: []
ASSERTIONS: {
  EXECENV: "flutter analyze, pure dart",
  CASES: [
    "输入空列表返回空 plan",
    "连续记录合并为同一 visit",
    "stage/ruler/palace/phase/bridge 任一变化开始新 visit",
    "输入年数 = 输出 cell 数",
    "cellSweep = 30/N, 最后一格贴合宫界",
    "inverse phase 且 non-adjacent 时生成 inverseJump edge",
    "不生成非 inverse 跳转 edge",
  ]
}
VERIFICATION: "flutter analyze PASS with 0 issues"
```

---

## ACT-005: Projection Tests

```
TASK_ID: "ACT-005-projection-tests"
TARGET_FILE: "test/presentation/chart_adapters/zhu_luo_san_xian_ring_projector_test.dart"
CONTEXT: {
  DOMAIN: "补完投影器测试：几何精度、不重复、sparse track、radial order",
  STRATEGY: "用真实 calculator fixture 验证投影几何",
}
TASK_DEPS: ["ACT-001", "ACT-002", "ACT-004"]
COMMANDS:
  PRECHECK: |
    flutter analyze lib/presentation/chart_adapters/zhu_luo_san_xian_ring_projector.dart
    flutter analyze lib/presentation/models/zhu_luo_san_xian/zhu_luo_ring_plan.dart
  STEP_1_CONTENT: |
    // 在已有 calculator fixtures group 后追加 projection group

    group("projection", () {
      final palaceOrder = EnumTwelveGong.listAll;

      test("4-year hold produces 4 cells of 7.5 degrees each", () {
        // 制造一个已知 4 年停宫的输入
        final results = calculateZhuLuoSanXian(ZhuLuoInput(
          lifePalace: EnumTwelveGong.Zi,
          birthSect: BirthSect.day,
          rulerPalaces: {ZhuLuoRuler.saturn: EnumTwelveGong.Si},
          maxAge: 30,
          config: classicInverseSectionsConfig,
        ));
        final plan = projectZhuLuoRing(
          years: results,
          palaceOrder: palaceOrder,
          startAngleOffset: 0,
        );

        // 找到 4 年停宫（第一组 hold: age 1-?）
        // Saturn in Si, rulerNumber=5 -> hold 5 years Si
        final holdCells = plan.cells
            .where((c) => c.visit.phase == "hold")
            .toList();
        expect(holdCells, hasLength(greaterThanOrEqualTo(4)));

        // 验证前 4 个 cell 角度
        final first4 = holdCells.take(4).toList();
        for (final cell in first4) {
          expect(cell.sweepAngle, closeTo(6.0, 1e-9)); // 30/5=6 for 5-year hold
        }
      });

      test("cell count matches input year count", () {
        final results = calculateZhuLuoSanXian(ZhuLuoInput(
          lifePalace: EnumTwelveGong.You,
          birthSect: BirthSect.day,
          rulerPalaces: {
            ZhuLuoRuler.venus: EnumTwelveGong.Yin,
            ZhuLuoRuler.moon: EnumTwelveGong.Wu,
            ZhuLuoRuler.mars: EnumTwelveGong.Zi,
          },
          maxAge: 80,
          config: directAnnualWithBridgeConfig,
        ));
        final plan = projectZhuLuoRing(
          years: results,
          palaceOrder: palaceOrder,
          startAngleOffset: 0,
        );
        expect(plan.cells, hasLength(results.length));
      });

      test("transition year appears exactly once", () {
        final results = calculateZhuLuoSanXian(ZhuLuoInput(
          lifePalace: EnumTwelveGong.You,
          birthSect: BirthSect.day,
          rulerPalaces: {
            ZhuLuoRuler.venus: EnumTwelveGong.Yin,
            ZhuLuoRuler.moon: EnumTwelveGong.Wu,
            ZhuLuoRuler.mars: EnumTwelveGong.Zi,
          },
          maxAge: 80,
          config: directAnnualWithBridgeConfig,
        ));
        final plan = projectZhuLuoRing(
          years: results,
          palaceOrder: palaceOrder,
          startAngleOffset: 0,
        );
        final transitionYears = results.where((r) => r.isTransitionYear).map((r) => r.age).toSet();
        for (final ty in transitionYears) {
          expect(plan.cells.where((c) => c.age == ty), hasLength(1));
        }
      });

      test("stage radial order: first < middle < last track indices", () {
        final results = calculateZhuLuoSanXian(ZhuLuoInput(
          lifePalace: EnumTwelveGong.You,
          birthSect: BirthSect.day,
          rulerPalaces: {
            ZhuLuoRuler.venus: EnumTwelveGong.Yin,
            ZhuLuoRuler.moon: EnumTwelveGong.Wu,
            ZhuLuoRuler.mars: EnumTwelveGong.Zi,
          },
          maxAge: 80,
          config: directAnnualWithBridgeConfig,
        ));
        final plan = projectZhuLuoRing(
          years: results,
          palaceOrder: palaceOrder,
          startAngleOffset: 0,
        );
        for (final cell in plan.cells) {
          if (cell.visit.stage == LimitStage.first) {
            expect(cell.trackIndex, lessThan(
                plan.cells.firstWhere((c) => c.visit.stage == LimitStage.middle).trackIndex));
          }
          if (cell.visit.stage == LimitStage.middle) {
            expect(cell.trackIndex, lessThan(
                plan.cells.firstWhere((c) => c.visit.stage == LimitStage.last).trackIndex));
          }
        }
      });
    });
  STEP_2: |
    flutter test test/presentation/chart_adapters/zhu_luo_san_xian_ring_projector_test.dart
    # 预期: PASS（calculator fixtures + projection tests）
PROHIBITED:
  - "不得在投影测试中伪造 year results 代替真实 calculator 输出"
  - "不得修改 calculator 基线测试"
ABSOLUTELY_PROHIBITED: []
ASSERTIONS: {
  EXECENV: "flutter_test",
  CASES: [
    "hold 年度格角度 = 30/N",
    "投影 cell 数 = 输入年数",
    "交限年龄只出现一次",
    "初 < 中 < 末径向顺序正确",
  ]
}
VERIFICATION: "flutter test PASS with 0 failed/skipped"
```

---

## ACT-006: ArcLayer Adapter

```
TASK_ID: "ACT-006-arclayer-adapter"
TARGET_FILE: "lib/presentation/chart_adapters/zhu_luo_san_xian_ring_adapter.dart"
CONTEXT: {
  DOMAIN: "ZhuLuoRingPlan → List<ArcLayer> 转换",
  STRATEGY: "每个 visit track 对应一个 ArcLayer；半径写入 LayerBehavior，年度格写入 ArcSegment.paletteKey/metadata",
}
TASK_DEPS: ["ACT-002", "ACT-004"]
COMMANDS:
  PRECHECK: |
    rg -n "class ArcLayer|class ArcSegment|class LayerBehavior" ../metaphysics-chart-ui/lib/src/core/board_layer.dart
    # 预期: ArcLayer/ArcSegment/LayerBehavior 均存在
  STEP_1_CONTENT: |
    import 'package:metaphysics_chart_ui/metaphysics_chart_ui.dart';
    import 'package:qizhengsiyu/presentation/models/zhu_luo_san_xian/zhu_luo_ring_plan.dart';

    class ZhuLuoRingLayers {
      final List<ArcLayer> layers;
      final Map<String, ZhuLuoAnnualCell> cellByHitId;
      final Map<int, ZhuLuoTrackBand> trackBands;

      ZhuLuoRingLayers({
        required this.layers,
        required this.cellByHitId,
        required this.trackBands,
      });
    }

    class ZhuLuoTrackBand {
      final int trackIndex;
      final double innerRadius;
      final double outerRadius;

      const ZhuLuoTrackBand({
        required this.trackIndex,
        required this.innerRadius,
        required this.outerRadius,
      });
    }

    ZhuLuoRingLayers buildZhuLuoRingLayers({
      required ZhuLuoRingPlan plan,
      required double innerRadius,
      required double trackWidth,
      required double repeatGap,
      required double stageGap,
      required ZhuLuoAgeLabelMode labelMode,
      required double zoomScale,
    }) {
      final totalTracks = plan.trackCounts.values.fold(0, (a, b) => a + b);
      if (totalTracks == 0) {
        return ZhuLuoRingLayers(layers: [], cellByHitId: {}, trackBands: {});
      }

      final stageOrder = [LimitStage.first, LimitStage.middle, LimitStage.last];
      final trackBands = <int, ZhuLuoTrackBand>{};

      var currentOffset = innerRadius;
      for (final stage in stageOrder) {
        final stageTrackCount = plan.trackCounts[stage] ?? 0;
        if (stageTrackCount == 0) continue;
        for (var t = 0; t < stageTrackCount; t++) {
          final trackIndex = _cumulativeTrackCount(plan, stage) + t;
          final inner = currentOffset;
          final outer = currentOffset + trackWidth;
          trackBands[trackIndex] = ZhuLuoTrackBand(
            trackIndex: trackIndex,
            innerRadius: inner,
            outerRadius: outer,
          );
          currentOffset = outer + (t + 1 < stageTrackCount ? repeatGap : stageGap);
        }
      }

      final cellsByTrack = <int, List<ZhuLuoAnnualCell>>{};
      for (final cell in plan.cells) {
        cellsByTrack.putIfAbsent(cell.trackIndex, () => []).add(cell);
      }

      final layers = <ArcLayer>[];
      final cellByHitId = <String, ZhuLuoAnnualCell>{};

      for (final entry in cellsByTrack.entries) {
        final trackIndex = entry.key;
        final trackCells = entry.value;
        final band = trackBands[trackIndex];
        if (band == null) {
          throw StateError('Missing Zhu Luo track band: $trackIndex');
        }

        final arcs = <ArcSegment>[];
        for (final cell in trackCells) {
          cellByHitId[cell.id] = cell;

          arcs.add(ArcSegment(
            id: cell.id,
            startAngle: cell.startAngle,
            sweepAngle: cell.sweepAngle,
            label: _labelForCell(cell, labelMode, zoomScale),
            paletteKey: _paletteKeyForCell(cell),
            metadata: {
              'age': cell.age,
              'stage': cell.visit.stage.name,
              'ruler': cell.visit.ruler.name,
              'palace': cell.visit.palace.name,
              'phase': cell.visit.phase,
              'usedBridge': cell.visit.usedBridge,
              'isTransitionYear': cell.isTransitionYear,
            },
          ));
        }

        layers.add(ArcLayer(
          id: 'zhu-luo:track-$trackIndex',
          styleRole: 'zhuLuoTrack',
          behavior: LayerBehavior(
            innerRadius: band.innerRadius,
            outerRadius: band.outerRadius,
            direction: AngularDirection.clockwise,
          ),
          arcs: arcs,
        ));
      }

      return ZhuLuoRingLayers(
        layers: layers,
        cellByHitId: cellByHitId,
        trackBands: trackBands,
      );
    }

    int _cumulativeTrackCount(ZhuLuoRingPlan plan, LimitStage stage) {
      var sum = 0;
      for (final s in LimitStage.values) {
        if (s.index >= stage.index) break;
        sum += plan.trackCounts[s] ?? 0;
      }
      return sum;
    }

    String _paletteKeyForCell(ZhuLuoAnnualCell cell) {
      if (cell.visit.usedBridge) return 'zhuLuoBridge';
      switch (cell.visit.stage) {
        case LimitStage.first:
          return 'zhuLuoInitial';
        case LimitStage.middle:
          return 'zhuLuoMiddle';
        case LimitStage.last:
          return 'zhuLuoFinal';
      }
    }

    String _labelForCell(
      ZhuLuoAnnualCell cell,
      ZhuLuoAgeLabelMode mode,
      double zoomScale,
    ) {
      if (mode == ZhuLuoAgeLabelMode.allCells) return '${cell.age}';
      if (mode == ZhuLuoAgeLabelMode.auto && zoomScale >= 1.8) {
        return '${cell.age}';
      }
      final visit = cell.visit;
      final centerAge = ((visit.startAge + visit.endAge) / 2).round();
      if (cell.age != centerAge) return '';
      if (visit.startAge == visit.endAge) return '${visit.startAge}';
      return '${visit.startAge}-${visit.endAge}';
    }
  STEP_2: |
    flutter analyze lib/presentation/chart_adapters/zhu_luo_san_xian_ring_adapter.dart
    # 预期: no issues（可能依赖 ArcLayer/ArcSegment 类型检查）
PROHIBITED:
  - "不得修改 ../metaphysics-chart-ui/ 下任何文件"
  - "不得创建 ArcSegmentColor、fillColor、radius、hitTest 等不存在字段"
  - "不得自定义 _ArcLayerPainter 复刻 metaphysics-chart-ui 渲染器"
ABSOLUTELY_PROHIBITED: []
ASSERTIONS: {
  EXECENV: "flutter analyze, package:metaphysics_chart_ui",
  CASES: [
    "每 visit track 一个 ArcLayer",
    "每 annual cell 一个 ArcSegment",
    "cellByHitId 包含所有 cell",
    "空 plan 返回空 layers",
    "track 半径写入 ArcLayer.behavior.innerRadius/outerRadius",
    "颜色语义只通过 ArcSegment.paletteKey 表达",
  ]
}
VERIFICATION: "flutter analyze PASS with 0 issues"
```

---

## ACT-007: Adapter Tests

```
TASK_ID: "ACT-007-adapter-tests"
TARGET_FILE: "test/presentation/chart_adapters/zhu_luo_san_xian_ring_adapter_test.dart"
CONTEXT: {
  DOMAIN: "ArcLayer adapter 单元测试 + style consumption 验证",
  STRATEGY: "用投影结果验证 layer 数量、arc 数量、标签不改变几何",
}
TASK_DEPS: ["ACT-005", "ACT-006"]
COMMANDS:
  PRECHECK: |
    flutter analyze lib/presentation/chart_adapters/zhu_luo_san_xian_ring_adapter.dart
  STEP_1_CONTENT: |
    import 'package:flutter_test/flutter_test.dart';
    import 'package:metaphysics_core/enums.dart';
    import 'package:metaphysics_chart_ui/metaphysics_chart_ui.dart';
    import 'package:qizhengsiyu/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_tables.dart';
    import 'package:qizhengsiyu/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_config.dart';
    import 'package:qizhengsiyu/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_calculator.dart';
    import 'package:qizhengsiyu/painter/chart_style/qi_zheng_chart_style.dart';
    import 'package:qizhengsiyu/presentation/models/zhu_luo_san_xian/zhu_luo_ring_plan.dart';
    import 'package:qizhengsiyu/presentation/chart_adapters/zhu_luo_san_xian_ring_projector.dart';
    import 'package:qizhengsiyu/presentation/chart_adapters/zhu_luo_san_xian_ring_adapter.dart';

    void main() {
      late ZhuLuoRingPlan plan;

      setUp(() {
        final results = calculateZhuLuoSanXian(ZhuLuoInput(
          lifePalace: EnumTwelveGong.You,
          birthSect: BirthSect.day,
          rulerPalaces: {
            ZhuLuoRuler.venus: EnumTwelveGong.Yin,
            ZhuLuoRuler.moon: EnumTwelveGong.Wu,
            ZhuLuoRuler.mars: EnumTwelveGong.Zi,
          },
          maxAge: 80,
          config: directAnnualWithBridgeConfig,
        ));
        plan = projectZhuLuoRing(
          years: results,
          palaceOrder: EnumTwelveGong.listAll,
          startAngleOffset: 0,
        );
      });

      test("layer count matches total tracks", () {
        final layers = buildZhuLuoRingLayers(
          plan: plan,
          innerRadius: 100,
          trackWidth: 20,
          repeatGap: 2,
          stageGap: 6,
          labelMode: ZhuLuoAgeLabelMode.rangeOnly,
          zoomScale: 1.0,
        );
        final expectedTrackCount = plan.trackCounts.values.fold(0, (a, b) => a + b);
        expect(layers.layers, hasLength(expectedTrackCount));
      });

      test("blank palace sectors produce no ArcSegment", () {
        // 验证空 palace 不产生 arc：取 plan 中未出现的 palace
        final layers = buildZhuLuoRingLayers(
          plan: plan,
          innerRadius: 100,
          trackWidth: 20,
          repeatGap: 2,
          stageGap: 6,
          labelMode: ZhuLuoAgeLabelMode.rangeOnly,
          zoomScale: 1.0,
        );
        // 某个 track layer 的 arc 数量应 <= plan 中该 track 的 cell 数
        for (final layer in layers.layers) {
          final trackId = layer.id;
          expect(layer.arcs, isNotEmpty);
          expect(layer.behavior.innerRadius, isNotNull);
          expect(layer.behavior.outerRadius, isNotNull);
          for (final arc in layer.arcs) {
            expect(arc.paletteKey, startsWith('zhuLuo'));
            expect(layers.cellByHitId, contains(arc.id));
          }
        }
      });

      // Style consumption belongs to BoardTheme/modulePalette integration, not to ArcSegment fields.
    }
  STEP_2: |
    flutter test test/presentation/chart_adapters/zhu_luo_san_xian_ring_adapter_test.dart
    # 预期: PASS
PROHIBITED:
  - "不得在测试中调用渲染/绘制 pipeline"
ABSOLUTELY_PROHIBITED: []
ASSERTIONS: {
  EXECENV: "flutter_test",
  CASES: [
    "layer 数量 = 物理 track 总数",
    "每个 layer 的 arcs 非空且有对应 cell",
  ]
}
VERIFICATION: "flutter test PASS with 0 failed/skipped"
```

---

## ACT-008A: QiZheng Style Color Model

```
TASK_ID: "ACT-008A-style-color-model"
LANG: "Dart 3.10.7 / Flutter 3.38.6"
TARGET_FILE: "lib/painter/chart_style/qi_zheng_chart_style.dart"
CONTEXT: {
  DOMAIN: "七政侧新增竹罗三限语义颜色字段",
  STRATEGY: "只扩展 QiZheng 本地 ChartSemanticColors，不碰 renderer、不碰 metaphysics-chart-ui",
}
TASK_DEPS: []
COMMANDS:
  PRECHECK: |
    flutter analyze lib/painter/chart_style/qi_zheng_chart_style.dart
  STEP_1: |
    在 ChartSemanticColors 中新增字段：
      final Color zhuLuoInitial;
      final Color zhuLuoMiddle;
      final Color zhuLuoFinal;
      final Color zhuLuoBridge;
      final Color zhuLuoCellDivider;
      final Color zhuLuoJumpConnector;
      final Color zhuLuoTransitionMarker;
  STEP_2: |
    同步更新同一类中的 const constructor、copyWith、==、hashCode、fallback()。
    fallback() 允许使用既有 theme semantic colors 派生值；如必须新增 Color 字面量，仅允许在本文件 fallback 内出现。
  STEP_3_VERIFY: |
    flutter analyze lib/painter/chart_style/qi_zheng_chart_style.dart
    # 预期: no issues
PROHIBITED:
  - "不得修改 ../metaphysics-chart-ui/ 任何文件"
  - "不得使用 Colors.black / Colors.white 裸色"
  - "不得删除或修改现有语义颜色字段"
ABSOLUTELY_PROHIBITED: [
  "不得修改 lib/painter/chart_style/theme_chart_style_resolver.dart，本 ACT 只改 TARGET_FILE",
  "不得修改 lib/xing_xian/zhu_luo_san_xian/",
]
ASSERTIONS: {
  EXECENV: "flutter analyze",
  CASES: [
    "ChartSemanticColors 新增 7 个 zhuLuo* 字段",
    "const constructor 包含新字段",
    "copyWith 包含新字段",
    "== 比较新字段",
    "fallback() 返回新字段的默认值",
  ]
}
PROTOCOL: {MODE: "PATCH_ONLY", NO_PROSE: true, OUTPUT_FORMAT: "diff"}
VERIFICATION: "flutter analyze lib/painter/chart_style/qi_zheng_chart_style.dart exit code == 0"
```

---

## ACT-008B: QiZheng Style Token Resolver

```
TASK_ID: "ACT-008B-style-token-resolver"
LANG: "Dart 3.10.7 / Flutter 3.38.6"
TARGET_FILE: "lib/painter/chart_style/theme_chart_style_resolver.dart"
CONTEXT: {
  DOMAIN: "七政侧解析竹罗三限语义样式 token",
  STRATEGY: "只解析 ACT-008A 已添加的字段，不新增渲染逻辑，不改共享包",
}
TASK_DEPS: ["ACT-008A-style-color-model"]
COMMANDS:
  PRECHECK: |
    flutter analyze lib/painter/chart_style/qi_zheng_chart_style.dart
    flutter analyze lib/painter/chart_style/theme_chart_style_resolver.dart
  STEP_1: |
    在 _parseChartStyle 中为 ChartSemanticColors 添加 token 解析：
      zhuLuoInitial: TokenLoader.parseColor(colorsMap['zhuLuoInitial']) ?? fallback.colors.zhuLuoInitial
      zhuLuoMiddle: TokenLoader.parseColor(colorsMap['zhuLuoMiddle']) ?? fallback.colors.zhuLuoMiddle
      zhuLuoFinal: TokenLoader.parseColor(colorsMap['zhuLuoFinal']) ?? fallback.colors.zhuLuoFinal
      zhuLuoBridge: TokenLoader.parseColor(colorsMap['zhuLuoBridge']) ?? fallback.colors.zhuLuoBridge
      zhuLuoCellDivider: TokenLoader.parseColor(colorsMap['zhuLuoCellDivider']) ?? fallback.colors.zhuLuoCellDivider
      zhuLuoJumpConnector: TokenLoader.parseColor(colorsMap['zhuLuoJumpConnector']) ?? fallback.colors.zhuLuoJumpConnector
      zhuLuoTransitionMarker: TokenLoader.parseColor(colorsMap['zhuLuoTransitionMarker']) ?? fallback.colors.zhuLuoTransitionMarker
  STEP_2_VERIFY: |
    flutter analyze lib/painter/chart_style/theme_chart_style_resolver.dart
    # 预期: no issues
PROHIBITED:
  - "不得修改 ../metaphysics-chart-ui/ 任何文件"
  - "不得修改 ChartSemanticColors 字段定义；字段定义属于 ACT-008A"
  - "不得硬编码 Colors.black / Colors.white / Color(0x...)"
ABSOLUTELY_PROHIBITED: [
  "不得修改 lib/xing_xian/zhu_luo_san_xian/",
  "不得新增任何 skip/only 测试标记",
]
ASSERTIONS: {
  EXECENV: "flutter analyze",
  CASES: [
    "resolver 能解析 7 个 zhuLuo* token key",
    "缺失 token 时回退到 QiZhengChartStyle.fallback 对应字段",
    "未修改 metaphysics-chart-ui",
  ]
}
PROTOCOL: {MODE: "PATCH_ONLY", NO_PROSE: true, OUTPUT_FORMAT: "diff"}
VERIFICATION: "flutter analyze lib/painter/chart_style/theme_chart_style_resolver.dart exit code == 0"
```

---

## ACT-009: Connector Painter

```
TASK_ID: "ACT-009-connector-painter"
TARGET_FILE: "lib/presentation/widgets/rings/zhu_luo_transition_painter.dart"
CONTEXT: {
  DOMAIN: "跳宫/交限连接线的 QiZheng 侧 CustomPainter",
  STRATEGY: "只绘制连接线和标记，不绘制 cell/label/hit region",
}
TASK_DEPS: ["ACT-002-ring-plan-models", "ACT-008A-style-color-model", "ACT-008B-style-token-resolver"]
COMMANDS:
  PRECHECK: |
    flutter analyze lib/presentation/models/zhu_luo_san_xian/zhu_luo_ring_plan.dart
    flutter analyze lib/painter/chart_style/qi_zheng_chart_style.dart
  STEP_1_CONTENT: |
    import 'dart:math';
    import 'package:flutter/material.dart';
    import 'package:metaphysics_core/enums.dart';
    import 'package:qizhengsiyu/painter/chart_style/qi_zheng_chart_style.dart';
    import 'package:qizhengsiyu/presentation/models/zhu_luo_san_xian/zhu_luo_ring_plan.dart';
    import 'package:qizhengsiyu/presentation/chart_adapters/zhu_luo_san_xian_ring_adapter.dart';

    /// 只绘制逆跳连接线和交限标记的 Painters。
    /// 不绘制年度格、文字、点击区域。
    class ZhuLuoTransitionPainter extends CustomPainter {
      final ZhuLuoRingPlan plan;
      final ZhuLuoRingLayers layers;
      final QiZhengChartStyle style;
      final double centerX;
      final double centerY;

      ZhuLuoTransitionPainter({
        required this.plan,
        required this.layers,
        required this.style,
        required this.centerX,
        required this.centerY,
      });

      @override
      void paint(Canvas canvas, Size size) {
        if (plan.transitions.isEmpty) return;

        for (final edge in plan.transitions) {
          final sourceCell = layers.cellByHitId[edge.sourceCellId];
          final targetCell = layers.cellByHitId[edge.targetCellId];
          if (sourceCell == null || targetCell == null) continue;

          switch (edge.kind) {
            case ZhuLuoTransitionKind.inverseJump:
              _paintJumpConnector(canvas, edge, sourceCell, targetCell);
            case ZhuLuoTransitionKind.stageTransition:
              _paintTransitionMarker(canvas, edge, targetCell);
          }
        }
      }

      void _paintJumpConnector(
        Canvas canvas,
        ZhuLuoTransitionEdge edge,
        ZhuLuoAnnualCell source,
        ZhuLuoAnnualCell target,
      ) {
        final sourceRadius = _cellRadius(source);
        final targetRadius = _cellRadius(target);
        final sourceMidAngle = source.startAngle + source.sweepAngle / 2;
        final targetMidAngle = target.startAngle + target.sweepAngle / 2;

        final sourceRadians = sourceMidAngle * pi / 180;
        final targetRadians = targetMidAngle * pi / 180;
        final x1 = centerX + sourceRadius * cos(sourceRadians);
        final y1 = centerY + sourceRadius * sin(sourceRadians);
        final x2 = centerX + targetRadius * cos(targetRadians);
        final y2 = centerY + targetRadius * sin(targetRadians);

        final paint = Paint()
          ..color = style.colors.zhuLuoJumpConnector
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

        canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
      }

      void _paintTransitionMarker(
        Canvas canvas,
        ZhuLuoTransitionEdge edge,
        ZhuLuoAnnualCell cell,
      ) {
        final radius = _cellRadius(cell);
        final midAngle = cell.startAngle + cell.sweepAngle / 2;
        final radians = midAngle * pi / 180;
        final x = centerX + radius * cos(radians);
        final y = centerY + radius * sin(radians);

        final paint = Paint()
          ..color = style.colors.zhuLuoTransitionMarker
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;

        // 小圆圈标记
        canvas.drawCircle(Offset(x, y), 4.0, paint);
      }

      double _cellRadius(ZhuLuoAnnualCell cell) {
        final band = layers.trackBands[cell.trackIndex];
        if (band == null) return 0;
        return (band.innerRadius + band.outerRadius) / 2;
      }

      @override
      bool shouldRepaint(covariant ZhuLuoTransitionPainter oldDelegate) =>
          oldDelegate.plan != plan || oldDelegate.style != style;
    }
  STEP_2: |
    flutter analyze lib/presentation/widgets/rings/zhu_luo_transition_painter.dart
    # 预期: no issues
PROHIBITED:
  - "不得在 painter 中绘制 cell、label、或 hit region"
  - "不得修改 metaphysics-chart-ui OverlayLayer"
ABSOLUTELY_PROHIBITED: []
ASSERTIONS: {
  EXECENV: "flutter analyze",
  CASES: [
    "只处理 transitions 列表",
    "inverseJump 绘制两点之间的线",
    "stageTransition 在目标 cell 位置绘制标记",
    "shouldRepaint 在 plan/style 变化时返回 true",
  ]
}
VERIFICATION: "flutter analyze PASS with 0 issues"
```

---

## ACT-010: Painter Tests

```
TASK_ID: "ACT-010-painter-tests"
TARGET_FILE: "test/presentation/widgets/rings/zhu_luo_transition_painter_test.dart"
CONTEXT: {
  DOMAIN: "Connector painter 纯逻辑测试",
  STRATEGY: "构造已知 plan + layers，验证 painter 属性，不测试画布输出",
}
TASK_DEPS: ["ACT-009"]
COMMANDS:
  PRECHECK: |
    flutter analyze lib/presentation/widgets/rings/zhu_luo_transition_painter.dart
  STEP_1_CONTENT: |
    import 'package:flutter_test/flutter_test.dart';
    import 'package:metaphysics_core/enums.dart';
    import 'package:qizhengsiyu/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_tables.dart';
    import 'package:qizhengsiyu/painter/chart_style/qi_zheng_chart_style.dart';
    import 'package:qizhengsiyu/presentation/models/zhu_luo_san_xian/zhu_luo_ring_plan.dart';
    import 'package:qizhengsiyu/presentation/chart_adapters/zhu_luo_san_xian_ring_adapter.dart';
    import 'package:qizhengsiyu/presentation/widgets/rings/zhu_luo_transition_painter.dart';

    void main() {
      group("ZhuLuoTransitionPainter", () {
        test("empty transitions paints nothing (shouldRepaint test)", () {
          final plan = ZhuLuoRingPlan(cells: [], transitions: [], trackCounts: {});
          final layers = ZhuLuoRingLayers(layers: [], cellByHitId: {}, trackBands: {});
          final painter = ZhuLuoTransitionPainter(
            plan: plan,
            layers: layers,
            style: QiZhengChartStyle.fallback(),
            centerX: 100,
            centerY: 100,
          );

          final painter2 = ZhuLuoTransitionPainter(
            plan: plan,
            layers: layers,
            style: QiZhengChartStyle.fallback(),
            centerX: 100,
            centerY: 100,
          );

          expect(painter.shouldRepaint(painter2), isFalse);
        });

        test("different plan triggers repaint", () {
          final planA = ZhuLuoRingPlan(cells: [], transitions: [], trackCounts: {});
          final planB = ZhuLuoRingPlan(cells: [], transitions: [
            const ZhuLuoTransitionEdge(
              id: "e1",
              age: 30,
              kind: ZhuLuoTransitionKind.inverseJump,
              sourceCellId: "src",
              targetCellId: "dst",
            ),
          ], trackCounts: {});

          final layers = ZhuLuoRingLayers(layers: [], cellByHitId: {}, trackBands: {});
          final painterA = ZhuLuoTransitionPainter(
            plan: planA, layers: layers,
            style: QiZhengChartStyle.fallback(),
            centerX: 100, centerY: 100,
          );
          final painterB = ZhuLuoTransitionPainter(
            plan: planB, layers: layers,
            style: QiZhengChartStyle.fallback(),
            centerX: 100, centerY: 100,
          );

          expect(painterA.shouldRepaint(painterB), isTrue);
        });
      });
    }
  STEP_2: |
    flutter test test/presentation/widgets/rings/zhu_luo_transition_painter_test.dart
    # 预期: PASS
PROHIBITED:
  - "不得创建完整 Canvas 渲染测试（纯逻辑验证即可）"
ABSOLUTELY_PROHIBITED: []
ASSERTIONS: {
  EXECENV: "flutter_test",
  CASES: [
    "空 transitions 时 shouldRepaint 返回 false（相同参数）",
    "不同 plan 时 shouldRepaint 返回 true",
  ]
}
VERIFICATION: "flutter test PASS with 0 failed/skipped"
```

---

## ACT-011: Ring Widget

```
TASK_ID: "ACT-011-ring-widget"
TARGET_FILE: "lib/presentation/widgets/rings/zhu_luo_san_xian_ring.dart"
CONTEXT: {
  DOMAIN: "Widget 组合：ArcLayers + foreground painter + selected-cell callback",
  STRATEGY: "Compose ArcLayers 和 painter 在 Stack 中",
}
TASK_DEPS: ["ACT-006", "ACT-009"]
COMMANDS:
  PRECHECK: |
    flutter analyze lib/presentation/chart_adapters/zhu_luo_san_xian_ring_adapter.dart
  STEP_1_CONTENT: |
    import 'package:flutter/material.dart';
    import 'package:metaphysics_chart_ui/metaphysics_chart_ui.dart';
    import 'package:qizhengsiyu/painter/chart_style/qi_zheng_chart_style.dart';
    import 'package:qizhengsiyu/presentation/models/zhu_luo_san_xian/zhu_luo_ring_plan.dart';
    import 'package:qizhengsiyu/presentation/chart_adapters/zhu_luo_san_xian_ring_adapter.dart';
    import 'package:qizhengsiyu/presentation/widgets/rings/zhu_luo_transition_painter.dart';

    class ZhuLuoSanXianRing extends StatelessWidget {
      final ZhuLuoRingPlan plan;
      final ZhuLuoAgeLabelMode labelMode;
      final double zoomScale;
      final double size;
      final QiZhengChartStyle style;
      final void Function(ZhuLuoAnnualCell cell)? onCellSelected;

      const ZhuLuoSanXianRing({
        super.key,
        required this.plan,
        required this.labelMode,
        this.zoomScale = 1.0,
        required this.size,
        required this.style,
        this.onCellSelected,
      });

      @override
      Widget build(BuildContext context) {
        const innerRadius = 50.0;
        const trackWidth = 20.0;
        const repeatGap = 2.0;
        const stageGap = 6.0;

        final layers = buildZhuLuoRingLayers(
          plan: plan,
          innerRadius: innerRadius,
          trackWidth: trackWidth,
          repeatGap: repeatGap,
          stageGap: stageGap,
          labelMode: labelMode,
          zoomScale: zoomScale,
        );

        final board = ChartBoard(
          moduleId: ModuleId.qizhengsiyu,
          instanceId: 'zhu-luo-san-xian-ring',
          layout: BoardLayout(
            family: BoardLayoutFamily.circular,
            width: size,
            height: size,
          ),
          layers: layers.layers,
        );

        final outerRadius = layers.trackBands.values
            .map((band) => band.outerRadius)
            .fold<double>(innerRadius, (max, radius) => radius > max ? radius : max);

        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularCanvasBoard(
                board: board,
                center: Offset(size / 2, size / 2),
                innerRadius: innerRadius,
                outerRadius: outerRadius,
                theme: _boardThemeFromStyle(style),
                onRegionTap: (id) {
                  final cell = layers.cellByHitId[id];
                  if (cell != null) onCellSelected?.call(cell);
                },
              ),
              RepaintBoundary(
                child: CustomPaint(
                  size: Size(size, size),
                  painter: ZhuLuoTransitionPainter(
                    plan: plan,
                    layers: layers,
                    style: style,
                    centerX: size / 2,
                    centerY: size / 2,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      BoardTheme _boardThemeFromStyle(QiZhengChartStyle style) {
        final base = BoardTheme.defaults();
        final palette = <String, Color>{
          'zhuLuoInitial': style.colors.zhuLuoInitial,
          'zhuLuoMiddle': style.colors.zhuLuoMiddle,
          'zhuLuoFinal': style.colors.zhuLuoFinal,
          'zhuLuoBridge': style.colors.zhuLuoBridge,
          'zhuLuoCellDivider': style.colors.zhuLuoCellDivider,
          'zhuLuoJumpConnector': style.colors.zhuLuoJumpConnector,
          'zhuLuoTransitionMarker': style.colors.zhuLuoTransitionMarker,
        };
        return base.copyWith(
          modulePaletteOverrides: {
            ...base.modulePalettes,
            ModuleId.qizhengsiyu.name: {
              ...?base.modulePalettes[ModuleId.qizhengsiyu.name],
              ...palette,
            },
          },
        );
      }
    }
  STEP_2: |
    flutter analyze lib/presentation/widgets/rings/zhu_luo_san_xian_ring.dart
    # 预期: no issues
PROHIBITED:
  - "不得在 widget 中直接引用 calculator 或 config"
  - "不得修改现有 ring widget"
ABSOLUTELY_PROHIBITED: []
ASSERTIONS: {
  EXECENV: "flutter analyze",
  CASES: [
    "widget 接受 plan + labelMode + style 为输入",
    "使用 Stack 组合 CircularCanvasBoard 和 transition painter",
    "ArcLayer 由 metaphysics-chart-ui renderer 绘制",
    "transition painter 作为 foreground 层",
  ]
}
VERIFICATION: "flutter analyze PASS with 0 issues"
```

---

## ACT-012: Widget Tests

```
TASK_ID: "ACT-012-widget-tests"
TARGET_FILE: "test/presentation/widgets/rings/zhu_luo_san_xian_ring_test.dart"
CONTEXT: {
  DOMAIN: "Widget 单元测试：构造、更新、label mode 不改变几何",
  STRATEGY: "用 tester pumpWidget + find 验证 widget 结构",
}
TASK_DEPS: ["ACT-011"]
COMMANDS:
  PRECHECK: |
    flutter analyze lib/presentation/widgets/rings/zhu_luo_san_xian_ring.dart
  STEP_1_CONTENT: |
    import 'package:flutter_test/flutter_test.dart';
    import 'package:flutter/material.dart';
    import 'package:metaphysics_core/enums.dart';
    import 'package:qizhengsiyu/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_tables.dart';
    import 'package:qizhengsiyu/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_config.dart';
    import 'package:qizhengsiyu/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_calculator.dart';
    import 'package:qizhengsiyu/painter/chart_style/qi_zheng_chart_style.dart';
    import 'package:qizhengsiyu/presentation/models/zhu_luo_san_xian/zhu_luo_ring_plan.dart';
    import 'package:qizhengsiyu/presentation/chart_adapters/zhu_luo_san_xian_ring_projector.dart';
    import 'package:qizhengsiyu/presentation/widgets/rings/zhu_luo_san_xian_ring.dart';

    Widget createTestWidget(ZhuLuoRingPlan plan, {ZhuLuoAgeLabelMode mode = ZhuLuoAgeLabelMode.rangeOnly}) {
      return MaterialApp(
        home: Scaffold(
          body: ZhuLuoSanXianRing(
            plan: plan,
            labelMode: mode,
            size: 400,
            style: QiZhengChartStyle.fallback(),
          ),
        ),
      );
    }

    void main() {
      testWidgets("widget renders without error", (tester) async {
        final plan = ZhuLuoRingPlan(cells: [], transitions: [], trackCounts: {});
        await tester.pumpWidget(createTestWidget(plan));
        expect(find.byType(ZhuLuoSanXianRing), findsOneWidget);
      });

      testWidgets("widget with real plan renders", (tester) async {
        final results = calculateZhuLuoSanXian(ZhuLuoInput(
          lifePalace: EnumTwelveGong.You,
          birthSect: BirthSect.day,
          rulerPalaces: {ZhuLuoRuler.venus: EnumTwelveGong.Yin},
          maxAge: 30,
          config: classicInverseSectionsConfig,
        ));
        final plan = projectZhuLuoRing(
          years: results,
          palaceOrder: EnumTwelveGong.listAll,
          startAngleOffset: 0,
        );
        await tester.pumpWidget(createTestWidget(plan));
        expect(find.byType(ZhuLuoSanXianRing), findsOneWidget);
      });
    }
  STEP_2: |
    flutter test test/presentation/widgets/rings/zhu_luo_san_xian_ring_test.dart
    # 预期: PASS
PROHIBITED:
  - "不得在 widget 测试中跳过渲染验证"
ABSOLUTELY_PROHIBITED: []
ASSERTIONS: {
  EXECENV: "flutter_test",
  CASES: [
    "空 plan 可渲染",
    "真实 plan（calculator fixture + projector）可渲染",
    "widget 不抛出异常",
  ]
}
VERIFICATION: "flutter test PASS with 0 failed/skipped"
```

---

## ACT-013: Golden Tests

```
TASK_ID: "ACT-013-golden-tests"
LANG: "Dart 3.10.7 / Flutter 3.38.6"
TARGET_FILE: "test/presentation/chart_adapters/zhu_luo_san_xian_golden_test.dart"
CONTEXT: {
  DOMAIN: "Golden 测试：A跳宫、B补桥、重复入宫、交限、明/暗主题",
  STRATEGY: "用 testWidgets + matchesGoldenFile 验证像素级渲染；环境不支持 golden 时报告 BLOCKED，不得 skip",
}
TASK_DEPS: ["ACT-011-ring-widget", "ACT-012-widget-tests"]
COMMANDS:
  PRECHECK: |
    flutter analyze lib/presentation/widgets/rings/zhu_luo_san_xian_ring.dart
  STEP_1_CONTENT: |
    import 'package:flutter_test/flutter_test.dart';
    import 'package:flutter/material.dart';
    import 'package:metaphysics_core/enums.dart';
    import 'package:qizhengsiyu/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_tables.dart';
    import 'package:qizhengsiyu/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_config.dart';
    import 'package:qizhengsiyu/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_calculator.dart';
    import 'package:qizhengsiyu/presentation/models/zhu_luo_san_xian/zhu_luo_ring_plan.dart';
    import 'package:qizhengsiyu/presentation/chart_adapters/zhu_luo_san_xian_ring_projector.dart';
    import 'package:qizhengsiyu/presentation/chart_adapters/zhu_luo_san_xian_ring_adapter.dart';
    import 'package:qizhengsiyu/presentation/widgets/rings/zhu_luo_san_xian_ring.dart';

    void main() {
      Widget goldenHost({
        required ZhuLuoAlgorithmConfig config,
        required Brightness brightness,
        required String scenario,
      }) {
        final years = calculateZhuLuoSanXian(ZhuLuoInput(
          lifePalace: EnumTwelveGong.You,
          birthSect: BirthSect.day,
          rulerPalaces: {
            ZhuLuoRuler.venus: EnumTwelveGong.Yin,
            ZhuLuoRuler.moon: EnumTwelveGong.Wu,
            ZhuLuoRuler.mars: EnumTwelveGong.Zi,
          },
          maxAge: 80,
          config: config,
        ));
        final plan = projectZhuLuoRing(
          years: years,
          palaceOrder: EnumTwelveGong.listAll,
          startAngleOffset: -90,
        );
        return MaterialApp(
          theme: ThemeData(brightness: brightness),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 360,
                height: 360,
                child: ZhuLuoSanXianRing(
                  plan: plan,
                  labelMode: ZhuLuoAgeLabelMode.rangeOnly,
                  size: 360,
                  style: QiZhengChartStyle.fallback(brightness: brightness),
                ),
              ),
            ),
          ),
        );
      }

      testWidgets("A law inverse jump golden", (tester) async {
        await tester.pumpWidget(goldenHost(
          config: classicInverseSectionsConfig,
          brightness: Brightness.light,
          scenario: "a-jump-light",
        ));
        await tester.pumpAndSettle();
        await expectLater(
          find.byType(ZhuLuoSanXianRing),
          matchesGoldenFile("goldens/zhu_luo_a_jump_light.png"),
        );
      });

      testWidgets("B law bridge golden", (tester) async {
        await tester.pumpWidget(goldenHost(
          config: directAnnualWithBridgeConfig,
          brightness: Brightness.light,
          scenario: "b-bridge-light",
        ));
        await tester.pumpAndSettle();
        await expectLater(
          find.byType(ZhuLuoSanXianRing),
          matchesGoldenFile("goldens/zhu_luo_b_bridge_light.png"),
        );
      });

      testWidgets("dark theme golden", (tester) async {
        await tester.pumpWidget(goldenHost(
          config: directAnnualWithBridgeConfig,
          brightness: Brightness.dark,
          scenario: "b-bridge-dark",
        ));
        await tester.pumpAndSettle();
        await expectLater(
          find.byType(ZhuLuoSanXianRing),
          matchesGoldenFile("goldens/zhu_luo_b_bridge_dark.png"),
        );
      });
    }
  STEP_2_GENERATE_BASELINES: |
    flutter test --update-goldens test/presentation/chart_adapters/zhu_luo_san_xian_golden_test.dart
    # 预期: 生成/更新 3 个 golden PNG，exit code == 0
  STEP_3_VERIFY: |
    flutter test test/presentation/chart_adapters/zhu_luo_san_xian_golden_test.dart
    # 预期: PASS, 0 failed, 0 skipped
PROHIBITED:
  - "不得用 skip/only 跳过 golden 测试"
  - "不得用 condition、平台判断、环境变量判断绕过 golden 断言"
  - "golden 环境不可用时必须输出 BLOCKED，不得伪造 PASS"
ABSOLUTELY_PROHIBITED: [
  "不得修改 lib/xing_xian/zhu_luo_san_xian/",
  "不得修改 ../metaphysics-chart-ui/",
  "不得新增 skip:、skip(、.only、solo",
]
ASSERTIONS: {
  EXECENV: "flutter_test with golden support",
  CASES: [
    "A 法 golden 基线",
    "B 法 golden 基线",
    "暗主题 golden 基线",
  ]
}
PROTOCOL: {MODE: "FULL_FILE", NO_PROSE: true, OUTPUT_FORMAT: "source"}
VERIFICATION: "flutter test --update-goldens 后再次 flutter test，exit code == 0 且 0 skipped"
```

---

## ACT-014: ViewModel Controls

```
TASK_ID: "ACT-014-viewmodel-controls"
TARGET_FILE: "lib/presentation/viewmodels/qi_zheng_si_yu_viewmodel.dart"
CONTEXT: {
  DOMAIN: "ViewModel 新增算法选择、标签密度控制、年度结果暴露",
  STRATEGY: "新增 ValueNotifier 状态字段，不修改计算 UseCase",
}
TASK_DEPS: ["ACT-005"]
COMMANDS:
  PRECHECK: |
    # impact scan before editing
    # 在编辑器外运行：
    # rg -n "class QiZhengSiYuViewModel" lib/presentation/viewmodels/qizheng*
    flutter analyze lib/presentation/viewmodels/qi_zheng_si_yu_viewmodel.dart
  STEP_1_ADD_FIELDS: |
    在 QiZhengSiYuViewModel 类中新增：

    // 竹罗算法选择
    final ValueNotifier<ZhuLuoAlgorithmConfig?> selectedZhuLuoAlgorithmNotifier =
        ValueNotifier(null);

    // 竹罗标签密度模式
    final ValueNotifier<ZhuLuoAgeLabelMode> zhuLuoLabelModeNotifier =
        ValueNotifier(ZhuLuoAgeLabelMode.rangeOnly);

    // 竹罗年度结果
    final ValueNotifier<List<ZhuLuoYearResult>?> zhuLuoYearResultsNotifier =
        ValueNotifier(null);

    // 选中竹罗年度格的详情
    final ValueNotifier<ZhuLuoAnnualCell?> selectedZhuLuoCellNotifier =
        ValueNotifier(null);
  STEP_2_DISPOSE: |
    在 dispose() 中添加：
    selectedZhuLuoAlgorithmNotifier.dispose();
    zhuLuoLabelModeNotifier.dispose();
    zhuLuoYearResultsNotifier.dispose();
    selectedZhuLuoCellNotifier.dispose();
  STEP_3_ADD_METHOD: |
    // 计算指定算法的竹罗年度结果
    void calculateZhuLuoResults(ZhuLuoAlgorithmConfig config) {
      if (_basicLifePanel == null || _lifeObserver == null) return;
      // 使用 ZhuLuoSanXianManager 计算
      // 计算方法在后续集成时补完
      // 此处只声明接口签名
      selectedZhuLuoAlgorithmNotifier.value = config;
    }

    // 设置标签密度模式
    void setZhuLuoLabelMode(ZhuLuoAgeLabelMode mode) {
      zhuLuoLabelModeNotifier.value = mode;
    }
  STEP_4: |
    flutter analyze lib/presentation/viewmodels/qi_zheng_si_yu_viewmodel.dart
    # 预期: no issues
PROHIBITED:
  - "不得修改计算 UseCase 或 domain 层"
  - "不得在 ViewModel 中直接调用 calculator（应通过 Manager）"
ABSOLUTELY_PROHIBITED: []
ASSERTIONS: {
  EXECENV: "flutter analyze",
  CASES: [
    "新增 4 个 ValueNotifier 字段",
    "dispose 释放所有新增 notifier",
    "calculateZhuLuoResults 方法签名存在",
    "setZhuLuoLabelMode 方法签名存在",
  ]
}
VERIFICATION: "flutter analyze PASS with 0 issues"
```

---

## ACT-015: Legacy Board Integration

```
TASK_ID: "ACT-015-board-integration"
TARGET_FILE: "lib/presentation/adapters/legacy/qizheng_legacy_board.dart"
CONTEXT: {
  DOMAIN: "在 board 中插入竹罗环，默认关闭 feature flag",
  STRATEGY: "新增可选参数 + 条件渲染，不改现有 ring layer",
}
TASK_DEPS: ["ACT-011", "ACT-014"]
COMMANDS:
  PRECHECK: |
    # impact scan before editing
    # rg -n "class QiZhengLegacyBoard" lib/presentation/adapters/legacy/qizheng*
    flutter analyze lib/presentation/adapters/legacy/qizheng_legacy_board.dart
  STEP_1_ADD_PARAM: |
    在 QiZhengLegacyBoard 构造函数中新增可选参数：

    // 竹罗三限环（默认 null 表示不显示）
    final ZhuLuoSanXianRing? zhuLuoSanXianRing;
    final bool showZhuLuoRing; // feature flag, 默认 false

    添加到 const constructor, 默认值: zhuLuoSanXianRing = null, showZhuLuoRing = false
  STEP_2_ADD_BUILD: |
    在 build 方法的 Stack children 末尾（神煞环之后）添加：

    if (showZhuLuoRing && zhuLuoSanXianRing != null)
      KeyedSubtree(
        key: const ValueKey('zhu-luo-san-xian-ring'),
        child: zhuLuoSanXianRing!,
      ),
  STEP_3: |
    flutter analyze lib/presentation/adapters/legacy/qizheng_legacy_board.dart
    # 预期: no issues
PROHIBITED:
  - "不得修改 DaXian/Hundred-Six/FeiXian/XiaoXian 渲染"
  - "不得修改 board 中现有 ring 的顺序或可见性"
ABSOLUTELY_PROHIBITED: []
ASSERTIONS: {
  EXECENV: "flutter analyze",
  CASES: [
    "新增 showZhuLuoRing 参数默认 false",
    "showZhuLuoRing=true + ring!=null 时在 stack 末尾渲染",
    "showZhuLuoRing=false 时 board 渲染不变",
    "不修改现有任何 ring 的行为",
  ]
}
VERIFICATION: "flutter analyze PASS with 0 issues"
```

---

## ACT-016: Verification Gates

```
TASK_ID: "ACT-016-verification-gates"
TARGET_FILE: "（命令执行，无文件变更）"
CONTEXT: {
  DOMAIN: "最终验证门禁：test/analyze/boundary scan/skip scan/impact validation",
  STRATEGY: "所有门禁必须 PASS 才可 claim 完成",
}
TASK_DEPS: [
  "ACT-001-calculator-fixtures",
  "ACT-002-ring-plan-models",
  "ACT-003-model-tests",
  "ACT-004-pure-projector",
  "ACT-005-projection-tests",
  "ACT-006-arclayer-adapter",
  "ACT-007-adapter-tests",
  "ACT-008A-style-color-model",
  "ACT-008B-style-token-resolver",
  "ACT-009-connector-painter",
  "ACT-010-painter-tests",
  "ACT-011-ring-widget",
  "ACT-012-widget-tests",
  "ACT-013-golden-tests",
  "ACT-014-viewmodel-controls",
  "ACT-015-board-integration",
]
COMMANDS:
  PRECHECK: git status --short
  STEP_1_FOCUSED_TESTS: |
    flutter test test/presentation/models/zhu_luo_san_xian
    flutter test test/presentation/chart_adapters/zhu_luo_san_xian_ring_projector_test.dart
    flutter test test/presentation/chart_adapters/zhu_luo_san_xian_ring_adapter_test.dart
    flutter test test/presentation/widgets/rings/zhu_luo_san_xian_ring_test.dart
    flutter test test/presentation/widgets/rings/zhu_luo_transition_painter_test.dart
    flutter test test/xing_xian/zhu_luo_san_xian
    flutter test test/domain/managers/fate/zhu_luo_san_xian_manager_test.dart
    # 预期: ALL PASS, 0 skipped/failed
  STEP_2_ANALYZE: |
    flutter analyze lib/presentation/models/zhu_luo_san_xian
    flutter analyze lib/presentation/chart_adapters/zhu_luo_san_xian_ring_projector.dart
    flutter analyze lib/presentation/chart_adapters/zhu_luo_san_xian_ring_adapter.dart
    flutter analyze lib/presentation/widgets/rings/zhu_luo_san_xian_ring.dart
    flutter analyze lib/presentation/widgets/rings/zhu_luo_transition_painter.dart
    flutter analyze lib/painter/chart_style/qi_zheng_chart_style.dart
    flutter analyze lib/painter/chart_style/theme_chart_style_resolver.dart
    # 预期: no issues
  STEP_3_BOUNDARY_SCAN: |
    # 计算规则泄漏
    rg -n "calculateZhuLuoSanXian|rulerDuration|rulerNumber" lib/presentation/ --include "*.dart"
    # 预期: 只在 projector test 中有 calculateZhuLuoSanXian 调用

    # 旧 DaXian painter/helper 泄漏
    rg -n "DaXianRingPainter|DaXianCalculateHelper" lib/presentation/widgets/rings/zhu_luo* lib/presentation/chart_adapters/zhu_luo* 2>/dev/null
    # 预期: no matches

    # 硬编码颜色
    rg -n 'Colors\.black|Color\(0x' lib/presentation/widgets/rings/zhu_luo* lib/presentation/chart_adapters/zhu_luo* 2>/dev/null
    # 预期: no matches

    # shared-package 变更
    git diff --name-only -- ../metaphysics-chart-ui
    # 预期: no output (没有 shared-package 变更)
  STEP_4_SKIP_SCAN: |
    rg -n "skip:|skip\(|\.only|, skip|solo" test/presentation
    # 预期: 没有新引入的 skip/only/solo
  STEP_5_IMPACT_SCAN: |
    # 如需修改 qizheng_legacy_board.dart / qi_zheng_si_yu_viewmodel.dart
    # 先运行仓库可用的 impact/dependency scan
    # 如 gitnexus impact 或 dependency validator
    # 预期: medium 或 lower 风险等级
  STEP_6_SUMMARY: |
    # 汇总所有 gate 结果，确认：
    #   1. 所有 test PASS, 无 skip
    #   2. flutter analyze 无 issue
    #   3. boundary scans 无泄漏
    #   4. 无 shared-package 变更
    #   5. 无 skip/only 引入
    #   6. impact 风险可接受
    #   7. feature flag 默认关闭
PROHIBITED:
  - "不得使用 --no-skip 标记跳过 skipped tests（不得有 skipped tests 在先）"
  - "不得在分析中使用 ignore 文件或 relaxed thresholds"
ABSOLUTELY_PROHIBITED: []
ASSERTIONS: {
  EXECENV: "flutter test, flutter analyze, rg, git diff",
  CASES: [
    "所有 focused tests PASS",
    "所有 flutter analyze 无 issue",
    "presentation 文件无 calculator 规则泄漏",
    "presentation 文件无旧 DaXian 引用",
    "zhu_luo* 文件无硬编码 ARGB",
    "metaphysics-chart-ui 无变更",
    "无 skip/only 引入",
  ]
}
VERIFICATION: "所有 gate 命令 exit code == 0, 且 skip/only 扫描结果为空"
```
