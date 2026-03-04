# 📋 Pattern & School 管理页面迁移指南

## 现状分析

### Companion System 当前状态
- ✅ Pattern（格局）管理页面：`lib/pages/pattern_management_page.dart` (已创建但未开发)
- ✅ School（流派）管理页面：`lib/pages/school_management_page.dart` (已创建但未开发)
- ❌ 未实现任何 CRUD 操作
- ❌ 缺少 ViewModel 层

### 主项目的完整实现
主项目 `xuan-qizhengsiyu` 已完整实现：
- ✅ `lib/presentation/pages/ge_ju/ge_ju_list_page.dart` - 列表页面（搜索、筛选、统计）
- ✅ `lib/presentation/pages/ge_ju/ge_ju_editor_page.dart` - 编辑页面（新建、编辑、复制）
- ✅ `lib/presentation/pages/ge_ju/ge_ju_detail_page.dart` - 详情页面
- ✅ `lib/presentation/viewmodels/ge_ju_editor_viewmodel.dart` - 编辑器 ViewModel
- ✅ `lib/presentation/viewmodels/ge_ju_list_viewmodel.dart` - 列表 ViewModel
- ✅ `lib/presentation/widgets/ge_ju/` - 各种 UI 组件和小部件

---

## 迁移方案

### 方案 A：直接复用主项目的页面（推荐 - 快速）

**优点**:
- ✅ 立即可用
- ✅ 功能完整
- ✅ UI 一致
- ✅ 无需重新开发

**步骤**:

#### 1️⃣ 复制页面和 ViewModel

```bash
# 从主项目复制页面
cp -r "/d/星命学/xuan-qizhengsiyu/lib/presentation/pages/ge_ju" \
      "/d/星命学/xuan-qizhengsiyu/companion_system/lib/pages/ge_ju"

# 从主项目复制 ViewModel
cp "/d/星命学/xuan-qizhengsiyu/lib/presentation/viewmodels/ge_ju_*" \
   "/d/星命学/xuan-qizhengsiyu/companion_system/lib/providers/"

# 从主项目复制 Widget
cp -r "/d/星命学/xuan-qizhengsiyu/lib/presentation/widgets/ge_ju" \
      "/d/星命学/xuan-qizhengsiyu/companion_system/lib/widgets/"
```

#### 2️⃣ 修改导入路径

在复制的文件中，将导入改为：

```dart
// 从：
import 'package:qizhengsiyu/...';

// 改为：
import 'package:companion_system/...';
```

**示例**:
```dart
// ge_ju_list_page.dart
import 'package:companion_system/models/...';
import 'package:companion_system/pages/ge_ju/...';
import 'package:companion_system/providers/ge_ju_list_viewmodel.dart';
import 'package:companion_system/widgets/ge_ju/...';
```

#### 3️⃣ 在导航中集成

```dart
// lib/main.dart 或路由配置中
ChangeNotifierProvider<GeJuListViewModel>(
  create: (ctx) => GeJuListViewModel(ctx.read<AppDatabase>()),
),
ChangeNotifierProvider<GeJuEditorViewModel>(
  create: (ctx) => GeJuEditorViewModel(ctx.read<AppDatabase>()),
),
```

---

### 方案 B：基于主项目进行二次开发（推荐 - 定制）

**优点**:
- ✅ 参考完整实现
- ✅ 可以进行定制修改
- ✅ 适应 companion_system 的特定需求
- ✅ 保持代码的独立性

**步骤**:

#### 1️⃣ 参考主项目的架构

```
主项目架构：
lib/presentation/
├── pages/
│   └── ge_ju/
│       ├── ge_ju_list_page.dart      ← 模板
│       ├── ge_ju_editor_page.dart    ← 模板
│       └── ge_ju_detail_page.dart    ← 模板
├── viewmodels/
│   ├── ge_ju_list_viewmodel.dart     ← 模板
│   └── ge_ju_editor_viewmodel.dart   ← 模板
└── widgets/
    ├── ge_ju/
    │   ├── ge_ju_list_tile.dart      ← 模板
    │   └── condition_tree_view.dart  ← 模板
    └── ...
```

#### 2️⃣ 在 companion_system 中实现类似结构

```
companion_system/
lib/
├── pages/
│   ├── pattern_management_page.dart  ← 基于 ge_ju_list_page
│   ├── pattern_editor_page.dart      ← 基于 ge_ju_editor_page
│   ├── school_management_page.dart   ← 新建
│   └── ...
├── providers/
│   ├── pattern_provider.dart         ← ViewModel
│   ├── school_provider.dart          ← ViewModel
│   └── ...
└── widgets/
    ├── pattern_list_tile.dart        ← 自定义
    └── ...
```

#### 3️⃣ 主要页面实现参考

**Pattern 列表页面** (`pattern_management_page.dart`):

基于 `ge_ju_list_page.dart` 的结构：
```dart
class PatternManagementPage extends StatefulWidget {
  const PatternManagementPage({super.key});

  @override
  State<PatternManagementPage> createState() => _PatternManagementPageState();
}

class _PatternManagementPageState extends State<PatternManagementPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PatternProvider>().loadPatterns();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('格局管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToEditor(context),
          ),
        ],
      ),
      body: Consumer<PatternProvider>(
        builder: (context, provider, _) {
          return ListView(
            children: [
              _buildSearchBar(),
              _buildFilterBar(),
              ...provider.patterns.map((p) => PatternListTile(pattern: p)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    // 参考 ge_ju_list_page.dart
  }

  Widget _buildFilterBar() {
    // 参考 ge_ju_list_page.dart
  }

  void _navigateToEditor(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (c) => const PatternEditorPage()),
    );
  }
}
```

**Pattern 编辑页面** (`pattern_editor_page.dart`):

基于 `ge_ju_editor_page.dart` 的结构：
```dart
class PatternEditorPage extends StatefulWidget {
  final String? patternId;

  const PatternEditorPage({super.key, this.patternId});

  @override
  State<PatternEditorPage> createState() => _PatternEditorPageState();
}

class _PatternEditorPageState extends State<PatternEditorPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _englishNameController = TextEditingController();
  final _pinyinController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  Future<void> _initialize() async {
    final provider = context.read<PatternProvider>();
    if (widget.patternId != null) {
      await provider.loadPatternForEdit(widget.patternId!);
    } else {
      provider.initForCreate();
    }
    _syncControllers();
  }

  void _syncControllers() {
    // 从 provider 同步数据到 TextEditingController
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PatternProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(provider.isEditing ? '编辑格局' : '新建格局'),
            actions: [
              TextButton(
                onPressed: provider.canSave ? () => _save(provider) : null,
                child: const Text('保存'),
              ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: '格局名称',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _englishNameController,
                  decoration: const InputDecoration(
                    labelText: '英文名称',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _pinyinController,
                  decoration: const InputDecoration(
                    labelText: '拼音',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: '描述',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _save(PatternProvider provider) async {
    if (_formKey.currentState!.validate()) {
      await provider.savePattern(
        name: _nameController.text,
        englishName: _englishNameController.text,
        pinyin: _pinyinController.text,
        description: _descriptionController.text,
      );
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _englishNameController.dispose();
    _pinyinController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
```

#### 4️⃣ ViewModel/Provider 实现

**PatternProvider** (`lib/providers/pattern_provider.dart`):

```dart
class PatternProvider extends ChangeNotifier {
  final AppDatabase _db;

  List<Pattern> _patterns = [];
  Pattern? _currentPattern;
  bool _isLoading = false;
  String _searchKeyword = '';

  List<Pattern> get patterns => _patterns;
  Pattern? get currentPattern => _currentPattern;
  bool get isLoading => _isLoading;
  bool get isEditing => _currentPattern != null;
  bool get canSave => _currentPattern != null;

  PatternProvider(this._db);

  // 加载所有格局
  Future<void> loadPatterns() async {
    _isLoading = true;
    notifyListeners();

    try {
      _patterns = await _db.geJuPatternsDao.getAllPatterns();
      _isLoading = false;
    } catch (e) {
      print('加载格局失败: $e');
      _isLoading = false;
    }
    notifyListeners();
  }

  // 加载单个格局进行编辑
  Future<void> loadPatternForEdit(String patternId) async {
    _currentPattern = await _db.geJuPatternsDao.getPatternById(patternId);
    notifyListeners();
  }

  // 初始化新建模式
  void initForCreate() {
    _currentPattern = null;
    notifyListeners();
  }

  // 保存格局
  Future<void> savePattern({
    required String name,
    required String englishName,
    required String pinyin,
    required String description,
  }) async {
    try {
      if (isEditing) {
        // 更新
        final updated = _currentPattern!.copyWith(
          name: name,
          englishName: englishName,
          pinyin: pinyin,
          description: description,
        );
        await _db.geJuPatternsDao.updatePattern(updated);
      } else {
        // 新建
        final pattern = Pattern(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name,
          englishName: englishName,
          pinyin: pinyin,
          description: description,
          categoryId: 'default',
          createdAt: DateTime.now(),
        );
        await _db.geJuPatternsDao.insertPattern(pattern);
      }
      await loadPatterns();
    } catch (e) {
      print('保存格局失败: $e');
      rethrow;
    }
  }

  // 删除格局
  Future<void> deletePattern(String patternId) async {
    try {
      await _db.geJuPatternsDao.deletePattern(patternId);
      await loadPatterns();
    } catch (e) {
      print('删除格局失败: $e');
      rethrow;
    }
  }

  // 搜索
  Future<void> search(String keyword) async {
    _searchKeyword = keyword;
    if (keyword.isEmpty) {
      await loadPatterns();
    } else {
      _patterns = _patterns
          .where((p) =>
              p.name.contains(keyword) ||
              (p.englishName?.contains(keyword) ?? false) ||
              (p.description?.contains(keyword) ?? false))
          .toList();
    }
    notifyListeners();
  }
}
```

---

## 快速实施步骤

### 使用方案 A（直接复用）

```bash
cd "D:\星命学\xuan-qizhengsiyu\companion_system"

# 1. 创建必要目录
mkdir -p lib/pages/ge_ju
mkdir -p lib/providers
mkdir -p lib/widgets/ge_ju

# 2. 复制文件（需要手动在 Windows 文件管理器中完成）
#    源：D:\星命学\xuan-qizhengsiyu\lib\presentation\pages\ge_ju
#    目标：D:\星命学\xuan-qizhengsiyu\companion_system\lib\pages\ge_ju

# 3. 修改导入路径（使用编辑器的查找替换功能）
#    pattern: 'package:qizhengsiyu/'
#    replacement: 'package:companion_system/'

# 4. 运行代码检查
flutter analyze

# 5. 如果有缺失的导入，逐一添加
```

---

## 关键文件清单

### 需要复制的文件（方案 A）

```
从主项目复制：
├── lib/presentation/pages/ge_ju/
│   ├── ge_ju_list_page.dart
│   ├── ge_ju_editor_page.dart
│   └── ge_ju_detail_page.dart
├── lib/presentation/viewmodels/
│   ├── ge_ju_list_viewmodel.dart
│   └── ge_ju_editor_viewmodel.dart
└── lib/presentation/widgets/ge_ju/
    ├── ge_ju_list_tile.dart
    ├── condition_tree_view.dart
    └── ... (其他组件)
```

### 需要新建的文件（方案 B）

```
在 companion_system 中新建：
├── lib/pages/
│   ├── pattern_management_page.dart      ← 格局列表
│   ├── pattern_editor_page.dart          ← 格局编辑
│   ├── school_management_page.dart       ← 流派列表
│   └── school_editor_page.dart           ← 流派编辑
├── lib/providers/
│   ├── pattern_provider.dart             ← ViewModel
│   └── school_provider.dart              ← ViewModel
└── lib/widgets/
    ├── pattern_list_tile.dart
    └── school_list_tile.dart
```

---

## 总结

### 推荐方案：**方案 A + 局部定制**

1. ✅ **快速**：直接复用主项目的完整实现
2. ✅ **可靠**：经过验证的代码
3. ✅ **灵活**：根据需要调整细节

### 时间估计

- 复制和导入修改：30 分钟
- 代码调试：30 分钟
- 测试验证：30 分钟
- **总计**：约 1.5 小时

### 下一步

请告诉我：
- 你倾向使用哪个方案？
- 需要我帮助复制文件并修改导入路径吗？
- 是否需要为 School（流派）也实现类似的管理页面？

