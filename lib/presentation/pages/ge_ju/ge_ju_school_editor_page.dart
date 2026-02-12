import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qizhengsiyu/presentation/viewmodels/ge_ju_school_editor_viewmodel.dart';

/// 流派编辑器页面
class GeJuSchoolEditorPage extends StatefulWidget {
  final String? schoolId;

  const GeJuSchoolEditorPage({super.key, this.schoolId});

  @override
  State<GeJuSchoolEditorPage> createState() => _GeJuSchoolEditorPageState();
}

class _GeJuSchoolEditorPageState extends State<GeJuSchoolEditorPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _briefController = TextEditingController();
  final _featureController = TextEditingController();

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  Future<void> _initialize() async {
    final viewModel = context.read<GeJuSchoolEditorViewModel>();

    if (widget.schoolId != null) {
      await viewModel.initForEdit(widget.schoolId!);
    } else {
      viewModel.initForCreate();
    }

    _nameController.text = viewModel.name;
    _briefController.text = viewModel.brief;
    setState(() => _isInitialized = true);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _briefController.dispose();
    _featureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GeJuSchoolEditorViewModel>(
      builder: (context, viewModel, _) {
        return WillPopScope(
          onWillPop: () => _confirmDiscard(viewModel),
          child: Scaffold(
            appBar: AppBar(
              title: Text(viewModel.pageTitle),
              actions: [
                if (!viewModel.isReadOnly)
                  TextButton(
                    onPressed: viewModel.canSave ? () => _save(viewModel) : null,
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

  Widget _buildBody(GeJuSchoolEditorViewModel viewModel) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorMessage != null && !_isInitialized) {
      return Center(child: Text(viewModel.errorMessage!));
    }

    final isReadOnly = viewModel.isReadOnly;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Name
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: '流派名称 *',
              hintText: '如：天官五星',
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
          const SizedBox(height: 16),

          // Brief
          TextFormField(
            controller: _briefController,
            decoration: const InputDecoration(
              labelText: '简介',
              hintText: '对该流派的简要描述',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            readOnly: isReadOnly,
            onChanged: viewModel.updateBrief,
          ),
          const SizedBox(height: 16),

          // Features
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('特点',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...List.generate(viewModel.features.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(viewModel.features[index]),
                          ),
                          if (!isReadOnly)
                            IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () => viewModel.removeFeature(index),
                            ),
                        ],
                      ),
                    );
                  }),
                  if (!isReadOnly) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _featureController,
                            decoration: const InputDecoration(
                              hintText: '添加特点',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            onSubmitted: (value) {
                              if (value.trim().isNotEmpty) {
                                viewModel.addFeature(value);
                                _featureController.clear();
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            final text = _featureController.text;
                            if (text.trim().isNotEmpty) {
                              viewModel.addFeature(text);
                              _featureController.clear();
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _save(GeJuSchoolEditorViewModel viewModel) async {
    if (!_formKey.currentState!.validate()) return;

    final success = await viewModel.save();
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存成功')),
      );
      Navigator.pop(context, true);
    }
  }

  Future<bool> _confirmDiscard(GeJuSchoolEditorViewModel viewModel) async {
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
}
