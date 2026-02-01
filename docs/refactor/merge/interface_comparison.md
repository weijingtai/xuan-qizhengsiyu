# ViewModel 接口对比分析

**生成时间**: 2025-10-20
**对比分支**: `refactor/74-ui` vs `refactor/74-mu`

---

## 1. UI分支 BeautyPageViewModel 完整接口清单

### 1.1 ValueNotifier 属性 (用于UI响应式更新)
```dart
final ValueNotifier<List<UIStarModel>?> uiBasicLifeStarsNotifier
final ValueNotifier<List<UIStarModel>?> uiFateLifeStarsNotifier
final ValueNotifier<BasePanelModel?> uiBasePanelNotifier
final ValueNotifier<DaXianPanelModel?> uiDaXianPanelNotifier
final ValueNotifier<ObserverPosition?> baseObserverPositionNotifier
```

### 1.2 普通 Getter 属性
```dart
List<UIStarModel> get uiBasicLifeStars
List<UIStarModel> get uiFateLifeStars
Map<EnumStars, FiveStarWalkingInfo>? get daXianMapper
ShenShaManager get shenShaManager
HuaYaoManager get huaYaoManager
ZhouTianModelManager get zhouTianModelManager
```

### 1.3 状态属性
```dart
ObserverPosition? lifeObserver  // 当前起盘的观察者位置
```

### 1.4 公开方法
```dart
Future<void> init()
  // 初始化 ViewModel,加载必要的数据源(ShenShaManager, HuaYaoManager等)

Future<void> calculate(ObserverPosition observerPosition)
  // 核心计算方法:根据观察者位置计算星盘
  // 更新 uiBasePanelNotifier, uiBasicLifeStarsNotifier 等

Future<void> calculateDaXian(DateTime fateLifeTime)
  // 计算大限盘
  // 更新 uiDaXianPanelNotifier, uiFateLifeStarsNotifier

void setLifeObserver(DivinationInfoModel divinationInfoModel)
  // 设置当前观察者信息(从DivinationInfoModel转换)

void setOverridePanelConfig(PanelConfig config)
  // 允许外部覆盖星盘配置

void calculateBasicStarsSafetyAngle(double starBodyRadius, ...)
  // 计算本命星体的UI防重叠角度

void calculateFateStarsSafetyAngle(double starBodyRadius, ...)
  // 计算大限星体的UI防重叠角度

void reset()
  // 重置 ViewModel 状态

void dispose()
  // 释放资源(包括 ValueNotifier)
```

### 1.5 私有方法(需要移植的核心逻辑)
```dart
List<UIStarModel> _calculateUIStarsFromMapper(...)
  // 从星体角度映射转换为 UIStarModel

Future<BasePanelModel> _calculatePanelWithService(...)
  // 使用 GenerateBasePanelService 计算星盘

Future<ShenShaManager> _loadShenShaManager()
Future<HuaYaoManager> _loadHuaYaoManager()
  // 加载各种数据管理器

static bool isInDegreeRange(...)
static List<DiZhi> getDayTimeZhi()
  // 静态辅助方法
```

### 1.6 常量
```dart
static const double _uiSafetyAnglePadding = 2.0
static final tz.TZDateTime _ziQiBaseShangHaiTime = ...
static const double _ziQiAnglePerDay = 0.0352
static const double _ziQiAnglePerMinute = ...
```

---

## 2. MVVM分支 QiZhengSiYuViewModel 现有接口清单

### 2.1 构造函数依赖注入
```dart
QiZhengSiYuViewModel({
  required this.shenShaManager,
  required this.huaYaoManager,
  required this.zhouTianModelManager,
})
```

### 2.2 Getter 属性
```dart
BasePanelModel? get basicLifePanel
List<UIStarModel> get uiBasicLifeStars
```

### 2.3 公开方法
```dart
Future<void> calculate(BasePanelConfig config, ObserverPosition observer)
  // 核心计算方法 (参数不同!)
  // 使用 CalculationEngineFactory 创建引擎
  // 调用 GenerateBasePanelService 计算
  // 注意: 没有更新 ValueNotifier
```

### 2.4 私有方法
```dart
Map<EnumStars, StarAngleSpeed> _transformStarPositions(...)
  // 转换星体位置数据
```

---

## 3. 接口差异对比表

| 接口项 | UI分支 | MVVM分支 | 需要操作 |
|--------|--------|----------|----------|
| **ValueNotifier 属性** |
| `uiBasicLifeStarsNotifier` | ✅ 存在 | ❌ 不存在 | **添加** |
| `uiFateLifeStarsNotifier` | ✅ 存在 | ❌ 不存在 | **添加** |
| `uiBasePanelNotifier` | ✅ 存在 | ❌ 不存在 | **添加** |
| `uiDaXianPanelNotifier` | ✅ 存在 | ❌ 不存在 | **添加** |
| `baseObserverPositionNotifier` | ✅ 存在 | ❌ 不存在 | **添加** |
| **Getter 属性** |
| `uiBasicLifeStars` | ✅ 存在 | ✅ 存在 | ✅ 无需修改 |
| `uiFateLifeStars` | ✅ 存在 | ❌ 不存在 | **添加** |
| `basicLifePanel` | ❌ 无(用notifier) | ✅ 存在 | ✅ 保留 |
| `daXianMapper` | ✅ 存在 | ❌ 不存在 | **添加** |
| `shenShaManager` | ✅ getter | ✅ final字段 | ✅ 已有(改为getter) |
| `huaYaoManager` | ✅ getter | ✅ final字段 | ✅ 已有(改为getter) |
| `zhouTianModelManager` | ✅ getter | ✅ final字段 | ✅ 已有(改为getter) |
| **状态属性** |
| `lifeObserver` | ✅ 存在 | ❌ 不存在 | **添加** |
| **核心方法** |
| `init()` | ✅ 存在 | ❌ 不存在 | **添加** |
| `calculate(ObserverPosition)` | ✅ 存在 | ❌ 签名不同 | **添加兼容版本** |
| `calculate(Config, Observer)` | ❌ 不存在 | ✅ 存在 | ✅ 保留(改名为calculateWithConfig) |
| `calculateDaXian(DateTime)` | ✅ 存在 | ❌ 不存在 | **添加或移植** |
| `setLifeObserver(DivinationInfoModel)` | ✅ 存在 | ❌ 不存在 | **添加** |
| `setOverridePanelConfig(PanelConfig)` | ✅ 存在 | ❌ 不存在 | **添加(可选)** |
| `calculateBasicStarsSafetyAngle` | ✅ 存在 | ❌ 不存在 | **移植** |
| `calculateFateStarsSafetyAngle` | ✅ 存在 | ❌ 不存在 | **移植** |
| `reset()` | ✅ 存在 | ❌ 不存在 | **添加(可选)** |
| `dispose()` | ✅ 存在 | ❌ 不存在 | **添加(必须)** |
| **私有方法(核心逻辑)** |
| `_calculateUIStarsFromMapper` | ✅ 存在 | ❌ 不存在 | **移植** |
| `_calculatePanelWithService` | ✅ 存在 | 部分存在 | **适配** |
| `_loadShenShaManager` | ✅ 存在 | ❌ 不需要 | ✅ 依赖注入替代 |
| `_transformStarPositions` | ❌ 不存在 | ✅ 存在 | ✅ 保留 |

---

## 4. 关键差异说明

### 4.1 calculate 方法签名冲突

**UI分支**:
```dart
Future<void> calculate(ObserverPosition observerPosition)
```

**MVVM分支**:
```dart
Future<void> calculate(BasePanelConfig config, ObserverPosition observer)
```

**解决方案**:
- MVVM分支的现有方法重命名为 `calculateWithConfig(BasePanelConfig, ObserverPosition)`
- 添加兼容的 `calculate(ObserverPosition)` 方法,内部构建默认config并调用 `calculateWithConfig`

### 4.2 ValueNotifier 的缺失

MVVM分支完全没有 `ValueNotifier`,这是UI层响应式更新的关键。

**影响范围**: `beauty_view_page.dart` 中有大量 `ValueListenableBuilder` 依赖这些 notifier

**解决方案**: 在 MVVM 的 ViewModel 中添加所有 ValueNotifier,并在计算完成后更新

### 4.3 依赖注入 vs 延迟加载

**UI分支**: Manager 在 `init()` 方法中异步加载
**MVVM分支**: Manager 通过构造函数注入

**解决方案**: 保留MVVM的依赖注入方式,但添加 `init()` 方法用于其他初始化任务(如加载周天模型)

### 4.4 大限盘计算

**UI分支**: 有完整的 `calculateDaXian` 方法
**MVVM分支**: 没有大限盘相关代码

**解决方案**: 需要从UI分支移植大限盘计算逻辑

### 4.5 UI星体计算逻辑

**UI分支**: 有复杂的 `_calculateUIStarsFromMapper` 方法,包含防重叠逻辑
**MVVM分支**: 只有 TODO 注释

**解决方案**: 完整移植UI分支的星体计算逻辑

---

## 5. 扩展计划优先级

### 优先级1 (必须 - UI层依赖)
- [x] 添加所有 ValueNotifier 属性
- [x] 添加兼容版 `calculate(ObserverPosition)` 方法
- [x] 重命名现有 `calculate` 为 `calculateWithConfig`
- [x] 在计算完成后更新所有 ValueNotifier
- [x] 添加 `dispose()` 方法释放 ValueNotifier
- [x] 添加 `init()` 方法

### 优先级2 (重要 - 核心功能)
- [ ] 移植 `_calculateUIStarsFromMapper` 逻辑
- [ ] 移植 `calculateBasicStarsSafetyAngle` 防重叠逻辑
- [ ] 移植 `calculateFateStarsSafetyAngle` 逻辑
- [ ] 添加 `lifeObserver` 状态属性
- [ ] 实现 `_buildDefaultConfig` 辅助方法

### 优先级3 (中等 - 扩展功能)
- [ ] 移植或实现 `calculateDaXian` 大限盘计算
- [ ] 添加 `uiFateLifeStars` 相关属性和计算
- [ ] 添加 `daXianMapper` 属性
- [ ] 实现 `setLifeObserver(DivinationInfoModel)` 方法

### 优先级4 (可选 - 辅助功能)
- [ ] 添加 `setOverridePanelConfig` 方法
- [ ] 添加 `reset()` 方法
- [ ] 移植所有常量

---

## 6. 数据模型兼容性

### 6.1 DivinationInfoModel vs ObserverPosition

**UI分支**: 使用 `DivinationInfoModel` (来自common模块)
**MVVM分支**: 使用 `ObserverPosition`

**需要转换方法**:
```dart
ObserverPosition _convertFromDivinationInfoModel(DivinationInfoModel model) {
  return ObserverPosition(
    dateTime: model.divinationDatetime.dateTime,
    longitude: model.divination.location.longitude,
    latitude: model.divination.location.latitude,
    // ...
  );
}
```

### 6.2 PanelConfig 模型差异

需要对比两个分支的 `PanelConfig` 定义,确认字段兼容性。

---

## 7. 下一步行动

1. ✅ 完成接口对比分析
2. ⏭️ 开始合并 MVVM 架构层 (domain/data)
3. ⏭️ 扩展 QiZhengSiYuViewModel,添加优先级1的接口
4. ⏭️ 移植UI星体计算逻辑 (优先级2)
5. ⏭️ 最小化修改 UI 层代码

---

**文档状态**: ✅ 完成
**下次更新**: 执行阶段3后
