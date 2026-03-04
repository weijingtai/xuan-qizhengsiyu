# ⚡ Pattern & School 管理 - 快速实施清单

## 🎯 目标

使用主项目 `xuan-qizhengsiyu` 已完成的格局管理实现，快速填充 `companion_system` 的 Pattern 和 School 管理页面。

---

## 📋 主项目已有资源

### 格局（Pattern/GeJu）管理 - 完全开发完毕 ✅

```
主项目位置：xuan-qizhengsiyu/lib/presentation/pages/ge_ju/

已实现的功能：
├── 格局列表页面 (ge_ju_list_page.dart)
│   ├── ✅ 搜索功能
│   ├── ✅ 多条件筛选
│   ├── ✅ 排序
│   ├── ✅ 统计信息
│   └── ✅ 新增/编辑/删除操作
│
├── 格局编辑页面 (ge_ju_editor_page.dart)
│   ├── ✅ 新建格局
│   ├── ✅ 编辑现有格局
│   ├── ✅ 复制格局
│   ├── ✅ 条件编辑器
│   └── ✅ 表单验证
│
├── 格局详情页面 (ge_ju_detail_page.dart)
│   ├── ✅ 显示完整信息
│   └── ✅ 规则查看
│
├── ViewModel (ge_ju_list_viewmodel.dart, ge_ju_editor_viewmodel.dart)
│   ├── ✅ 数据管理
│   ├── ✅ CRUD 操作
│   └── ✅ 状态管理
│
└── UI 组件 (widgets/ge_ju/)
    ├── ✅ 列表项卡片
    ├── ✅ 条件树视图
    └── ✅ 其他辅助组件
```

### 流派（School）管理 - 在主项目中有数据模型

```
主项目数据模型：
├── GeJuSchools 表（Drift 数据库表）
├── School 实体类（ge_ju_model.dart）
└── 部分 UI 组件 (school_selector.dart)

状态：
⚠️  有数据模型，但 UI 管理页面不完整
```

---

## 🚀 快速实施方案

### 方案选择矩阵

| 方案 | Pattern | School | 优点 | 缺点 | 推荐度 |
|------|---------|--------|------|------|--------|
| A: 直接复用 | ✅ 复制 | ✅ 参考实现 | 快速，功能全 | 需要改导入 | ⭐⭐⭐ |
| B: 参考开发 | ✅ 参考 | ✅ 参考 | 高度定制 | 耗时 | ⭐⭐ |
| C: 混合方案 | ✅ 复制 | ✅ 参考实现 | 平衡 | 中等耗时 | ⭐⭐⭐⭐ |

**推荐：方案 C（混合）**

---

## 🛠️ 方案 C - 混合实施

### Phase 1: Pattern 管理（直接复用 - 30分钟）

#### Step 1.1: 复制文件结构

```
主项目目录          →    Companion 目录
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
pages/ge_ju/        →    pages/ge_ju/
viewmodels/ge_ju*   →    providers/（重名为 pattern_provider）
widgets/ge_ju/      →    widgets/ge_ju/
```

#### Step 1.2: 自动化导入替换

使用编辑器的**查找替换**：

```
查找：    import 'package:qizhengsiyu/
替换为：  import 'package:companion_system/
```

#### Step 1.3: 删除不用的页面

```bash
# 删除 companion_system 中的空文件
rm lib/pages/pattern_management_page.dart
rm lib/pages/pattern_editor_page.dart
```

#### Step 1.4: 验证

```bash
flutter analyze
flutter pub get
```

**预期结果**: 0 errors，可能有一些 warnings（可忽略）

---

### Phase 2: School 管理（参考实现 - 45分钟）

#### Step 2.1: 参考 ge_ju 实现 School 列表

参考：`ge_ju_list_page.dart`

创建：`lib/pages/school_list_page.dart`

```dart
class SchoolListPage extends StatefulWidget {
  const SchoolListPage({super.key});

  @override
  State<SchoolListPage> createState() => _SchoolListPageState();
}

class _SchoolListPageState extends State<SchoolListPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SchoolProvider>().loadSchools();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('流派管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToEditor(context),
          ),
        ],
      ),
      body: Consumer<SchoolProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: [
              _buildSearchBar(provider),
              ...provider.schools.map((s) => _buildSchoolTile(s)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(SchoolProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '搜索流派...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onChanged: provider.search,
      ),
    );
  }

  Widget _buildSchoolTile(School school) {
    return ListTile(
      title: Text(school.name),
      subtitle: Text(school.type),
      trailing: SizedBox(
        width: 100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _navigateToEditor(context, schoolId: school.id),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _confirmDelete(context, school.id),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToEditor(BuildContext context, {String? schoolId}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (c) => SchoolEditorPage(schoolId: schoolId),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String schoolId) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个流派吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('取消')),
          TextButton(
            onPressed: () {
              context.read<SchoolProvider>().deleteSchool(schoolId);
              Navigator.pop(c);
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
```

#### Step 2.2: 创建 School 编辑页面

参考：`ge_ju_editor_page.dart`

创建：`lib/pages/school_editor_page.dart`

```dart
class SchoolEditorPage extends StatefulWidget {
  final String? schoolId;

  const SchoolEditorPage({super.key, this.schoolId});

  @override
  State<SchoolEditorPage> createState() => _SchoolEditorPageState();
}

class _SchoolEditorPageState extends State<SchoolEditorPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _eraController = TextEditingController();
  final _founderController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  Future<void> _initialize() async {
    final provider = context.read<SchoolProvider>();
    if (widget.schoolId != null) {
      await provider.loadSchoolForEdit(widget.schoolId!);
      _syncControllers();
    }
  }

  void _syncControllers() {
    final provider = context.read<SchoolProvider>();
    if (provider.currentSchool != null) {
      _nameController.text = provider.currentSchool!.name;
      _typeController.text = provider.currentSchool!.type;
      _eraController.text = provider.currentSchool!.era ?? '';
      _founderController.text = provider.currentSchool!.founder ?? '';
      _descriptionController.text = provider.currentSchool!.description ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.schoolId != null ? '编辑流派' : '新建流派'),
        actions: [
          TextButton(
            onPressed: () => _save(),
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
                labelText: '流派名称',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v?.isEmpty ?? true ? '请输入流派名称' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _typeController,
              decoration: const InputDecoration(
                labelText: '流派类型',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v?.isEmpty ?? true ? '请输入流派类型' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _eraController,
              decoration: const InputDecoration(
                labelText: '时代',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _founderController,
              decoration: const InputDecoration(
                labelText: '创始人',
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
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<SchoolProvider>();
      await provider.saveSchool(
        id: widget.schoolId,
        name: _nameController.text,
        type: _typeController.text,
        era: _eraController.text,
        founder: _founderController.text,
        description: _descriptionController.text,
      );
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _eraController.dispose();
    _founderController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
```

#### Step 2.3: 创建 SchoolProvider

创建：`lib/providers/school_provider.dart`

```dart
class SchoolProvider extends ChangeNotifier {
  final AppDatabase _db;

  List<School> _schools = [];
  School? _currentSchool;
  bool _isLoading = false;

  List<School> get schools => _schools;
  School? get currentSchool => _currentSchool;
  bool get isLoading => _isLoading;

  SchoolProvider(this._db);

  Future<void> loadSchools() async {
    _isLoading = true;
    notifyListeners();

    try {
      _schools = await _db.geJuSchoolsDao.getAllSchools();
    } catch (e) {
      print('加载流派失败: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadSchoolForEdit(String schoolId) async {
    _currentSchool = await _db.geJuSchoolsDao.getSchoolById(schoolId);
    notifyListeners();
  }

  Future<void> saveSchool({
    String? id,
    required String name,
    required String type,
    String? era,
    String? founder,
    String? description,
  }) async {
    try {
      if (id != null) {
        // 更新
        final updated = School(
          id: id,
          name: name,
          type: type,
          era: era,
          founder: founder,
          description: description,
          isActive: true,
          ruleCount: _currentSchool?.ruleCount ?? 0,
          createdAt: _currentSchool?.createdAt ?? DateTime.now(),
        );
        await _db.geJuSchoolsDao.updateSchool(updated);
      } else {
        // 新建
        final school = School(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name,
          type: type,
          era: era,
          founder: founder,
          description: description,
          isActive: true,
          ruleCount: 0,
          createdAt: DateTime.now(),
        );
        await _db.geJuSchoolsDao.insertSchool(school);
      }
      await loadSchools();
    } catch (e) {
      print('保存流派失败: $e');
      rethrow;
    }
  }

  Future<void> deleteSchool(String schoolId) async {
    try {
      await _db.geJuSchoolsDao.deleteSchool(schoolId);
      await loadSchools();
    } catch (e) {
      print('删除流派失败: $e');
      rethrow;
    }
  }

  Future<void> search(String keyword) async {
    await loadSchools();
    if (keyword.isNotEmpty) {
      _schools = _schools
          .where((s) =>
              s.name.contains(keyword) ||
              s.type.contains(keyword) ||
              (s.description?.contains(keyword) ?? false))
          .toList();
    }
    notifyListeners();
  }
}
```

---

## ✅ 实施清单

### Phase 1: Pattern 管理

- [ ] 从主项目复制 `lib/presentation/pages/ge_ju/` → `companion_system/lib/pages/ge_ju/`
- [ ] 从主项目复制 `lib/presentation/viewmodels/ge_ju_*` → `companion_system/lib/providers/`
- [ ] 从主项目复制 `lib/presentation/widgets/ge_ju/` → `companion_system/lib/widgets/ge_ju/`
- [ ] 修改所有导入路径 (`package:qizhengsiyu/` → `package:companion_system/`)
- [ ] 删除 `lib/pages/pattern_management_page.dart` 和 `lib/pages/pattern_editor_page.dart`
- [ ] 运行 `flutter analyze` 验证
- [ ] 在 `lib/main.dart` 中注册 Provider
- [ ] 测试 Pattern 管理功能

### Phase 2: School 管理

- [ ] 创建 `lib/pages/school_list_page.dart`
- [ ] 创建 `lib/pages/school_editor_page.dart`
- [ ] 创建 `lib/providers/school_provider.dart`
- [ ] 删除 `lib/pages/school_management_page.dart`
- [ ] 在 `lib/main.dart` 中注册 SchoolProvider
- [ ] 运行 `flutter analyze` 验证
- [ ] 测试 School 管理功能

### Phase 3: 集成

- [ ] 更新导航菜单添加 Pattern 和 School 入口
- [ ] 添加路由配置
- [ ] 全应用测试

---

## ⏱️ 时间估计

| 阶段 | 任务 | 时间 |
|------|------|------|
| Phase 1 | Pattern 复用 | 30 分钟 |
| Phase 2 | School 开发 | 45 分钟 |
| Phase 3 | 集成与测试 | 30 分钟 |
| **总计** | | **约 2 小时** |

---

## 📌 关键注意事项

1. **导入路径**: 确保所有导入都改为 `package:companion_system/`
2. **DAO 方法**: 确保数据库 DAO 中有相应的方法（getAllSchools, getSchoolById 等）
3. **Provider 注册**: 在 `main.dart` 中正确注册所有 Provider
4. **数据库**: 确保 AppDatabase 已包含 GeJuSchools 表

---

## 🎯 最终结果

完成后，companion_system 将具有：
- ✅ 完整的 Pattern（格局）管理界面
- ✅ 完整的 School（流派）管理界面
- ✅ CRUD 操作（增删改查）
- ✅ 搜索和筛选功能
- ✅ 与主项目一致的 UI/UX

