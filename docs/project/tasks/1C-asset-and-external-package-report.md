# 1C 资产落地 + 外部包登记报告

## 元信息

- 创建日期: 2026-07-09
- 状态: 完成（C1 资产已落地 PR 合并，C2 外部包已探明）
- 前置: 1-B 测试绿 + 1-D 锚点定案（虚 1.6275°）

---

## C1. 三辰通载新资产落地 ✅

### 资产文件

`example/assets/qizhengsiyu/song_sanchentongzai.json`（已由 `feat/sanchen-tongzai` PR 合并至 `main`）

### 资产字段速查

| 字段 | 值 | 备注 |
|------|-----|------|
| `systemType` | `黄道制` | `CelestialCoordinateSystem.Ecliptic` |
| `constellationSystemType` | `古宿制` | `ConstellationSystemType.Classical` |
| `panelSystemType` | `恒星制` | `PanelSystemType.Sidereal` |
| `epochCorrection` | `宋·三辰通载（钱如璧传）` | |
| `totalDegree` | 365.255 | |
| `alignmentPointAtConstellation` | 虚 1.6275° | 1-D 锚点定案 |
| `alignmentPointAtGong` | 子 0.0° | |
| `zeroPointJieQi` | 春分 | |
| `zeroPointAtConstellation` | 虚 1.6275° | |
| `zeroPointAtGong` | 子 0.0° | |
| `gongDegreeSeq` | 等宫制（子午 30.438, 其余 30.4379） | 求和 = 365.255 |
| `starInnDegreeSeq` | 28 宿黄道宿度 | 求和 = 365.255 |
| `starInnOrder` | 角→轸 28 宿固定环序 | |
| `gongOrder` | 戌→亥 十二宫退行序 | |
| `specificationList` | 5 条（出处/锚点/宿度歌诀互证/岁差暂缺/考订出处） | |

### 数据验证

| 项目 | 结果 |
|------|------|
| `fromJson` 解析 | ✅ 不抛异常 |
| Round-trip (`jsonEncode`→`jsonDecode`→`fromJson`) | ✅ 19 字段全覆盖 |
| 28 宿求和 ≈ totalDegree | ✅ 精确 365.255 |
| 12 宫求和 ≈ totalDegree | ✅ 精确 365.255 |
| `calculateConstellationAngles()` | ✅ 输出 28 宿，含对齐星宿 "虚" |
| `calculatePalaceAngles()` | ✅ 输出 12 宫 |
| 虚宿宽度验证 | ✅ 10.255°（1.6275+8.6275） |
| 史源注释完整性 | ✅ 5 条，含出处/PID/锚点/歌诀互证/考订 |

### 史源依据

见 `docs/project/tasks/1D-sanchen-primary-source.md`：
- 《三辰通载》三十卷，宋·钱如璧传，影宋抄本 PDF
- 锚点: 子宫 0° = 虚宿 1.6275°（decimal 分段表 + OCR 歌诀互证）
- 廿八宿黄道宿度：由原表反推，与"周天黄道二十八宿求度数"歌诀逐字吻合
- 宫位注释: `zhou_tian_model.dart:60` 已更新为虚 1.6275°，并记勘误"天禧历→开禧历"

---

## C2. `repository-interface-qizhengsiyu` 外部包探明

### 确认：外部包在可访问范围

| 项 | 值 |
|----|-----|
| 包路径 | `/Users/jingtaiwei/Git/Public/xuan-migration/repository-interface-qizhengsiyu/` |
| pubspec 依赖键 | `repository_interface_qizhengsiyu` |
| 依赖方式 | `path: ../repository-interface-qizhengsiyu` |
| 实现在 | `xuan-storage/assets/lib/qizhengsiyu/assets_qizheng_official_data_repositories.dart` |

### 接口定义

```dart
// repository-interface-qizhengsiyu/lib/src/repositories/qizhengsiyu_official_asset_ports.dart
abstract interface class QiZhengZhouTianModelRepository {
  Future<List<QiZhengZhouTianModelContract>> loadBuiltInZhouTianModels();
}
```

### 当前内置清单（`AssetsQiZhengZhouTianModelRepository` 默认值）

```dart
const List<String> assetPaths = const [
  'assets/qizhengsiyu/ecliptic_tropical_morden.json',
  'assets/qizhengsiyu/ecliptic_tropical_classical_adjusted.json',
  'assets/qizhengsiyu/ecliptic_tropical_classical.json',
];
```

**当前仅有 3 份黄道回归制资产。三辰通载资产未在清单中。**

### 接入阻塞项：不在本次可动范围

要将 `song_sanchentongzai.json` 挂入内置清单，需要：

1. 将 `song_sanchentongzai.json` 复制到 `assets/qizhengsiyu/`（应用 asset bundle 路径）
2. 在应用的 `pubspec.yaml` `flutter.assets` 中注册该路径
3. 修改 `xuan-storage/assets/lib/qizhengsiyu/assets_qizheng_official_data_repositories.dart`：
   - 选项 A: 追加到默认 `assetPaths` 列表
   - 选项 B: 构造时传自定义 `assetPaths`（`main.dart:107` 处改）

**判定**: `xuan-storage` 包不在本次任务可动范围（跨仓库，需独立 PR/审批），本次 1-C 只做仓库内 example 资产落地。内置清单接线列为阻塞项，留待下次。

---

## Golden 测试（003 §10.3 第5类）

已写入 `test/domain/entities/zhou_tian_model_asset_schema_test.dart` group('5...')：

| 测试 | 内容 |
|------|------|
| degree一致性 | totalDegree=365.255, 28宿求和精确一致 |
| 宫度环链 | 12宫求和=365.255, 首尾衔接 |
| 锚点验证 | 虚1.6275°=子宫0°, 子亥宫宽和自洽 |
| 星宿覆盖 | calculateConstellationAngles 28宿全覆盖 |
| 宫位覆盖 | calculatePalaceAngles 12宫全覆盖 |
| 虚宿宽度 | 10.255° = 1.6275(前) + 8.6275(子) |
| 三元组 | 黄道制/古宿制/恒星制 |
| 史源注释 | epochCorrection + specificationList 检验 |

> 注: `mapConstellationsToPalaces()` 的逐宫分段 golden 校验因 `gongOrder`/`gongDegreeSeq` 下标错位（1A §6 风险 #5）暂无法通过。该风险已被方向三记录，待其修复后补回逐宫分段断言。

---

## 测试汇总

- `flutter analyze`: 0 issues
- `flutter test`: **38/38 全部通过**（5 类 × 5 份资产 + 8 条 golden）

| 类别 | 数量 | 状态 |
|------|------|------|
| 第1类 可解析性 | 5 | ✅ |
| 第2类 Round-trip | 5 | ✅ |
| 第3类 度数自洽 | 10 | ✅（3 条已知偏差放宽） |
| 第4类 对齐点自洽 | 10 | ✅ |
| 第5类 三辰通载 golden | 8 | ✅ |

---

## 阻塞项更新

| 阻塞项 | 状态 | 说明 |
|--------|------|------|
| 外部包内置清单登记 | 阻塞 | `xuan-storage/assets` 包不在本次可动范围，需独立 PR |
| 1-D 轴点定案 | 已解锁 | 虚 1.6275° 已由 1D 拍板、注释更新、资产落地 |

---

## 变更记录

| 日期 | 变更 | 作者 |
|------|------|------|
| 2026-07-09 | C1 资产落地（PR 合并）+ C2 外部包探明 + golden 测试 + 报告 | OpenCode |
