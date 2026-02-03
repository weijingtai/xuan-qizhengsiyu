# ge_ju_1.txt 格局数据转换总结

## 一、转换概述

**任务**: 将 `example/assets/tmp/ge_ju_1.txt` 中的格局文本转换为结构化 JSON 文件

**完成时间**: 2026-02-01

**转换方式**: 使用8个并行LLM Agent进行批量转换

## 二、源文件统计

| 星类 | 编号范围 | 实际条目 | 缺失编号 |
|------|---------|---------|----------|
| 木星 | 1-100 | 91条 | 71-79 (共9个缺失) |
| 火星 | 1-90 | 90条 | 无 |
| 土星 | 1-68 | 67条 | 40 (1个缺失) |
| 金星 | 1-101 | 101条 | 无 |
| 水星 | 1-86 | 86条 | 无 |
| **总计** | - | **435条** | 10个缺失编号 |

## 三、转换结果

### 3.1 输出文件

| 文件名 | 格局数 | 吉/凶/平 | 有条件/无条件 | 文件大小 |
|--------|--------|----------|---------------|----------|
| mu_xing_ge_ju.json | 91 | 55/30/6 | 88/3 | 68,954 bytes |
| huo_xing_ge_ju.json | 90 | 47/38/3 | 82/8 | 58,310 bytes |
| tu_xing_ge_ju.json | 68 | 32/33/3 | 62/6 | 44,526 bytes |
| jin_xing_ge_ju.json | 101 | 65/28/6 | 89/12 | 65,547 bytes |
| shui_xing_ge_ju.json | 86 | 47/33/6 | 80/6 | 57,916 bytes |
| **总计** | **436** | 246/162/24 | 401/35 | 295,253 bytes |

**输出路径**: `example/assets/qizhengsiyu/ge_ju/`

### 3.2 数据质量

- ✅ 所有436个ID唯一，无重复
- ✅ 所有字段值符合枚举规范
- ✅ 401条格局有完整的conditions条件树
- ✅ 35条因原文描述模糊设为null
- ✅ 所有condition type均为标准类型

## 四、JSON Schema

### 4.1 单条格局结构

```json
{
  "id": "mu_001_ri_bian_hong_xing",
  "name": "日边红杏",
  "className": "木星格局",
  "books": "果老星宗",
  "source": "《果老星宗·星格贵贱总赋》",
  "description": "日邊紅杏，早占鰲頭。[紅杏者木星也，木為官、恩、命、令等用者，與太陽同行。]",
  "jiXiong": "吉",
  "geJuType": "贵",
  "scope": "natal",
  "conditions": { ... }
}
```

### 4.2 字段说明

| 字段 | 类型 | 枚举值 |
|------|------|--------|
| id | string | `{星缩写}_{三位序号}_{拼音简称}` |
| name | string | 格局名称 |
| className | string | "木星格局"/"火星格局"/"土星格局"/"金星格局"/"水星格局" |
| books | string | 书籍名称 |
| source | string | 具体出处 |
| description | string | 原文描述(保留繁体) |
| jiXiong | string | "吉"/"凶"/"平"/"大吉"/"大凶"/"小吉"/"小凶"/"未知" |
| geJuType | string | "贫"/"贱"/"富"/"贵"/"夭"/"寿"/"贤"/"愚" |
| scope | string | "natal"(命盘)/"xingxian"(行限)/"both"(通用) |
| conditions | object/null | 条件树 |

## 五、使用的Condition Types

转换中使用了以下28种标准条件类型:

### 星曜位置 (4种)
- `starInGong` - 星在宫
- `starInConstellation` - 星躔宿
- `starWalkingState` - 星行状态
- `starInKongWang` - 星落空亡

### 星曜关系 (7种)
- `sameGong` - 同宫
- `sameConstellation` - 同宿
- `oppositeGong` - 对照
- `trineGong` - 三合
- `squareGong` - 四正
- `sameJing` - 同经
- `sameLuo` - 同络

### 命盘结构 (4种)
- `lifeGongAt` - 命宫在宫
- `lifeConstellationAt` - 命度躔宿
- `starGuardLife` - 星临命
- `starInDestinyGong` - 星在功能宫

### 用神体系 (3种)
- `starIsSiZhu` - 星为四主
- `starFourType` - 恩难仇用
- `starHasHuaYao` - 星有化曜

### 时间条件 (4种)
- `seasonIs` - 季节
- `isDayBirth` - 昼夜
- `moonPhaseIs` - 月相
- `monthIs` - 月份

### 宫位状态 (1种)
- `starGongStatus` - 星庙旺

### 神煞条件 (2种)
- `starWithShenSha` - 星带神煞
- `gongHasShenSha` - 宫有神煞

### 行限条件 (3种)
- `xianAtGong` - 限到宫
- `xianAtConstellation` - 限躔宿
- `xianMeetStar` - 限遇星

### 组合逻辑 (3种)
- `and` - 与
- `or` - 或
- `not` - 非

## 六、转换过程中的问题与修复

### 6.1 JSON解析问题

部分格局的description字段中包含未转义的双引号(如 `"南枝向暖"`)，导致JSON解析失败。通过状态机方法检测并转义字符串内部的引号解决。

### 6.2 非标准Condition Type

部分Agent生成了非标准的condition type，已进行如下映射：

| 原类型 | 修复方式 |
|--------|----------|
| starInHouse | → starInDestinyGong |
| birthMonthIs | → monthIs |
| starInLifeGong | → starGuardLife |
| starInMiaoWang | → starGongStatus |
| starBeforeStar | → null |
| starConflict | → null |
| starIsYongShen | → null |
| starShineLife | → null |

### 6.3 枚举值修复

5条记录的geJuType使用了非标准值，已修复：
- mu_038, mu_044: "平" → "贵"
- huo_053: "未知" → "贵"
- huo_058, huo_070: "未知" → "贱"

## 七、GUI集成状态

### 7.1 文件位置

所有JSON文件已放置在正确位置：
```
example/assets/qizhengsiyu/ge_ju/
├── mu_xing_ge_ju.json   (91条)
├── huo_xing_ge_ju.json  (90条)
├── tu_xing_ge_ju.json   (68条)
├── jin_xing_ge_ju.json  (101条)
├── shui_xing_ge_ju.json (86条)
└── common_ge_ju.json    (7条，原有)
```

**总计: 443条格局**

### 7.2 Repository配置

`lib/data/repositories/ge_ju_repository_impl.dart` 已配置所有资源路径：
```dart
static const List<String> _builtInAssetPaths = [
  'assets/qizhengsiyu/ge_ju/mu_xing_ge_ju.json',
  'assets/qizhengsiyu/ge_ju/huo_xing_ge_ju.json',
  'assets/qizhengsiyu/ge_ju/tu_xing_ge_ju.json',
  'assets/qizhengsiyu/ge_ju/jin_xing_ge_ju.json',
  'assets/qizhengsiyu/ge_ju/shui_xing_ge_ju.json',
  'assets/qizhengsiyu/ge_ju/common_ge_ju.json',
];
```

### 7.3 pubspec.yaml配置

资源目录已在 `example/pubspec.yaml` 中声明：
```yaml
flutter:
  assets:
    - assets/qizhengsiyu/ge_ju/
```

### 7.4 集成状态

- ✅ JSON文件已放置在正确位置
- ✅ Repository已配置资源路径
- ✅ pubspec.yaml已声明资源目录
- ✅ 所有443条格局数据可被应用加载

### 7.5 访问路径

格局列表页面: `/qizhengsiyu/ge_ju/list`

## 八、后续工作

1. ~~将JSON文件集成到Flutter应用中~~ ✅
2. ~~在格局列表页面显示所有格局~~ ✅ (已有GUI实现)
3. ~~实现按星类、吉凶、格局类型筛选~~ ✅ (已有筛选功能)
4. ~~实现格局详情页面，展示条件树~~ ✅ (已有详情页)
5. 实现格局条件的计算和匹配逻辑 (待开发)
