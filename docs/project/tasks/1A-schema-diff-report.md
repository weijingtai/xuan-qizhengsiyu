# 1A：Schema 摸底报告 — 3 份旧资产字段差异清单 + 补全方案

## 元信息

- 创建日期：2026-07-09
- 文档类型：字段差异清单 + 迁移补全方案（草稿，先不改文件）
- 状态：人类已复审
- 前置：003 调研 §3（现状盘点）、§6.3（字段改名对照表）
- 正模板：`example/assets/qizhengsiyu/yuan_shoushi_chidao_hengxin.json`

---

## 0. 正模板 schema 速查（`yuan_shoushi_chidao_hengxin.json`）

| JSON key | Dart 类型 | 枚举约束 |
|----------|-----------|----------|
| `systemType` | `CelestialCoordinateSystem` | `黄道制` / `赤道制` / `天赤道制` / **`似黄道恒星制`** |
| `projectionConfig` | `ProjectionConfig?` | 可选，缺省为 null |
| `constellationSystemType` | `ConstellationSystemType` | `古宿制` / `矫正古宿制` / `今宿制` |
| `panelSystemType` | `PanelSystemType` | `回归制` / `恒星制` |
| `epochCorrection` | `String` | 无约束 |
| `totalDegree` | `double` | 无约束 |
| `gongOrder` | `List<EnumTwelveGong>` | 12 个单字：`子 丑 寅 卯 辰 巳 午 未 申 酉 戌 亥`（退行排列） |
| `starInnOrder` | `List<Enum28Constellations>` | 28 个单字宿名，角→轸固定环序 |
| `gongDegreeSeq` | `List<GongDegree>` | 每项 `{"gong": "子", "degree": 30.0}`，gong 单字 |
| `starInnDegreeSeq` | `List<ConstellationDegree>` | 每项 `{"constellation": "角", "degree": 12.0}`，单字宿名 |
| `alignmentPointAtConstellation` | `ConstellationDegree` | `{"constellation": "女", "degree": 1.971253}`，单字宿名 |
| `alignmentPointAtGong` | `GongDegree` | `{"gong": "丑", "degree": 14.784394}`，单字 |
| `zeroPointJieQi` | `TwentyFourJieQi` | 如 `冬至` |
| `zeroPointAtConstellation` | `ConstellationDegree` | 同上格式 |
| `zeroPointAtGong` | `GongDegree` | 同上格式 |
| `celestialLongitude` | `double` | 无约束 |
| `zeroPointOffsetToNow` | `double` | 无约束 |
| `rightAscension` | `double` | 无约束 |
| `specificationList` | `List<String>` | 描述性文字数组 |

### 关键枚举约束细节

**宿名必须是裸单字**（不带 `宿` 后缀），来自 `Enum28Constellations` 的 `@JsonValue`：
```
角 亢 氐 房 心 尾 箕 斗 牛 女 虚 危 室 壁
奎 娄 胃 昴 毕 觜 参 井 鬼 柳 星 张 翼 轸
```

**宫名必须是裸单字**，来自 `EnumTwelveGong` 的 `@JsonValue`：
```
子 丑 寅 卯 辰 巳 午 未 申 酉 戌 亥
```

---

## 1. `han_chidao_hengxin.json`（汉·太初历）

### 1.1 逐字段差异表

| # | 旧字段 | 新字段 | 旧值 | 新值 | 说明 |
|---|--------|--------|------|------|------|
| 1 | `systemType` | `systemType` | `"天赤道制"` | 不变 | 键名和值都对 |
| 2 | `starInnType` | `constellationSystemType` | `"古宿"` | `"古宿制"` | **键改名 + 值补"制"字** |
| 3 | `starInnSystem` | `panelSystemType` | `"恒星制"` | 不变 | **仅键改名** |
| 4 | `epochCorrection` | `epochCorrection` | `"汉·太初历"` | 不变 | |
| 5 | `totalDegree` | `totalDegree` | `365.25` | 不变 | |
| 6 | `twelvGongDegreeMap` | `gongDegreeSeq` | `{"子": 30.44, ...}`（Map） | `[{"gong": "子", "degree": 30.44}, ...]`（List） | **结构转换** |
| 7 | `starInnDegreeMap` | `starInnDegreeSeq` | `{"角": 12.0, ...}`（Map） | `[{"constellation": "角", "degree": 12.0}, ...]`（List） | **结构转换** |
| 8 | `alignmentPointAtStarInn` | `alignmentPointAtConstellation` | `{"starInn": "牛宿", "degree": 0.0}` | `{"constellation": "牛", "degree": 0.0}` | **键改名 + 值去"宿"后缀** |
| 9 | `alignmentPointAtGong` | `alignmentPointAtGong` | `{"gong": "丑", "degree": 15.0}` | 不变 | |
| 10 | `zeroPointJieQi` | `zeroPointJieQi` | `"冬至"` | 不变 | |
| 11 | `zeroPointAtStarInn` | `zeroPointAtConstellation` | `{"starInn": "牛宿", "degree": 0.0}` | `{"constellation": "牛", "degree": 0.0}` | **键改名 + 值去"宿"后缀** |
| 12 | `zeroPointAtGong` | `zeroPointAtGong` | `{"gong": "子宫", "degree": 15.0}` | `{"gong": "子", "degree": 15.0}` | **值去"宫"后缀** |
| 13 | `celestialLongitude` | `celestialLongitude` | `270.0` | 不变 | |
| 14 | `zeroPointOffsetToNow` | `zeroPointOffsetToNow` | `28.0` | 不变 | |
| 15 | `rightAscension` | `rightAscension` | `240.5` | 不变 | |
| — | （缺失） | `gongOrder` | — | `["戌","酉","申","未","午","巳","辰","卯","寅","丑","子","亥"]` | **必须新补** |
| — | （缺失） | `starInnOrder` | — | 28 宿固定环序 | **必须新补** |
| — | （缺失） | `specificationList` | — | `["汉太初天赤道恒星制，总度数 365.25 度"]` | **必须新补** |
| — | （缺失） | `projectionConfig` | — | null（可选，不补） | 可空 |

### 1.2 值核对结论

- `starInnDegreeMap` 度数求和 = 365.25，与 `totalDegree` 一致

---

## 2. `yuan_chidao_hengxing.json`（元·授时历）

### 2.1 逐字段差异表

| # | 旧字段 | 新字段 | 旧值 | 新值 | 说明 |
|---|--------|--------|------|------|------|
| 1 | `systemType` | `systemType` | `"赤道制"` | 不变 | |
| 2 | `starInnType` | `constellationSystemType` | `"古宿"` | `"古宿制"` | **键改名 + 值补"制"字** |
| 3 | `starInnSystem` | `panelSystemType` | `"恒星制"` | 不变 | **仅键改名** |
| 4 | `epochCorrection` | `epochCorrection` | `"元·授时历"` | 不变 | |
| 5 | `totalDegree` | `totalDegree` | `365.25` | 不变 | |
| 6 | `twelvGongDegreeMap` | `gongDegreeSeq` | `{"子": 30.438, ...}`（Map） | `[{"gong": "子", "degree": 30.438}, ...]`（List） | **结构转换** |
| 7 | `starInnDegreeMap` | `starInnDegreeSeq` | `{"角": 12, ...}`（Map） | `[{"constellation": "角", "degree": 12.0}, ...]`（List） | **结构转换** |
| 8 | `alignmentPointAtStarInn` | `alignmentPointAtConstellation` | `{"starInn": "女宿", "degree": 2.1}` | `{"constellation": "女", "degree": 2.1}` | **键改名 + 值去"宿"后缀** |
| 9 | `alignmentPointAtGong` | `alignmentPointAtGong` | `{"gong": "子", "degree": 0}` | 不变 | |
| 10 | `zeroPointJieQi` | `zeroPointJieQi` | `"冬至"` | 不变 | |
| 11 | `zeroPointAtStarInn` | `zeroPointAtConstellation` | `{"starInn": "虚宿", "degree": 6}` | `{"constellation": "虚", "degree": 6.0}` | **键改名 + 值去"宿"后缀** |
| 12 | `zeroPointAtGong` | `zeroPointAtGong` | `{"gong": "子宫", "degree": 15.0}` | `{"gong": "子", "degree": 15.0}` | **值去"宫"后缀** |
| — | （缺失） | `gongOrder` | — | 正模板退行序 | **必须新补** |
| — | （缺失） | `starInnOrder` | — | 28 宿固定环序 | **必须新补** |
| — | （缺失） | `specificationList` | — | `["元授时赤道恒星制，总度数 365.25 度"]` | **必须新补** |

---

## 3. `ming_si_huangdao_hengxing.json`（明·似黄道恒星制）

### 3.1 逐字段差异表

| # | 旧字段 | 新字段 | 旧值 | 新值 | 说明 |
|---|--------|--------|------|------|------|
| 1 | `systemType` | `systemType` | **`"似黄道制"`** | **`"似黄道恒星制"`** | **键名不变，但值必须改** |
| 2 | `starInnType` | `constellationSystemType` | `"古宿"` | `"古宿制"` | **键改名 + 值补"制"字** |
| 3 | `starInnSystem` | `panelSystemType` | `"恒星制"` | 不变 | **仅键改名** |
| 4 | `epochCorrection` | `epochCorrection` | `"元·授时历"` | `"元·授时历"`（保留） | 保留不改 |
| 5 | `totalDegree` | `totalDegree` | `365.25` | 不变 | |
| 6 | `twelvGongDegreeMap` | `gongDegreeSeq` | `{"子": 30.44, ...}`（Map） | `[{"gong": "子", "degree": 30.44}, ...]`（List） | **结构转换** |
| 7 | `starInnDegreeMap` | `starInnDegreeSeq` | `{"角": 12.0, ...}`（Map） | `[{"constellation": "角", "degree": 12.0}, ...]`（List） | **结构转换** |
| 8 | `alignmentPointAtStarInn` | `alignmentPointAtConstellation` | `{"starInn": "女宿", "degree": 1.38}` | `{"constellation": "女", "degree": 1.38}` | **键改名 + 值去"宿"后缀** |
| 9 | `alignmentPointAtGong` | `alignmentPointAtGong` | `{"gong": "子宫", "degree": 0.0}` | `{"gong": "子", "degree": 0.0}` | **值去"宫"后缀** |
| 10 | `zeroPointJieQi` | `zeroPointJieQi` | `"冬至"` | 不变 | |
| 11 | `zeroPointAtStarInn` | `zeroPointAtConstellation` | `{"starInn": "牛宿", "degree": 0.0}` | `{"constellation": "牛", "degree": 0.0}` | **键改名 + 值去"宿"后缀** |
| 12 | `zeroPointAtGong` | `zeroPointAtGong` | `{"gong": "子宫", "degree": 15.0}` | `{"gong": "子", "degree": 15.0}` | **值去"宫"后缀** |
| — | `description`（旧有） | 归入 `specificationList` | `"明代常用..."` | 移入 `specificationList` 数组 | 旧字段不存在于新 schema |
| — | （缺失） | `gongOrder` | — | 正模板退行序 | **必须新补** |
| — | （缺失） | `starInnOrder` | — | 28 宿固定环序 | **必须新补** |
| — | （缺失） | `specificationList` | — | `["明似黄道恒星制，从元代赤道恒星制发展而来，以黄道为基，采用不等宫制"]` | **必须新补** |

---

## 4. 补全方案

### 4.1 `gongOrder` — 十二宫退行环序（3 份文件统一复用）

```json
["戌","酉","申","未","午","巳","辰","卯","寅","丑","子","亥"]
```

### 4.2 `starInnOrder` — 二十八宿固定环序（3 份文件统一复用）

```json
["角","亢","氐","房","心","尾","箕","斗","牛","女","虚","危","室","壁","奎","娄","胃","昴","毕","觜","参","井","鬼","柳","星","张","翼","轸"]
```

### 4.3 `specificationList` — 描述文字

| 文件 | `specificationList` |
|------|---------------------|
| `han_chidao_hengxin.json` | `["汉太初天赤道恒星制，总度数 365.25 度"]` |
| `yuan_chidao_hengxing.json` | `["元授时赤道恒星制，总度数 365.25 度"]` |
| `ming_si_huangdao_hengxing.json` | `["明似黄道恒星制，从元代赤道恒星制发展而来，以黄道为基，采用不等宫制"]` |

---

## 5. 汇总

### 5.1 `han_chidao_hengxin.json`

| 类型 | 数量 | 详情 |
|------|------|------|
| 字段改名 | 4 | `starInnType`→`constellationSystemType`、`starInnSystem`→`panelSystemType`、`alignmentPointAtStarInn`→`alignmentPointAtConstellation`、`zeroPointAtStarInn`→`zeroPointAtConstellation` |
| 结构转换 | 2 | `twelvGongDegreeMap`→`gongDegreeSeq`、`starInnDegreeMap`→`starInnDegreeSeq` |
| 值改名 | 4 | `"古宿"`→`"古宿制"`、`"牛宿"`→`"牛"`（×2）、`"子宫"`→`"子"`（×1） |
| 缺失补全 | 3 | `gongOrder`、`starInnOrder`、`specificationList` |

### 5.2 `yuan_chidao_hengxing.json`

| 类型 | 数量 | 详情 |
|------|------|------|
| 字段改名 | 4 | 同 5.1 |
| 结构转换 | 2 | 同 5.1 |
| 值改名 | 4 | `"古宿"`→`"古宿制"`、`"女宿"`→`"女"`、`"虚宿"`→`"虚"`、`"子宫"`→`"子"`（×1） |
| 缺失补全 | 3 | 同 5.1 |

### 5.3 `ming_si_huangdao_hengxing.json`

| 类型 | 数量 | 详情 |
|------|------|------|
| 字段改名 | 4 | 同 5.1 |
| 结构转换 | 2 | 同 5.1 |
| **键值不改但值自身要改** | 1 | `systemType`: `"似黄道制"`→`"似黄道恒星制"` |
| 值改名 | 5 | `"古宿"`→`"古宿制"`、`"女宿"`→`"女"`、`"牛宿"`→`"牛"`、`"子宫"`→`"子"`（×2） |
| 旧字段处理 | 1 | `description` 内容移入 `specificationList` |
| 缺失补全 | 3 | 同 5.1 |

---

## 6. 风险提示

1. **`totalDegree` 与度数序列求和的自洽性问题**（003 §3 已知，1-B 第 3 类测试直接相关）：

   - **`starInnDegreeSeq`（宿度求和）**：3 份旧文件的宿度表都是汉初整数度表，求和 = 365.25，与各自 `totalDegree: 365.25` 一致。正模板 `yuan_shoushi_chidao_hengxin.json` 是唯一例外，其宿度求和约 360，属既有偏差，不在本次 3 份迁移范围。

   - **`gongDegreeSeq`（宫度求和）——迁移后 han / ming 会超 1-B 的 0.01° 容差**：迁移沿用旧 `twelvGongDegreeMap` 的宫度原值（不重算），求和如下表：

     | 文件 | 迁移后宫度值 | ×12 求和 | 与 totalDegree(365.25) 差 | 0.01° 容差 |
     |------|------------|----------|--------------------------|-----------|
     | `han_chidao_hengxin.json` | 30.44 | **365.28** | **0.03°** | 超容差，登记为已知偏差 |
     | `ming_si_huangdao_hengxing.json` | 30.44 | **365.28** | **0.03°** | 超容差，登记为已知偏差 |
     | `yuan_chidao_hengxing.json` | 30.438 | 365.256 | 0.006° | 过 |
     | `yuan_shoushi_chidao_hengxin.json`（正模板） | 30.0 | 360.0 | 5.25° | 既有 bug |

2. **`ming_si_huangdao_hengxing.json` 的 `epochCorrection` 是"元·授时历"**，但文件名含"明"。迁移时保留原值不动。

3. **宿名去后缀 / 宫名去后缀**：旧文件用带"宿"/"宫"后缀的形式，新 schema 要求裸单字。

4. **`gongDegreeSeq` 与 `gongOrder` 下标错位（被均匀宫度掩盖的静默错盘隐患）**：`calculatePalaceAngles()` 按下标把 `gongDegreeSeq[i]` 配给 `gongOrder[i]`（退行序 戌→亥），但 `gongDegreeSeq` 用自然序（子→亥）——两序下标不对齐。均匀宫度掩盖了此问题，方向三非均匀宫度会引爆。已记录到任务纪要方向三。

---

## 附录 A：二十八宿固定环序（`starInnOrder`）

```
角 → 亢 → 氐 → 房 → 心 → 尾 → 箕 → 斗 → 牛 → 女 → 虚 → 危 → 室 → 壁
→ 奎 → 娄 → 胃 → 昴 → 毕 → 觜 → 参 → 井 → 鬼 → 柳 → 星 → 张 → 翼 → 轸
```

## 附录 B：十二宫退行环序（`gongOrder`）

```
戌 → 酉 → 申 → 未 → 午 → 巳 → 辰 → 卯 → 寅 → 丑 → 子 → 亥
```

---

## 变更记录

| 日期 | 变更 | 作者 |
|------|------|------|
| 2026-07-09 | 初稿 | OpenCode |
| 2026-07-09 | R1 复审去风险：补 gongDegreeSeq 求和自洽性、修正计数、统一 spec 文案 | Claude Code |
| 2026-07-09 | R1 工程评审追加：gongDegreeSeq/gongOrder 下标错位静默错盘隐患 | Claude Code |
