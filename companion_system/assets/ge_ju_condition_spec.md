# 七政四余格局条件 JSON 规范文档

> 本文档供 AI 阅读，用于将用户输入的自然语言描述转化为格局条件 JSON。
> 所有条件最终以 `Map<String, dynamic>` 表示，顶层必须包含 `"type"` 字段。

---

## 一、逻辑组合（AND / OR / NOT）

条件可以嵌套组合，支持三种逻辑操作符。

### AND —— 所有子条件同时成立

```json
{
  "type": "and",
  "conditions": [ <条件A>, <条件B>, ... ]
}
```

**自然语言触发词**：同时、且、并且、以及、都、皆、兼

**示例**：日在财帛宫，且月入庙

```json
{
  "type": "and",
  "conditions": [
    { "type": "starInDestinyGong", "star": "Sun", "destinyGong": "CaiBo" },
    { "type": "starGongStatus", "star": "Moon", "statuses": ["Miao"] }
  ]
}
```

---

### OR —— 子条件满足其一即可

```json
{
  "type": "or",
  "conditions": [ <条件A>, <条件B>, ... ]
}
```

**自然语言触发词**：或、任一、其中之一、之一、或者

**示例**：火入申宫或酉宫

```json
{
  "type": "starInGong",
  "star": "Mars",
  "gongs": ["Shen", "You"]
}
```

> 注意：**同一个条件类型的多值**（如多个宫位、多个状态）直接放在数组里，不需要包 OR。
> 只有**不同条件类型**之间才需要显式 OR 节点。

---

### NOT —— 条件取反

```json
{
  "type": "not",
  "condition": <单个条件>
}
```

**自然语言触发词**：不、非、无、没有、排除

**示例**：火不在四正宫

```json
{
  "type": "not",
  "condition": { "type": "starInFourZheng", "star": "Mars" }
}
```

---

## 二、枚举值速查表

### 2.1 星体 `star` / `stars` / `starA` / `starB`

| 枚举值 | 中文 | 说明 |
|--------|------|------|
| `Sun` | 日 | 太阳 |
| `Moon` | 月 | 太阴 |
| `Mars` | 火 | 火星 |
| `Mercury` | 水 | 水星 |
| `Jupiter` | 木 | 木星 |
| `Venus` | 金 | 金星 |
| `Saturn` | 土 | 土星 |
| `Luo` | 罗 | 罗睺（火余） |
| `Ji` | 计 | 计都（土余） |
| `Qi` | 气 | 紫气（木余） |
| `Bei` | 孛 | 月孛（水余） |

> 五正曜：Sun, Moon, Mars, Mercury, Jupiter, Venus, Saturn
> 四余：Luo（罗睺）, Ji（计都）, Qi（紫气）, Bei（月孛）

---

### 2.2 地支宫 `gongs` / `targetGong` / `months`

以下值既用于宫位（天干宫），也用于出生月份（地支）：

| 枚举值 | 中文 | 顺序 |
|--------|------|------|
| `Zi` | 子 | 0 |
| `Chou` | 丑 | 1 |
| `Yin` | 寅 | 2 |
| `Mao` | 卯 | 3 |
| `Chen` | 辰 | 4 |
| `Si` | 巳 | 5 |
| `Wu` | 午 | 6 |
| `Wei` | 未 | 7 |
| `Shen` | 申 | 8 |
| `You` | 酉 | 9 |
| `Xu` | 戌 | 10 |
| `Hai` | 亥 | 11 |

**四正宫**：Zi（子）、Wu（午）、Mao（卯）、You（酉）
**四维宫**：Chen（辰）、Xu（戌）、Chou（丑）、Wei（未）
**四孟宫**：Yin（寅）、Shen（申）、Si（巳）、Hai（亥）

三合局：
- 申子辰水局：Shen, Zi, Chen
- 亥卯未木局：Hai, Mao, Wei
- 寅午戌火局：Yin, Wu, Xu
- 巳酉丑金局：Si, You, Chou

六合对：子丑、寅亥、卯戌、辰酉、巳申、午未

---

### 2.3 命理十二宫 `destinyGong`

| 枚举值 | 中文 |
|--------|------|
| `Ming` | 命宫 |
| `CaiBo` | 财帛宫 |
| `XiongDi` | 兄弟宫 |
| `TianZhai` | 田宅宫 |
| `NanNv` | 男女宫 |
| `NuPu` | 奴仆宫 |
| `FuQi` | 夫妻宫 |
| `JiE` | 疾厄宫 |
| `QianYi` | 迁移宫 |
| `GuanLu` | 官禄宫 |
| `FuDe` | 福德宫 |
| `XiangMao` | 相貌宫 |

---

### 2.4 庙旺状态 `statuses`

| 枚举值 | 中文 | 含义 |
|--------|------|------|
| `Miao` | 庙 | 入庙（最强） |
| `Wang` | 旺 | 乘旺 |
| `Xi` | 喜 | 喜宫 |
| `Le` | 乐 | 乐宫 |
| `Nu` | 怒 | 怒宫 |
| `Xian` | 陷 | 凶宫（落陷，弱） |
| `Zheng` | 正 | 正垣 |
| `Pian` | 偏 | 偏垣 |
| `Yuan` | 垣 | 垣 |
| `Dian` | 殿 | 升殿 |
| `Gui` | 贵 | 贵 |

> 常用分组：
> - 强旺：`["Miao", "Wang"]`
> - 强旺喜：`["Miao", "Wang", "Xi"]`
> - 落弱：`["Xian", "Nu"]`

---

### 2.5 化曜 `huaYaos`

| 枚举值 | 中文 | 说明 |
|--------|------|------|
| `Lu` | 禄 | 化禄 |
| `An` | 暗 | 化暗 |
| `Fu` | 福 | 化福 |
| `Hao` | 耗 | 化耗 |
| `YinBi` | 荫 | 化荫 |
| `Gui` | 贵 | 化贵 |
| `Xing` | 刑 | 化刑 |
| `Yin` | 印 | 化印 |
| `Qiu` | 囚 | 化囚 |
| `Quan` | 权 | 化权 |

---

### 2.6 月相 `phases`

| 枚举值 | 中文 |
|--------|------|
| `New` | 新月 |
| `E_Mei` | 峨眉月 |
| `Shang_Xian` | 上弦月 |
| `Ying_Tu` | 盈凸月 |
| `Full` | 满月 |
| `Kui_Tu` | 亏凸月 |
| `Xia_Xian` | 下弦月 |
| `Can_Yue` | 残月 |

---

### 2.7 季节 `seasons`

| 枚举值 | 中文 |
|--------|------|
| `SPRING` | 春季 |
| `SUMMER` | 夏季 |
| `AUTUMN` | 秋季 |
| `WINTER` | 冬季 |

---

### 2.8 星曜运行状态 `states`

| 枚举值 | 中文 |
|--------|------|
| `Fast` | 速（顺速） |
| `Normal` | 常（正常） |
| `Slow` | 迟（顺迟） |
| `Stay` | 留（留守） |
| `Retrograde` | 逆（逆行） |

---

### 2.9 恩难仇用 `types`（星曜四令关系）

| 枚举值 | 中文 | 含义 |
|--------|------|------|
| `En` | 恩 | 相生（生我者） |
| `Nan` | 难 | 相克（克我者） |
| `Chou` | 仇 | 我所泻（我生者之克者） |
| `Yong` | 用 | 我所克 |

---

### 2.10 四主角色 `roles`

| 枚举值 | 中文 |
|--------|------|
| `lifeGongMaster` | 命主（命宫主星） |
| `bodyGongMaster` | 身主（身宫主星） |
| `lifeConstellationMaster` | 度主（命度主星） |
| `bodyConstellationMaster` | 身度主 |

---

## 三、条件类型详解

---

### 3.1 `starInGong` —— 星曜在指定宫位

**含义**：某颗星位于给定的一个或多个地支宫之一（OR 关系）。

**字段**：

| 字段 | 类型 | 说明 |
|------|------|------|
| `star` | String | 星体枚举值 |
| `gongs` | List\<String\> | 目标宫位列表，满足其一即为真 |

**JSON 模板**：

```json
{ "type": "starInGong", "star": "<星>", "gongs": ["<宫1>", "<宫2>"] }
```

**示例**：

```json
// 火星在申宫或酉宫
{ "type": "starInGong", "star": "Mars", "gongs": ["Shen", "You"] }

// 日在子宫
{ "type": "starInGong", "star": "Sun", "gongs": ["Zi"] }
```

**自然语言触发词**：入X宫、在X宫、临X宫、守X宫、居X宫、落X宫

---

### 3.2 `starInConstellation` —— 星曜在指定星宿

**含义**：某颗星的经度落在指定二十八宿之一（OR 关系）。

**字段**：

| 字段 | 类型 | 说明 |
|------|------|------|
| `star` | String | 星体枚举值 |
| `constellations` | List\<String\> | 星宿中文名列表，如 "毕"、"昴"、"井" |

**JSON 模板**：

```json
{ "type": "starInConstellation", "star": "<星>", "constellations": ["<宿1>"] }
```

**示例**：

```json
// 日躔毕宿或昴宿
{ "type": "starInConstellation", "star": "Sun", "constellations": ["毕", "昴"] }
```

**自然语言触发词**：躔X宿、在X宿、临X宿

---

### 3.3 `starWalkingState` —— 星曜运行状态

**含义**：某颗星当前的运行状态（顺速/留/逆）。

**字段**：

| 字段 | 类型 | 说明 |
|------|------|------|
| `star` | String | 星体枚举值 |
| `states` | List\<String\> | 状态列表（见 2.8），满足其一即真 |

**JSON 模板**：

```json
{ "type": "starWalkingState", "star": "<星>", "states": ["<状态>"] }
```

**示例**：

```json
// 火星逆行
{ "type": "starWalkingState", "star": "Mars", "states": ["Retrograde"] }

// 土星留或逆
{ "type": "starWalkingState", "star": "Saturn", "states": ["Stay", "Retrograde"] }
```

**自然语言触发词**：逆行、顺行、留守、速行、迟行

---

### 3.4 `starInKongWang` —— 星曜落空亡

**含义**：某颗星当前落在空亡之地。

**字段**：

| 字段 | 类型 | 说明 |
|------|------|------|
| `star` | String | 星体枚举值 |

**JSON 模板**：

```json
{ "type": "starInKongWang", "star": "<星>" }
```

**示例**：

```json
// 火星落空亡
{ "type": "starInKongWang", "star": "Mars" }
```

**自然语言触发词**：落空亡、入空亡、在空亡

---

### 3.5 `starInFourZheng` —— 星曜在四正宫

**含义**：某颗星位于四正宫（子/午/卯/酉）之一。四正宫为最强宫位。

**字段**：

| 字段 | 类型 | 说明 |
|------|------|------|
| `star` | String | 星体枚举值 |

**JSON 模板**：

```json
{ "type": "starInFourZheng", "star": "<星>" }
```

**示例**：

```json
// 火在四正宫（子午卯酉之一）
{ "type": "starInFourZheng", "star": "Mars" }
```

**自然语言触发词**：在四正、入四正、居四正宫、在子午卯酉

> 等价展开：`{ "type": "starInGong", "star": "Mars", "gongs": ["Zi","Wu","Mao","You"] }`
> 推荐直接使用 `starInFourZheng` 更简洁。

---

### 3.6 `sameGong` —— 多星同宫

**含义**：列出的所有星同处一个地支宫（会合）。

**字段**：

| 字段 | 类型 | 说明 |
|------|------|------|
| `stars` | List\<String\> | 星体列表（≥2颗） |

**JSON 模板**：

```json
{ "type": "sameGong", "stars": ["<星A>", "<星B>"] }
```

**示例**：

```json
// 日月同宫
{ "type": "sameGong", "stars": ["Sun", "Moon"] }

// 火木土三星同宫
{ "type": "sameGong", "stars": ["Mars", "Jupiter", "Saturn"] }
```

**自然语言触发词**：同宫、会合、聚于同宫、同垣、并照

---

### 3.7 `sameConstellation` —— 多星同宿

**含义**：列出的所有星在同一个二十八宿。

**字段**：

| 字段 | 类型 | 说明 |
|------|------|------|
| `stars` | List\<String\> | 星体列表（≥2颗） |

**JSON 模板**：

```json
{ "type": "sameConstellation", "stars": ["<星A>", "<星B>"] }
```

**示例**：

```json
{ "type": "sameConstellation", "stars": ["Sun", "Moon"] }
```

**自然语言触发词**：同宿、同躔

---

### 3.8 `oppositeGong` —— 对照（对宫）

**含义**：两颗星所在地支宫正对（相差六位），如子与午、卯与酉。

**字段**：

| 字段 | 类型 | 说明 |
|------|------|------|
| `stars` | List\<String\> | 恰好2颗星 |

**JSON 模板**：

```json
{ "type": "oppositeGong", "stars": ["<星A>", "<星B>"] }
```

**示例**：

```json
// 日月对照
{ "type": "oppositeGong", "stars": ["Sun", "Moon"] }
```

**自然语言触发词**：对照、对宫、相对、照于对宫

---

### 3.9 `trineGong` —— 三合

**含义**：列出的所有星都处于同一三合局的三个宫位中（含同宫）。

**字段**：

| 字段 | 类型 | 说明 |
|------|------|------|
| `stars` | List\<String\> | 星体列表（≥2颗） |

**JSON 模板**：

```json
{ "type": "trineGong", "stars": ["<星A>", "<星B>"] }
```

**示例**：

```json
// 日月三合
{ "type": "trineGong", "stars": ["Sun", "Moon"] }
```

**自然语言触发词**：三合、三方、在三合宫

---

### 3.10 `squareGong` —— 四正关系（多星）

**含义**：列出的多颗星都处于同一四正（子午卯酉）体系的宫位中。
用于判断多星是否共处四正关系，与 `starInFourZheng`（单星判断）不同。

**字段**：

| 字段 | 类型 | 说明 |
|------|------|------|
| `stars` | List\<String\> | 星体列表（≥2颗） |

**JSON 模板**：

```json
{ "type": "squareGong", "stars": ["<星A>", "<星B>"] }
```

**示例**：

```json
// 日月都在四正宫且互成四正关系
{ "type": "squareGong", "stars": ["Sun", "Moon"] }
```

---

### 3.11 `sameJing` —— 同经

**含义**：多颗星位于同一黄道经度段（同经）。

**字段**：

| 字段 | 类型 | 说明 |
|------|------|------|
| `stars` | List\<String\> | 星体列表（≥2颗） |

**JSON 模板**：

```json
{ "type": "sameJing", "stars": ["<星A>", "<星B>"] }
```

---

### 3.12 `sameLuo` —— 同络

**含义**：多颗星属于同一络（特定聚合关系）。

**字段**：

| 字段 | 类型 | 说明 |
|------|------|------|
| `stars` | List\<String\> | 星体列表（≥2颗） |

**JSON 模板**：

```json
{ "type": "sameLuo", "stars": ["<星A>", "<星B>"] }
```

---

### 3.13 `gongZhao` —— 拱照

**含义**：starA 在 starB 所在宫的三方位（不含同宫），即"A 拱照 B"。
方向性：A 拱照 B ≠ B 拱照 A（需明确主被动关系）。

**字段**：

| 字段 | 类型 | 说明 |
|------|------|------|
| `starA` | String | 拱照方（主动） |
| `starB` | String | 被拱照方（被动） |

**JSON 模板**：

```json
{ "type": "gongZhao", "starA": "<拱照方>", "starB": "<被拱照方>" }
```

**示例**：

```json
// 日拱照月（日在月所在宫的三方）
{ "type": "gongZhao", "starA": "Sun", "starB": "Moon" }
```

**自然语言触发词**：拱照、三方拱照、拱于三方、A拱B

> 注意：`gongZhao` 与 `trineGong` 的区别：
> - `trineGong`：多星同属一个三合局（含同宫），无方向性
> - `gongZhao`：A 必须在 B 的三方宫（不含同宫），有方向性

---

### 3.14 `jiaGong` —— 夹宫

**含义**：starA 和 starB 分别在 targetGong 的前一宫和后一宫（顺序不限），即"A和B夹住目标宫"。

**字段**：

| 字段 | 类型 | 说明 |
|------|------|------|
| `starA` | String | 夹宫星之一 |
| `starB` | String | 夹宫星之二 |
| `targetGong` | String | 被夹的宫位（地支字符串） |

**JSON 模板**：

```json
{ "type": "jiaGong", "starA": "<星A>", "starB": "<星B>", "targetGong": "<宫>" }
```

**示例**：

```json
// 日月夹命宫（子宫）
{ "type": "jiaGong", "starA": "Sun", "starB": "Moon", "targetGong": "Zi" }

// 火土夹卯宫
{ "type": "jiaGong", "starA": "Mars", "starB": "Saturn", "targetGong": "Mao" }
```

**自然语言触发词**：夹宫、夹X宫、A与B夹X

---

### 3.15 `sixHarmony` —— 六合

**含义**：两颗星所在地支宫构成六合关系（子丑、寅亥、卯戌、辰酉、巳申、午未）。

**字段**：

| 字段 | 类型 | 说明 |
|------|------|------|
| `starA` | String | 星体A |
| `starB` | String | 星体B |

**JSON 模板**：

```json
{ "type": "sixHarmony", "starA": "<星A>", "starB": "<星B>" }
```

**示例**：

```json
// 日月六合
{ "type": "sixHarmony", "starA": "Sun", "starB": "Moon" }
```

**自然语言触发词**：六合、合宫、地支六合

---

### 3.16 `lifeGongAt` —— 命宫所在

**含义**：命宫（安命）落在指定地支宫之一。

**字段**：

| 字段 | 类型 | 说明 |
|------|------|------|
| `gongs` | List\<String\> | 目标宫位列表，满足其一即真 |

**JSON 模板**：

```json
{ "type": "lifeGongAt", "gongs": ["<宫1>", "<宫2>"] }
```

**示例**：

```json
// 命宫在子宫或午宫
{ "type": "lifeGongAt", "gongs": ["Zi", "Wu"] }
```

**自然语言触发词**：命宫安于X、命在X宫、安命X宫

---

### 3.17 `lifeConstellationAt` —— 命度躔宿

**含义**：命度（安命宿度）所在的二十八宿。

**字段**：

| 字段 | 类型 | 说明 |
|------|------|------|
| `constellations` | List\<String\> | 星宿中文名列表 |

**JSON 模板**：

```json
{ "type": "lifeConstellationAt", "constellations": ["<宿1>"] }
```

**示例**：

```json
{ "type": "lifeConstellationAt", "constellations": ["毕", "觜"] }
```

---

### 3.18 `starGuardLife` —— 星临命

**含义**：某颗星与命宫同宫（临守命宫）。

**字段**：

| 字段 | 类型 | 说明 |
|------|------|------|
| `star` | String | 星体枚举值 |

**JSON 模板**：

```json
{ "type": "starGuardLife", "star": "<星>" }
```

**示例**：

```json
// 日临命
{ "type": "starGuardLife", "star": "Sun" }

// 月临命
{ "type": "starGuardLife", "star": "Moon" }
```

**自然语言触发词**：临命、守命、临于命宫、在命宫

---

### 3.19 `starInDestinyGong` —— 星在命理宫

**含义**：某颗星位于指定的命盘功能宫（财帛、官禄等）。

**字段**：

| 字段 | 类型 | 说明 |
|------|------|------|
| `star` | String | 星体枚举值 |
| `destinyGong` | String | 命理宫枚举值（见 2.3） |

**JSON 模板**：

```json
{ "type": "starInDestinyGong", "star": "<星>", "destinyGong": "<命理宫>" }
```

**示例**：

```json
// 日在财帛宫
{ "type": "starInDestinyGong", "star": "Sun", "destinyGong": "CaiBo" }

// 火在官禄宫
{ "type": "starInDestinyGong", "star": "Mars", "destinyGong": "GuanLu" }
```

**自然语言触发词**：在X宫（命理宫名）、临X宫（命理宫名）、守X宫（命理宫名）

> 区别：`starGuardLife`（临命宫）是 `starInDestinyGong` + `destinyGong: "Ming"` 的特例，但更简洁。

---

### 3.20 `starIsSiZhu` —— 星为四主

**含义**：某颗星是否担任命主、身主、度主、身度主之一。

**字段**：

| 字段 | 类型 | 说明 |
|------|------|------|
| `star` | String | 星体枚举值 |
| `roles` | List\<String\> | 角色列表（见 2.10） |

**JSON 模板**：

```json
{ "type": "starIsSiZhu", "star": "<星>", "roles": ["<角色>"] }
```

**示例**：

```json
// 火为命主
{ "type": "starIsSiZhu", "star": "Mars", "roles": ["lifeGongMaster"] }

// 木为命主或身主
{ "type": "starIsSiZhu", "star": "Jupiter", "roles": ["lifeGongMaster", "bodyGongMaster"] }
```

**自然语言触发词**：为命主、为身主、为度主、担任命主

---

### 3.21 `starFourType` —— 星恩难仇用关系

**含义**：`star` 对于 `target` 的四令关系（恩/难/仇/用）。
语义："`star` 是 `target` 的恩星/难星/仇星/用星"。

**字段**：

| 字段 | 类型 | 说明 |
|------|------|------|
| `star` | String | 主体星（承担关系的那颗） |
| `target` | String | 参照星（相对于哪颗星） |
| `types` | List\<String\> | 关系类型列表（见 2.9） |

**JSON 模板**：

```json
{ "type": "starFourType", "star": "<主体>", "target": "<参照>", "types": ["<关系>"] }
```

**示例**：

```json
// 木为火之恩星（木生火）
{ "type": "starFourType", "star": "Jupiter", "target": "Mars", "types": ["En"] }

// 水为火之难星（水克火）
{ "type": "starFourType", "star": "Mercury", "target": "Mars", "types": ["Nan"] }
```

**自然语言触发词**：X为Y之恩星、X克Y（难）、X为Y之仇星

---

### 3.22 `starHasHuaYao` —— 星有化曜

**含义**：某颗星当年带有指定化曜（国老化曜）。

**字段**：

| 字段 | 类型 | 说明 |
|------|------|------|
| `star` | String | 星体枚举值 |
| `huaYaos` | List\<String\> | 化曜列表（见 2.5） |

**JSON 模板**：

```json
{ "type": "starHasHuaYao", "star": "<星>", "huaYaos": ["<化曜>"] }
```

**示例**：

```json
// 木化禄
{ "type": "starHasHuaYao", "star": "Jupiter", "huaYaos": ["Lu"] }

// 火化权或化印
{ "type": "starHasHuaYao", "star": "Mars", "huaYaos": ["Quan", "Yin"] }
```

**自然语言触发词**：化禄、化权、化印、化贵、有X化曜

---

### 3.23 `starGongStatus` —— 星庙旺状态

**含义**：某颗星当前在宫位中的力量状态（庙/旺/喜/陷等）。

**字段**：

| 字段 | 类型 | 说明 |
|------|------|------|
| `star` | String | 星体枚举值 |
| `statuses` | List\<String\> | 状态列表（见 2.4），满足其一即真 |

**JSON 模板**：

```json
{ "type": "starGongStatus", "star": "<星>", "statuses": ["<状态>"] }
```

**示例**：

```json
// 火入庙
{ "type": "starGongStatus", "star": "Mars", "statuses": ["Miao"] }

// 月入庙或旺
{ "type": "starGongStatus", "star": "Moon", "statuses": ["Miao", "Wang"] }

// 土落陷（弱）
{ "type": "starGongStatus", "star": "Saturn", "statuses": ["Xian"] }
```

**自然语言触发词**：入庙、乘旺、喜宫、落陷、有力、得地、失地

---

### 3.24 `seasonIs` —— 出生季节

**含义**：出生时节为指定季节之一。

**字段**：

| 字段 | 类型 | 说明 |
|------|------|------|
| `seasons` | List\<String\> | 季节列表（见 2.7） |

**JSON 模板**：

```json
{ "type": "seasonIs", "seasons": ["<季节>"] }
```

**示例**：

```json
// 生于夏季
{ "type": "seasonIs", "seasons": ["SUMMER"] }

// 生于春季或夏季
{ "type": "seasonIs", "seasons": ["SPRING", "SUMMER"] }
```

**自然语言触发词**：生于春/夏/秋/冬、春生、夏生

---

### 3.25 `isDayBirth` —— 昼夜生

**含义**：是否为昼生（太阳在地平线以上）。

**字段**：

| 字段 | 类型 | 说明 |
|------|------|------|
| `isDay` | bool | true = 昼生，false = 夜生 |

**JSON 模板**：

```json
{ "type": "isDayBirth", "isDay": true }
```

**示例**：

```json
// 昼生
{ "type": "isDayBirth", "isDay": true }

// 夜生
{ "type": "isDayBirth", "isDay": false }
```

**自然语言触发词**：昼生、白天生、日生、夜生、夜间生

---

### 3.26 `moonPhaseIs` —— 月相

**含义**：出生时月相为指定月相之一。

**字段**：

| 字段 | 类型 | 说明 |
|------|------|------|
| `phases` | List\<String\> | 月相列表（见 2.6） |

**JSON 模板**：

```json
{ "type": "moonPhaseIs", "phases": ["<月相>"] }
```

**示例**：

```json
// 满月生
{ "type": "moonPhaseIs", "phases": ["Full"] }

// 新月或满月
{ "type": "moonPhaseIs", "phases": ["New", "Full"] }
```

**自然语言触发词**：满月生、新月、上弦、下弦、峨眉月

---

### 3.27 `monthIs` —— 出生月（地支）

**含义**：出生月份的地支为指定地支之一。

**字段**：

| 字段 | 类型 | 说明 |
|------|------|------|
| `months` | List\<String\> | 地支列表（见 2.2） |

**JSON 模板**：

```json
{ "type": "monthIs", "months": ["<地支>"] }
```

**示例**：

```json
// 生于子月（农历11月）
{ "type": "monthIs", "months": ["Zi"] }

// 生于寅月或卯月（正月或二月）
{ "type": "monthIs", "months": ["Yin", "Mao"] }
```

**自然语言触发词**：X月生、生于X月、农历X月出生

---

### 3.28 `starWithShenSha` —— 星带神煞

**含义**：某颗星所在宫位带有指定神煞之一。

**字段**：

| 字段 | 类型 | 说明 |
|------|------|------|
| `star` | String | 星体枚举值 |
| `shenShaNames` | List\<String\> | 神煞中文名列表（如 "天乙贵人"、"将星"、"羊刃"） |

**JSON 模板**：

```json
{ "type": "starWithShenSha", "star": "<星>", "shenShaNames": ["<神煞名>"] }
```

**示例**：

```json
// 日与天乙贵人同宫
{ "type": "starWithShenSha", "star": "Sun", "shenShaNames": ["天乙贵人"] }
```

**自然语言触发词**：带X神煞、与X同宫、有X神煞

---

### 3.29 `gongHasShenSha` —— 宫位带神煞

**含义**：指定宫位（地支宫、命宫或身宫）带有指定神煞之一。

**字段**：

| 字段 | 类型 | 说明 |
|------|------|------|
| `gongIdentifier` | String | 宫位标识：地支名（"Zi"等）、"lifeGong"（命宫）、"bodyGong"（身宫） |
| `shenShaNames` | List\<String\> | 神煞中文名列表 |

**JSON 模板**：

```json
{ "type": "gongHasShenSha", "gongIdentifier": "<宫位或lifeGong>", "shenShaNames": ["<神煞>"] }
```

**示例**：

```json
// 命宫带将星
{ "type": "gongHasShenSha", "gongIdentifier": "lifeGong", "shenShaNames": ["将星"] }

// 子宫带天乙贵人
{ "type": "gongHasShenSha", "gongIdentifier": "Zi", "shenShaNames": ["天乙贵人"] }
```

---

### 3.30 `xianAtGong` —— 行限在宫

**含义**：当前行限（小限/大限）落在指定地支宫之一。仅在行限模式下有效。

**字段**：

| 字段 | 类型 | 说明 |
|------|------|------|
| `gongs` | List\<String\> | 目标宫位列表 |

**JSON 模板**：

```json
{ "type": "xianAtGong", "gongs": ["<宫1>", "<宫2>"] }
```

**示例**：

```json
// 行限在命宫地支（子宫）
{ "type": "xianAtGong", "gongs": ["Zi"] }
```

---

### 3.31 `xianAtConstellation` —— 行限在星宿

**含义**：当前行限（小限）所在宿度落在指定二十八宿之一。

**字段**：

| 字段 | 类型 | 说明 |
|------|------|------|
| `constellations` | List\<String\> | 星宿中文名列表 |

**JSON 模板**：

```json
{ "type": "xianAtConstellation", "constellations": ["<宿>"] }
```

---

### 3.32 `xianMeetStar` —— 行限遇星

**含义**：行限宫内有指定星曜之一。

**字段**：

| 字段 | 类型 | 说明 |
|------|------|------|
| `stars` | List\<String\> | 星体列表，满足其一即真 |

**JSON 模板**：

```json
{ "type": "xianMeetStar", "stars": ["<星>"] }
```

**示例**：

```json
// 行限遇日或月
{ "type": "xianMeetStar", "stars": ["Sun", "Moon"] }
```

---

## 四、复合示例

### 示例 1：日月同宫且入庙

```json
{
  "type": "and",
  "conditions": [
    { "type": "sameGong", "stars": ["Sun", "Moon"] },
    { "type": "starGongStatus", "star": "Sun", "statuses": ["Miao"] },
    { "type": "starGongStatus", "star": "Moon", "statuses": ["Miao"] }
  ]
}
```

---

### 示例 2：火在财帛或官禄，且不落空亡

```json
{
  "type": "and",
  "conditions": [
    {
      "type": "or",
      "conditions": [
        { "type": "starInDestinyGong", "star": "Mars", "destinyGong": "CaiBo" },
        { "type": "starInDestinyGong", "star": "Mars", "destinyGong": "GuanLu" }
      ]
    },
    {
      "type": "not",
      "condition": { "type": "starInKongWang", "star": "Mars" }
    }
  ]
}
```

---

### 示例 3：木化禄，且在命宫三方（拱照命）

```json
{
  "type": "and",
  "conditions": [
    { "type": "starHasHuaYao", "star": "Jupiter", "huaYaos": ["Lu"] },
    { "type": "starGuardLife", "star": "Jupiter" }
  ]
}
```

> 若是"拱照命宫"（三方，不含同宫），用 `starInDestinyGong + Ming` 无法表达。
> 此时可用：命宫地支假设为 `Zi`，则拱照为在申子辰的另两宫，但由于命宫地支是运行时确定的，目前无专门条件类型，可通过 `lifeGongAt` 组合 `starInGong` 近似表达。

---

### 示例 4：日月拱照，生于夏季，昼生

```json
{
  "type": "and",
  "conditions": [
    { "type": "gongZhao", "starA": "Sun", "starB": "Moon" },
    { "type": "seasonIs", "seasons": ["SUMMER"] },
    { "type": "isDayBirth", "isDay": true }
  ]
}
```

---

### 示例 5：金水夹命宫（命在子，则金在亥，水在丑）

```json
{
  "type": "and",
  "conditions": [
    { "type": "lifeGongAt", "gongs": ["Zi"] },
    { "type": "jiaGong", "starA": "Venus", "starB": "Mercury", "targetGong": "Zi" }
  ]
}
```

---

### 示例 6：火土六合，且火入庙或旺

```json
{
  "type": "and",
  "conditions": [
    { "type": "sixHarmony", "starA": "Mars", "starB": "Saturn" },
    { "type": "starGongStatus", "star": "Mars", "statuses": ["Miao", "Wang"] }
  ]
}
```

---

### 示例 7：三颗吉星（日月木）任意两颗三合

```json
{
  "type": "or",
  "conditions": [
    { "type": "trineGong", "stars": ["Sun", "Moon"] },
    { "type": "trineGong", "stars": ["Sun", "Jupiter"] },
    { "type": "trineGong", "stars": ["Moon", "Jupiter"] }
  ]
}
```

---

## 五、AI 转换规则摘要

1. **单个宫位多选** → 同一条件的 `gongs`/`stars`/`statuses` 列表中并列（无需 OR 包装）
2. **不同条件类型之间的"或"** → 用 `{"type":"or","conditions":[...]}` 包装
3. **所有条件都要成立** → 用 `{"type":"and","conditions":[...]}` 包装
4. **取反** → 用 `{"type":"not","condition":{...}}` 包装
5. **临命 = 在命宫** → 优先用 `starGuardLife`，比 `starInDestinyGong + Ming` 更简洁
6. **在四正宫（单星）** → 用 `starInFourZheng`；多星互居四正关系 → 用 `squareGong`
7. **拱照方向明确** → `gongZhao` 中 starA 是主动方（A 拱照 B）
8. **夹宫顺序无关** → `jiaGong` 中 starA/starB 可互换
9. **星宿名用中文** → `constellations` 字段使用中文宿名（如 "毕"、"昴"）
10. **季节用大写** → `seasons` 字段使用 `SPRING`/`SUMMER`/`AUTUMN`/`WINTER`
