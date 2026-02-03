import 'package:common/enums.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_rule.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju_model.dart';
import 'package:qizhengsiyu/presentation/viewmodels/ge_ju_editor_viewmodel.dart';
import 'package:qizhengsiyu/presentation/widgets/ge_ju/condition_tree_view.dart';

/// 格局编辑器页面
class GeJuEditorPage extends StatefulWidget {
  /// 规则 ID，null 表示新建模式
  final String? ruleId;

  /// 复制来源规则 ID
  final String? duplicateFromId;

  const GeJuEditorPage({
    super.key,
    this.ruleId,
    this.duplicateFromId,
  });

  @override
  State<GeJuEditorPage> createState() => _GeJuEditorPageState();
}

class _GeJuEditorPageState extends State<GeJuEditorPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _classNameController = TextEditingController();
  final _booksController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _sourceController = TextEditingController();

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  Future<void> _initialize() async {
    final viewModel = context.read<GeJuEditorViewModel>();

    if (widget.duplicateFromId != null) {
      await viewModel.initFromDuplicate(widget.duplicateFromId!);
    } else if (widget.ruleId != null) {
      await viewModel.initForEdit(widget.ruleId!);
    } else {
      viewModel.initForCreate();
    }

    _syncControllersFromViewModel(viewModel);
    setState(() => _isInitialized = true);
  }

  void _syncControllersFromViewModel(GeJuEditorViewModel viewModel) {
    _nameController.text = viewModel.name;
    _classNameController.text = viewModel.className;
    _booksController.text = viewModel.books;
    _descriptionController.text = viewModel.description;
    _sourceController.text = viewModel.source;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _classNameController.dispose();
    _booksController.dispose();
    _descriptionController.dispose();
    _sourceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GeJuEditorViewModel>(
      builder: (context, viewModel, _) {
        return WillPopScope(
          onWillPop: () => _confirmDiscard(viewModel),
          child: Scaffold(
            appBar: AppBar(
              title: Text(viewModel.pageTitle),
              actions: [
                if (!viewModel.isBuiltIn)
                  TextButton(
                    onPressed: viewModel.canSave
                        ? () => _save(viewModel)
                        : null,
                    child: const Text('保存'),
                  ),
              ],
            ),
            body: _buildBody(viewModel),
          ),
        );
      },
    );
  }

  Widget _buildBody(GeJuEditorViewModel viewModel) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.saveError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 48, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(viewModel.saveError!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                viewModel.clearError();
                _initialize();
              },
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildBasicInfoSection(viewModel),
          const SizedBox(height: 16),
          _buildPropertiesSection(viewModel),
          const SizedBox(height: 16),
          _buildDescriptionSection(viewModel),
          const SizedBox(height: 16),
          _buildConditionSection(viewModel),
          const SizedBox(height: 16),
          _buildValidationSection(viewModel),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection(GeJuEditorViewModel viewModel) {
    final isReadOnly = viewModel.isBuiltIn;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('基本信息',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '名称 *',
                hintText: '输入格局名称',
                border: OutlineInputBorder(),
              ),
              readOnly: isReadOnly,
              onChanged: viewModel.updateName,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '名称不能为空';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _classNameController,
              decoration: const InputDecoration(
                labelText: '分类 *',
                hintText: '例如：木星格局、火星格局',
                border: OutlineInputBorder(),
              ),
              readOnly: isReadOnly,
              onChanged: viewModel.updateClassName,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '分类不能为空';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _booksController,
              decoration: const InputDecoration(
                labelText: '书籍来源',
                hintText: '例如：果老星宗、天文志',
                border: OutlineInputBorder(),
              ),
              readOnly: isReadOnly,
              onChanged: viewModel.updateBooks,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _sourceController,
              decoration: const InputDecoration(
                labelText: '出处',
                hintText: '具体篇章或引用来源',
                border: OutlineInputBorder(),
              ),
              readOnly: isReadOnly,
              onChanged: viewModel.updateSource,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertiesSection(GeJuEditorViewModel viewModel) {
    final isReadOnly = viewModel.isBuiltIn;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('属性设置',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('吉凶', style: TextStyle(fontSize: 13)),
                      const SizedBox(height: 4),
                      SegmentedButton<JiXiongEnum>(
                        segments: const [
                          ButtonSegment(
                              value: JiXiongEnum.JI, label: Text('吉')),
                          ButtonSegment(
                              value: JiXiongEnum.XIONG, label: Text('凶')),
                          ButtonSegment(
                              value: JiXiongEnum.PING, label: Text('平')),
                        ],
                        selected: {viewModel.jiXiong},
                        onSelectionChanged: isReadOnly
                            ? null
                            : (set) => viewModel.updateJiXiong(set.first),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('适用范围', style: TextStyle(fontSize: 13)),
                      const SizedBox(height: 4),
                      SegmentedButton<GeJuScope>(
                        segments: const [
                          ButtonSegment(
                              value: GeJuScope.natal, label: Text('命盘')),
                          ButtonSegment(
                              value: GeJuScope.xingxian, label: Text('行限')),
                          ButtonSegment(
                              value: GeJuScope.both, label: Text('通用')),
                        ],
                        selected: {viewModel.scope},
                        onSelectionChanged: isReadOnly
                            ? null
                            : (set) => viewModel.updateScope(set.first),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<GeJuType>(
              decoration: const InputDecoration(
                labelText: '格局类型',
                border: OutlineInputBorder(),
              ),
              value: viewModel.geJuType,
              items: GeJuType.values
                  .map((t) => DropdownMenuItem(
                        value: t,
                        child: Text(_getGeJuTypeLabel(t)),
                      ))
                  .toList(),
              onChanged: isReadOnly
                  ? null
                  : (value) {
                      if (value != null) viewModel.updateGeJuType(value);
                    },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection(GeJuEditorViewModel viewModel) {
    final isReadOnly = viewModel.isBuiltIn;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('描述',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '格局描述',
                hintText: '详细描述该格局的含义和古籍原文',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
              readOnly: isReadOnly,
              onChanged: viewModel.updateDescription,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConditionSection(GeJuEditorViewModel viewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('判断条件',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                if (!viewModel.isBuiltIn)
                  Text(
                    '(暂不支持编辑条件)',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (viewModel.rootConditionNode != null)
              ConditionTreeView(
                condition: viewModel.rootConditionNode!.toCondition(),
              )
            else
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Center(
                  child: Text(
                    '(无判断条件)',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildValidationSection(GeJuEditorViewModel viewModel) {
    final validation = viewModel.validationResult;
    if (validation == null) return const SizedBox.shrink();

    return Card(
      color: validation.isValid ? Colors.green.shade50 : Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  validation.isValid
                      ? Icons.check_circle
                      : Icons.error,
                  color:
                      validation.isValid ? Colors.green : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  validation.isValid ? '验证通过' : '验证失败',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: validation.isValid
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                  ),
                ),
              ],
            ),
            if (validation.errors.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...validation.errors.map((e) => Padding(
                    padding: const EdgeInsets.only(left: 28),
                    child: Text(
                      '- $e',
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  )),
            ],
            if (validation.warnings.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...validation.warnings.map((w) => Padding(
                    padding: const EdgeInsets.only(left: 28),
                    child: Text(
                      '- $w',
                      style: TextStyle(color: Colors.orange.shade700),
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _save(GeJuEditorViewModel viewModel) async {
    if (!_formKey.currentState!.validate()) return;

    viewModel.validate();
    if (!viewModel.canSave) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请修正验证错误后再保存')),
      );
      return;
    }

    final success = await viewModel.save();
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存成功')),
      );
      Navigator.pop(context, true);
    }
  }

  Future<bool> _confirmDiscard(GeJuEditorViewModel viewModel) async {
    if (!viewModel.hasUnsavedChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('放弃修改？'),
        content: const Text('您有未保存的修改，确定要放弃吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('继续编辑'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('放弃'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  String _getGeJuTypeLabel(GeJuType type) {
    switch (type) {
      case GeJuType.pin:
        return '贫';
      case GeJuType.jian:
        return '贱';
      case GeJuType.fu:
        return '富';
      case GeJuType.gui:
        return '贵';
      case GeJuType.yao:
        return '夭';
      case GeJuType.shou:
        return '寿';
      case GeJuType.xian:
        return '贤';
      case GeJuType.yu:
        return '愚';
    }
  }
}
