# 格局管理程序 - 原子任务清单

> 基于 `manager_plans.md` 设计方案的实施任务分解。
> 前置依赖：第一~四阶段（基础框架、条件实现、规则模型、评估引擎）已完成。

---

## 第一阶段：数据层（Data Layer）

### 1.1 错误类型定义

- [x] **M-001** 创建 `lib/domain/errors/ge_ju_errors.dart`
  - 新建文件
  - 实现以下错误类：
    - `GeJuError` 基类
    - `RuleNotFoundError`
    - `RuleValidationError`
    - `BuiltInRuleModificationError`
    - `RuleStorageError`
    - `RuleImportError`
  - 无依赖

### 1.2 本地数据源

- [x] **M-002** 创建 `lib/data/datasources/local/ge_ju_local_data_source.dart`
  - 新建文件
  - 定义接口 `GeJuLocalDataSource`：
    ```dart
    abstract class GeJuLocalDataSource {
      Future<List<GeJuRule>> loadFromAssets(List<String> assetPaths);
      Future<List<GeJuRule>> loadFromUserFile();
      Future<void> saveToUserFile(List<GeJuRule> rules);
      Future<String> getUserRulesFilePath();
    }
    ```
  - 实现 `GeJuLocalDataSourceImpl`：
    - `loadFromAssets()`: 使用 `rootBundle.loadString()` 加载 assets 下的 JSON
    - `loadFromUserFile()`: 使用 `path_provider` 获取文档目录，读取 `ge_ju/user_rules.json`
    - `saveToUserFile()`: 将 `List<GeJuRule>` 序列化为 JSON 并写入文件
    - `getUserRulesFilePath()`: 返回用户规则文件的完整路径
  - 注意事项：
    - 文件不存在时返回空列表而非抛异常
    - 写入前创建目录（如 `ge_ju/` 不存在）
    - 使用 `GeJuRuleParser.parseRules()` 解析 JSON
    - 使用 `GeJuRule.toJson()` 序列化
  - 依赖：`path_provider`, `GeJuRule`, `GeJuRuleParser`

### 1.3 Repository 接口

- [x] **M-003** 创建 `lib/domain/repositories/ge_ju_repository.dart`
  - 新建文件
  - 定义接口 `IGeJuRepository`：
    ```dart
    abstract class IGeJuRepository {
      Future<List<GeJuRule>> loadBuiltInRules();
      Future<List<GeJuRule>> loadUserRules();
      Future<List<GeJuRule>> loadAllRules();
      Future<void> saveUserRule(GeJuRule rule);
      Future<void> saveUserRules(List<GeJuRule> rules);
      Future<void> deleteUserRule(String ruleId);
      Future<String> exportRules(List<GeJuRule> rules);
      Future<List<GeJuRule>> importRules(String jsonContent);
      bool isBuiltInRule(String ruleId);
    }
    ```
  - 无实现代码，纯接口
  - 依赖：`GeJuRule`

### 1.4 Repository 实现

- [x] **M-004** 创建 `lib/data/repositories/ge_ju_repository_impl.dart`
  - 新建文件
  - 实现 `GeJuRepositoryImpl implements IGeJuRepository`
  - 关键实现细节：
    - **内置规则资源路径列表**：
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
    - **缓存机制**：`_builtInRulesCache` 和 `_userRulesCache`
    - **内置规则标识**：所有从 assets 加载的规则 id 记录到 `_builtInRuleIds` Set 中
    - `loadBuiltInRules()`: 从 assets 加载，结果缓存
    - `loadUserRules()`: 从用户文件加载，结果缓存
    - `loadAllRules()`: 合并内置+用户，内置在前
    - `saveUserRule()`: 加载现有用户规则 -> 按 id 查找并替换或追加 -> 保存
    - `deleteUserRule()`: 加载 -> 移除 -> 保存，如果是内置规则抛 `BuiltInRuleModificationError`
    - `exportRules()`: 将规则列表序列化为格式化的 JSON 字符串
    - `importRules()`: 解析 JSON 字符串为规则列表，为每条规则生成新 UUID（避免冲突）
    - `isBuiltInRule()`: 检查 `_builtInRuleIds` 集合
  - 依赖：`IGeJuRepository`, `GeJuLocalDataSource`, `GeJuRule`, 错误类型

---

## 第二阶段：领域层（Domain Layer）

### 2.1 验证结果模型

- [x] **M-005** 创建 `lib/domain/services/ge_ju_validation.dart`
  - 新建文件
  - 定义模型类：
    ```dart
    class ValidationResult {
      final bool isValid;
      final List<String> errors;
      final List<String> warnings;
    }

    class ImportResult {
      final int successCount;
      final int failedCount;
      final List<GeJuRule> importedRules;
      final List<String> errors;
    }

    class GeJuRuleCreateParams {
      final String name;
      final String className;
      final String? books;
      final String description;
      final String? source;
      final JiXiongEnum jiXiong;
      final GeJuType geJuType;
      final GeJuScope scope;
      final GeJuCondition? conditions;
    }
    ```
  - 依赖：`GeJuRule`, `GeJuCondition`, 枚举类型

### 2.2 CRUD Service

- [x] **M-006** 创建 `lib/domain/services/ge_ju_crud_service.dart`
  - 新建文件
  - 实现 `GeJuCrudService` 类
  - **CRUD 方法**：
    - `createRule(GeJuRuleCreateParams params) -> Future<GeJuRule>`
      - 生成 UUID
      - 构建 GeJuRule 对象
      - 调用 `_repository.saveUserRule()`
      - 返回新创建的规则
    - `getRule(String ruleId) -> Future<GeJuRule?>`
      - 从全部规则中查找
    - `getAllRules() -> Future<List<GeJuRule>>`
      - 调用 `_repository.loadAllRules()`
    - `updateRule(GeJuRule rule) -> Future<void>`
      - 检查是否为内置规则（不允许修改）
      - 验证
      - 调用 `_repository.saveUserRule()`
    - `deleteRule(String ruleId) -> Future<void>`
      - 检查是否为内置规则
      - 调用 `_repository.deleteUserRule()`
  - **查询方法**：
    - `searchRules(String keyword) -> Future<List<GeJuRule>>`
      - 搜索 name、description、className、books 字段
      - 关键词不区分大小写
    - `filterByCategory(String category) -> Future<List<GeJuRule>>`
    - `filterByJiXiong(JiXiongEnum jiXiong) -> Future<List<GeJuRule>>`
    - `filterByType(GeJuType type) -> Future<List<GeJuRule>>`
  - **验证方法**：
    - `validateRule(GeJuRule rule) -> ValidationResult`
      - name 不为空
      - className 不为空
      - description 不为空
      - 如果有 conditions，验证条件结构合法
    - `validateCondition(GeJuCondition condition) -> ValidationResult`
      - And/Or 条件至少有1个子条件
      - 叶子条件的参数合法
  - **导入导出方法**：
    - `exportRules(List<String> ruleIds) -> Future<String>`
    - `importRulesFromJson(String jsonContent) -> Future<ImportResult>`
    - `duplicateRule(String ruleId) -> Future<GeJuRule>`
      - 拷贝规则，生成新 UUID，名称加 "(副本)" 后缀
  - 依赖：`IGeJuRepository`, `ValidationResult`, `ImportResult`, `GeJuRuleCreateParams`, `uuid`

---

## 第三阶段：表现层模型（Presentation Models）

### 3.1 条件类型注册表

- [x] **M-007** 创建 `lib/presentation/models/condition_type_registry.dart`
  - 新建文件
  - 定义枚举和模型类：
    - `ConditionParamType` 枚举（star, starList, gong, gongList, constellation...）
    - `ConditionParamDefinition` 类（name, displayName, paramType, required, defaultValue, options）
    - `ConditionTypeDefinition` 类（type, displayName, category, params, description）
  - 定义静态注册表 `ConditionTypeRegistry`：
    - **星曜位置类**（4种）：
      - `starInGong`: 参数(star, gongs)
      - `starInConstellation`: 参数(star, constellations)
      - `starWalkingState`: 参数(star, states)
      - `starInKongWang`: 参数(star)
    - **星曜关系类**（7种）：
      - `sameGong`: 参数(stars)
      - `sameConstellation`: 参数(stars)
      - `oppositeGong`: 参数(stars[2])
      - `trineGong`: 参数(stars)
      - `squareGong`: 参数(stars)
      - `sameJing`: 参数(stars)
      - `sameLuo`: 参数(stars)
    - **命盘结构类**（4种）：
      - `lifeGongAt`: 参数(gongs)
      - `lifeConstellationAt`: 参数(constellations)
      - `starGuardLife`: 参数(star)
      - `starInDestinyGong`: 参数(star, destinyGong)
    - **用神类**（3种）：
      - `starIsSiZhu`: 参数(star, roles)
      - `starFourType`: 参数(star, target, types)
      - `starHasHuaYao`: 参数(star, huaYaos)
    - **时间类**（4种）：
      - `seasonIs`: 参数(seasons)
      - `isDayBirth`: 参数(isDay)
      - `moonPhaseIs`: 参数(phases)
      - `monthIs`: 参数(months)
    - **状态类**（1种）：
      - `starGongStatus`: 参数(star, statuses)
    - **神煞类**（2种）：
      - `starWithShenSha`: 参数(star, shenShaNames)
      - `gongHasShenSha`: 参数(gongIdentifier, shenShaNames)
    - **行限类**（3种）：
      - `xianAtGong`: 参数(gongs)
      - `xianAtConstellation`: 参数(constellations)
      - `xianMeetStar`: 参数(stars)
  - 提供查询方法：
    - `getByType(String type)`
    - `getByCategory(String category)`
    - `get categories -> List<String>`
  - 依赖：枚举类型（`EnumStars`, `EnumTwelveGong` 等）

### 3.2 条件编辑器节点模型

- [x] **M-008** 创建 `lib/presentation/models/condition_editor_node.dart`
  - 新建文件
  - 定义 `ConditionNodeType` 枚举（logic, leaf）
  - 定义 `ConditionEditorNode` 类：
    ```dart
    class ConditionEditorNode {
      final String id;           // UUID
      ConditionNodeType nodeType;
      String conditionType;      // 'and', 'or', 'not', 'starInGong', ...
      Map<String, dynamic> params;
      List<ConditionEditorNode> children;

      GeJuCondition toCondition();
      static ConditionEditorNode fromCondition(GeJuCondition condition);
      String describe();         // 人类可读描述
    }
    ```
  - `toCondition()` 实现：
    - 遍历树，递归将编辑器节点转为 `GeJuCondition` 对象
    - logic 节点 -> And/Or/NotCondition
    - leaf 节点 -> 调用对应的 `XxxCondition` 构造函数
  - `fromCondition()` 实现：
    - 递归将 `GeJuCondition` 对象转为编辑器节点
    - And/Or/NotCondition -> logic 节点
    - 其他 -> leaf 节点，提取 params
  - 依赖：`GeJuCondition`, 所有条件子类, `uuid`

---

## 第四阶段：表现层 ViewModel

### 4.1 列表 ViewModel

- [x] **M-009** 创建 `lib/presentation/viewmodels/ge_ju_list_viewmodel.dart`
  - 新建文件
  - 实现 `GeJuListViewModel extends ChangeNotifier`
  - **状态字段**：
    - `_allRules`: 全部规则列表
    - `_filteredRules`: 筛选后的规则列表
    - `_isLoading`: 加载状态
    - `_errorMessage`: 错误信息
    - `_searchKeyword`: 搜索关键词
    - `_selectedCategory`: 选中的分类
    - `_selectedJiXiong`: 选中的吉凶
    - `_selectedType`: 选中的类型
    - `_selectedScope`: 选中的范围
    - `_showBuiltInOnly` / `_showUserOnly`: 来源筛选
    - `_sortField` / `_sortAscending`: 排序
  - **核心方法**：
    - `loadRules()`: 从 service 加载全部规则，更新状态
    - `_applyFiltersAndSort()`: 内部方法，应用所有筛选和排序
    - `search(String keyword)`: 设置关键词，重新筛选
    - `filterByCategory(String? category)`: 设置分类筛选
    - `filterByJiXiong(JiXiongEnum? jiXiong)`: 设置吉凶筛选
    - `filterByType(GeJuType? type)`: 设置类型筛选
    - `filterByScope(GeJuScope? scope)`: 设置范围筛选
    - `clearFilters()`: 清除所有筛选
    - `sortBy(GeJuSortField field, {bool? ascending})`: 设置排序
    - `deleteRule(String ruleId)`: 删除规则，刷新列表
    - `refreshRules()`: 强制刷新
  - **Getters**：
    - `rules`: 当前显示的规则列表
    - `isLoading`, `errorMessage`
    - `categories`: 所有分类列表（去重）
    - `totalCount`, `builtInCount`, `userCount`: 统计数据
  - 依赖：`GeJuCrudService`, `IGeJuRepository`

### 4.2 编辑器 ViewModel

- [x] **M-010** 创建 `lib/presentation/viewmodels/ge_ju_editor_viewmodel.dart`
  - 新建文件
  - 实现 `GeJuEditorViewModel extends ChangeNotifier`
  - **状态字段**：
    - `_isCreateMode`: 是否为新建模式
    - `_editingRuleId`: 正在编辑的规则 ID
    - `_name`, `_className`, `_books`, `_description`, `_source`: 表单字段
    - `_jiXiong`, `_geJuType`, `_scope`: 枚举字段
    - `_rootConditionNode`: 条件树根节点 (`ConditionEditorNode?`)
    - `_validationResult`: 验证结果
    - `_hasUnsavedChanges`: 是否有未保存的修改
    - `_isSaving`: 保存中状态
  - **初始化方法**：
    - `initForCreate()`: 重置所有字段为默认值
    - `initForEdit(String ruleId)`: 从 service 加载规则，填充表单字段
    - `initFromDuplicate(String ruleId)`: 基于现有规则创建副本
  - **表单更新方法**：
    - `updateName(String value)`: 更新名称，标记未保存
    - `updateClassName(String value)`: 更新分类
    - `updateDescription(String value)`: 更新描述
    - `updateJiXiong(JiXiongEnum value)`: 更新吉凶
    - `updateGeJuType(GeJuType value)`: 更新格局类型
    - `updateScope(GeJuScope value)`: 更新适用范围
    - `updateBooks(String value)`: 更新书籍来源
    - `updateSource(String value)`: 更新出处
  - **条件树操作方法**：
    - `setRootCondition(ConditionEditorNode? node)`: 设置根条件
    - `addConditionToGroup(String groupId, ConditionEditorNode child)`: 向逻辑组添加子条件
    - `removeConditionNode(String nodeId)`: 移除条件节点
    - `updateConditionNode(String nodeId, ConditionEditorNode updated)`: 更新条件节点
    - `wrapInLogicGroup(String nodeId, String logicType)`: 将节点包装为逻辑组
  - **验证与保存**：
    - `validate() -> ValidationResult`: 验证所有字段
    - `save() -> Future<bool>`: 保存规则，返回是否成功
    - `canSave -> bool`: 是否可以保存（验证通过且有修改）
    - `reset()`: 重置到初始状态
  - 依赖：`GeJuCrudService`, `ConditionEditorNode`, `ValidationResult`

---

## 第五阶段：表现层 UI

### 5.1 格局列表页面

- [x] **M-011** 创建 `lib/presentation/pages/ge_ju/ge_ju_list_page.dart`
  - 新建文件
  - 实现 `GeJuListPage extends StatefulWidget`
  - **UI 结构**：
    - AppBar：标题 "格局管理"，带新建按钮
    - 搜索栏：`TextField` + 清除按钮
    - 筛选栏：`Wrap` 包含多个 `FilterChip`/`DropdownButton`
      - 分类筛选
      - 吉凶筛选（吉/凶/平）
      - 类型筛选（贫/贱/富/贵/夭/寿/贤/愚）
      - 范围筛选（命盘/行限/通用）
      - 来源筛选（内置/自定义/全部）
    - 列表主体：`ListView.builder`
      - 每项使用 `GeJuListTile` 组件
      - 显示：名称、分类标签、吉凶标签、类型标签、描述摘要
      - 内置规则用 📌 图标，自定义用 📝 图标
      - 自定义规则显示滑动删除操作
    - 底部统计栏：总数/内置数/自定义数
  - **交互**：
    - 点击 -> 进入详情页
    - 长按/滑动 -> 自定义规则显示删除确认
    - 新建按钮 -> 进入编辑器（创建模式）
    - 下拉刷新
  - 依赖：`GeJuListViewModel`

### 5.2 格局列表项组件

- [x] **M-012** 创建 `lib/presentation/widgets/ge_ju/ge_ju_list_tile.dart`
  - 新建文件
  - 实现 `GeJuListTile extends StatelessWidget`
  - 接收参数：
    - `GeJuRule rule`
    - `bool isBuiltIn`
    - `VoidCallback? onTap`
    - `VoidCallback? onDelete`
    - `VoidCallback? onDuplicate`
  - 显示内容：
    - 第一行：来源图标 + 名称 + 吉凶/类型 Chip
    - 第二行：分类 + 出处
    - 第三行：描述（最多2行，溢出省略）
  - 使用 `PopupMenuButton` 提供操作菜单
  - 依赖：`GeJuRule`, 枚举类型

### 5.3 格局详情页面

- [x] **M-013** 创建 `lib/presentation/pages/ge_ju/ge_ju_detail_page.dart`
  - 新建文件
  - 实现 `GeJuDetailPage extends StatelessWidget`
  - 接收参数：`GeJuRule rule`, `bool isBuiltIn`
  - **UI 结构**：
    - AppBar：返回 + 标题 + 操作按钮（编辑/复制/删除，内置规则隐藏编辑和删除）
    - 基本信息卡片：分类、出处、吉凶、类型、范围
    - 描述卡片：完整描述文本
    - 条件树卡片：
      - 使用 `ConditionTreeView` 组件展示条件树
      - 支持展开/折叠
    - JSON 源码卡片：
      - 折叠显示
      - 复制按钮
      - 格式化显示
  - 依赖：`GeJuRule`, `ConditionTreeView`

### 5.4 条件树展示组件

- [x] **M-014** 创建 `lib/presentation/widgets/ge_ju/condition_tree_view.dart`
  - 新建文件
  - 实现 `ConditionTreeView extends StatelessWidget`
  - 接收参数：`GeJuCondition? condition`
  - **UI 结构**：
    - 递归渲染条件树
    - And/Or 节点：显示逻辑关系文字 + 缩进子节点
    - Not 节点：显示 "非" + 缩进子节点
    - 叶子节点：调用 `condition.describe()` 显示描述
    - 使用缩进和连接线表示层级
  - 依赖：`GeJuCondition` 及所有子类

### 5.5 格局编辑器页面

- [x] **M-015** 创建 `lib/presentation/pages/ge_ju/ge_ju_editor_page.dart`
  - 新建文件
  - 实现 `GeJuEditorPage extends StatefulWidget`
  - 接收参数：`String? ruleId`（null 表示新建）
  - **UI 结构**：
    - AppBar：取消 + 标题（新建/编辑）+ 保存按钮
    - `Form` 表单：
      - 名称 `TextFormField`（必填）
      - 分类 `DropdownButtonFormField`（提供预设选项 + 自定义输入）
      - 出处 `TextFormField`
      - 书籍 `TextFormField`
      - 吉凶 `SegmentedButton<JiXiongEnum>`（吉/凶/平）
      - 类型 `DropdownButtonFormField<GeJuType>`
      - 范围 `SegmentedButton<GeJuScope>`（命盘/行限/通用）
      - 描述 `TextFormField`（多行）
    - 条件编辑区域：
      - 标题 "判断条件" + 添加按钮
      - 使用 `ConditionEditorTree` 组件
    - 底部：验证提示信息
  - **行为**：
    - `initState()` 时根据 `ruleId` 初始化 ViewModel
    - 保存前弹出确认对话框
    - 有未保存修改时返回前弹出提示
  - 依赖：`GeJuEditorViewModel`, `ConditionEditorTree`

### 5.6 条件编辑器树组件

- [ ] **M-016** 创建 `lib/presentation/widgets/ge_ju/condition_editor_tree.dart`
  - 新建文件
  - 实现 `ConditionEditorTree extends StatefulWidget`
  - 接收参数：
    - `ConditionEditorNode? rootNode`
    - `ValueChanged<ConditionEditorNode?> onChanged`
  - **UI 结构**：
    - 若 rootNode 为 null：显示 "添加根条件" 按钮
    - 若 rootNode 存在：递归渲染 `ConditionNodeWidget`
  - **ConditionNodeWidget**（内部 Widget）：
    - 逻辑节点（AND/OR/NOT）：
      - 显示逻辑类型标签 + 切换按钮 + 删除按钮 + 添加子条件按钮
      - 缩进显示子节点列表
      - 支持拖拽排序子条件
    - 叶子节点：
      - 显示条件类型名 + 参数摘要 + 编辑按钮 + 删除按钮
      - 点击编辑按钮弹出 `ConditionEditorDialog`
  - 依赖：`ConditionEditorNode`, `ConditionEditorDialog`

### 5.7 条件编辑器弹窗

- [ ] **M-017** 创建 `lib/presentation/widgets/ge_ju/condition_editor_dialog.dart`
  - 新建文件
  - 实现 `ConditionEditorDialog extends StatefulWidget`
  - 接收参数：
    - `ConditionEditorNode? existingNode`（编辑模式）
    - `ValueChanged<ConditionEditorNode> onConfirm`
  - **UI 结构**：
    - 标题：添加条件 / 编辑条件
    - 条件类型选择：
      - 第一级：分类下拉 `DropdownButton`（星曜位置/星曜关系/命盘结构/用神/时间/...）
      - 第二级：具体类型下拉（跟随分类变化）
    - 参数表单：
      - 根据选中的条件类型，动态渲染参数输入控件
      - `star` -> 星曜下拉选择（11颗星）
      - `starList` -> 多选星曜 (Chip + 添加)
      - `gong` -> 宫位下拉
      - `gongList` -> 多选宫位（12宫 CheckboxListTile）
      - `constellation` -> 星宿下拉
      - `constellationList` -> 多选星宿
      - `walkingStateList` -> 多选运行状态
      - `fourTypeList` -> 多选恩难仇用
      - `huaYaoList` -> 多选化曜
      - `boolean` -> Switch
      - `seasonList` -> 多选季节
      - `moonPhaseList` -> 多选月相
      - `role` / `roleList` -> 四主角色选择
      - `destinyGong` -> 命理十二宫选择
      - `gongStatusList` -> 多选庙旺状态
    - 预览行：显示 `describe()` 结果
    - 底部：取消 + 确定 按钮
  - 使用 `ConditionTypeRegistry` 获取条件类型定义
  - 依赖：`ConditionTypeRegistry`, `ConditionEditorNode`, 枚举类型

### 5.8 参数输入组件

- [ ] **M-018** 创建 `lib/presentation/widgets/ge_ju/condition_param_widgets.dart`
  - 新建文件
  - 实现条件参数的专用输入组件：
    - `StarPickerWidget` - 单星曜选择
    - `StarMultiPickerWidget` - 多星曜选择
    - `GongPickerWidget` - 宫位选择（支持地支/十二次/黄道别名）
    - `GongMultiPickerWidget` - 多宫位选择
    - `ConstellationPickerWidget` - 星宿选择
    - `ConstellationMultiPickerWidget` - 多星宿选择
    - `EnumMultiPickerWidget<T>` - 通用枚举多选
  - 每个组件：
    - 接收当前值和 `onChanged` 回调
    - 使用 `Chip` + `ActionChip` 或 `Wrap` + `FilterChip` 布局
  - 依赖：枚举类型

---

## 第六阶段：依赖注入与路由

### 6.1 依赖注入注册

- [x] **M-019** 修改 `lib/di.dart`
  - 在 `createProviders()` 中添加格局管理相关的 Provider：
    ```dart
    // GeJu DataSource
    Provider<GeJuLocalDataSource>(
      create: (_) => GeJuLocalDataSourceImpl(),
    ),
    // GeJu Repository
    Provider<IGeJuRepository>(
      create: (context) => GeJuRepositoryImpl(
        localDataSource: context.read<GeJuLocalDataSource>(),
      ),
    ),
    // GeJu Service
    Provider<GeJuCrudService>(
      create: (context) => GeJuCrudService(
        repository: context.read<IGeJuRepository>(),
      ),
    ),
    // GeJu ViewModels
    ChangeNotifierProvider<GeJuListViewModel>(
      create: (context) => GeJuListViewModel(
        crudService: context.read<GeJuCrudService>(),
      ),
    ),
    ```
  - 依赖：上述所有新建类

### 6.2 路由注册

- [x] **M-020** 修改路由配置
  - 需要先确认路由系统所在文件（可能为 `example/lib/main.dart` 中的路由表）
  - 添加格局管理相关路由：
    - `/ge_ju/list` -> `GeJuListPage`
    - `/ge_ju/detail` -> `GeJuDetailPage`（带参数）
    - `/ge_ju/create` -> `GeJuEditorPage`（创建模式）
    - `/ge_ju/edit` -> `GeJuEditorPage`（编辑模式，带参数）
  - 依赖：页面文件

### 6.3 资源文件注册

- [x] **M-021** 修改 `example/pubspec.yaml`（如有必要）
  - 在 `flutter.assets` 下添加格局 JSON 文件路径：
    ```yaml
    flutter:
      assets:
        - assets/qizhengsiyu/ge_ju/
    ```
  - 确保目录和文件被正确注册

---

## 第七阶段：测试

### 7.1 单元测试

- [ ] **M-022** 创建 `test/domain/services/ge_ju_crud_service_test.dart`
  - 测试 CRUD 方法
  - Mock `IGeJuRepository`
  - 覆盖：创建、读取、更新、删除、搜索、筛选、验证

- [ ] **M-023** 创建 `test/data/repositories/ge_ju_repository_impl_test.dart`
  - 测试 Repository 实现
  - Mock `GeJuLocalDataSource`
  - 覆盖：加载内置/用户规则、保存、删除、导入导出、内置规则保护

### 7.2 模型测试

- [ ] **M-024** 创建 `test/presentation/models/condition_editor_node_test.dart`
  - 测试条件编辑器节点
  - 覆盖：toCondition() 转换、fromCondition() 解析、嵌套条件树

### 7.3 Widget 测试

- [ ] **M-025** 创建 `test/presentation/pages/ge_ju_list_page_test.dart`
  - 测试列表页面
  - 覆盖：加载显示、搜索、筛选、删除确认

---

## 任务依赖关系

```
M-001 (错误类型) ────────────────────────────────────┐
                                                      │
M-002 (DataSource) ──────┐                            │
                         ├─ M-004 (Repo 实现) ──────── M-006 (Service) ──┐
M-003 (Repo 接口) ───────┘                                               │
                                                                         │
M-005 (验证模型) ──── M-006 (Service) ──────────────────────────────────┤
                                                                         │
M-007 (条件注册表) ── M-008 (编辑器节点) ── M-017 (编辑弹窗) ──────────┤
                                                                         │
                                              M-009 (列表 VM) ──────────┤
                                              M-010 (编辑器 VM) ────────┤
                                                                         │
M-012 (列表项组件) ── M-011 (列表页面) ────────────────────────────────┤
M-014 (条件树展示) ── M-013 (详情页面) ────────────────────────────────┤
M-016 (编辑器树) ──── M-015 (编辑器页面) ──────────────────────────────┤
M-018 (参数组件) ──── M-017 (编辑弹窗) ────────────────────────────────┤
                                                                         │
                                              M-019 (DI 注册) ──────────┤
                                              M-020 (路由注册) ──────────┤
                                              M-021 (资源注册) ──────────┘
                                                         │
                                                         ▼
                                              M-022~M-025 (测试)
```

---

## 任务统计

| 阶段 | 任务数 | 说明 |
|------|--------|------|
| 第一阶段：数据层 | 4 | M-001 ~ M-004 |
| 第二阶段：领域层 | 2 | M-005 ~ M-006 |
| 第三阶段：表现层模型 | 2 | M-007 ~ M-008 |
| 第四阶段：ViewModel | 2 | M-009 ~ M-010 |
| 第五阶段：UI 组件 | 8 | M-011 ~ M-018 |
| 第六阶段：集成 | 3 | M-019 ~ M-021 |
| 第七阶段：测试 | 4 | M-022 ~ M-025 |
| **合计** | **25** | |

---

## 文件清单

### 新建文件

| 序号 | 文件路径 | 任务 | 说明 |
|------|---------|------|------|
| 1 | `lib/domain/errors/ge_ju_errors.dart` | M-001 | 错误类型 |
| 2 | `lib/data/datasources/local/ge_ju_local_data_source.dart` | M-002 | 本地数据源 |
| 3 | `lib/domain/repositories/ge_ju_repository.dart` | M-003 | Repository 接口 |
| 4 | `lib/data/repositories/ge_ju_repository_impl.dart` | M-004 | Repository 实现 |
| 5 | `lib/domain/services/ge_ju_validation.dart` | M-005 | 验证模型 |
| 6 | `lib/domain/services/ge_ju_crud_service.dart` | M-006 | CRUD 服务 |
| 7 | `lib/presentation/models/condition_type_registry.dart` | M-007 | 条件类型注册表 |
| 8 | `lib/presentation/models/condition_editor_node.dart` | M-008 | 条件编辑器节点 |
| 9 | `lib/presentation/viewmodels/ge_ju_list_viewmodel.dart` | M-009 | 列表 ViewModel |
| 10 | `lib/presentation/viewmodels/ge_ju_editor_viewmodel.dart` | M-010 | 编辑器 ViewModel |
| 11 | `lib/presentation/pages/ge_ju/ge_ju_list_page.dart` | M-011 | 列表页面 |
| 12 | `lib/presentation/widgets/ge_ju/ge_ju_list_tile.dart` | M-012 | 列表项组件 |
| 13 | `lib/presentation/pages/ge_ju/ge_ju_detail_page.dart` | M-013 | 详情页面 |
| 14 | `lib/presentation/widgets/ge_ju/condition_tree_view.dart` | M-014 | 条件树展示 |
| 15 | `lib/presentation/pages/ge_ju/ge_ju_editor_page.dart` | M-015 | 编辑器页面 |
| 16 | `lib/presentation/widgets/ge_ju/condition_editor_tree.dart` | M-016 | 条件编辑器树 |
| 17 | `lib/presentation/widgets/ge_ju/condition_editor_dialog.dart` | M-017 | 条件编辑弹窗 |
| 18 | `lib/presentation/widgets/ge_ju/condition_param_widgets.dart` | M-018 | 参数输入组件 |
| 19 | `test/domain/services/ge_ju_crud_service_test.dart` | M-022 | Service 测试 |
| 20 | `test/data/repositories/ge_ju_repository_impl_test.dart` | M-023 | Repository 测试 |
| 21 | `test/presentation/models/condition_editor_node_test.dart` | M-024 | 模型测试 |
| 22 | `test/presentation/pages/ge_ju_list_page_test.dart` | M-025 | Widget 测试 |

### 修改文件

| 序号 | 文件路径 | 任务 | 说明 |
|------|---------|------|------|
| 1 | `lib/di.dart` | M-019 | 添加 Provider 注册 |
| 2 | 路由文件（待确认） | M-020 | 添加格局管理路由 |
| 3 | `example/pubspec.yaml` | M-021 | 注册 ge_ju assets |

---

## 建议的实施顺序

1. **第一批（数据基础）**：M-001 → M-003 → M-002 → M-004 → M-005 → M-006
2. **第二批（模型层）**：M-007 → M-008
3. **第三批（ViewModel）**：M-009 → M-010
4. **第四批（UI 组件）**：M-012 → M-014 → M-018 → M-011 → M-013 → M-016 → M-017 → M-015
5. **第五批（集成）**：M-019 → M-020 → M-021
6. **第六批（测试）**：M-022 → M-023 → M-024 → M-025
