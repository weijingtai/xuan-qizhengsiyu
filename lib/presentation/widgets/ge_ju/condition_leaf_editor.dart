import 'package:flutter/material.dart';
import 'package:qizhengsiyu/presentation/models/condition_editor_node.dart';
import 'package:qizhengsiyu/presentation/models/condition_type_registry.dart';
import 'package:qizhengsiyu/presentation/widgets/ge_ju/condition_param_widgets.dart';

/// 显示叶子条件编辑器对话框
///
/// [definition] 条件类型定义
/// [existingParams] 已有的参数值（编辑模式），null 表示新建
///
/// 返回编辑后的 [ConditionEditorNode]，用户取消时返回 null
Future<ConditionEditorNode?> showConditionLeafEditor(
  BuildContext context, {
  required ConditionTypeDefinition definition,
  Map<String, dynamic>? existingParams,
}) {
  return Navigator.push<ConditionEditorNode>(
    context,
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => _ConditionLeafEditorPage(
        definition: definition,
        existingParams: existingParams,
      ),
    ),
  );
}

class _ConditionLeafEditorPage extends StatefulWidget {
  final ConditionTypeDefinition definition;
  final Map<String, dynamic>? existingParams;

  const _ConditionLeafEditorPage({
    required this.definition,
    this.existingParams,
  });

  @override
  State<_ConditionLeafEditorPage> createState() =>
      _ConditionLeafEditorPageState();
}

class _ConditionLeafEditorPageState extends State<_ConditionLeafEditorPage> {
  late Map<String, dynamic> _params;

  @override
  void initState() {
    super.initState();
    _params = Map<String, dynamic>.from(widget.existingParams ?? {});
    // Initialize defaults for params not yet set
    for (final def in widget.definition.params) {
      if (!_params.containsKey(def.name) && def.defaultValue != null) {
        _params[def.name] = def.defaultValue;
      }
    }
  }

  bool get _isValid {
    for (final def in widget.definition.params) {
      if (def.required) {
        final value = _params[def.name];
        if (value == null) return false;
        if (value is String && value.isEmpty) return false;
        if (value is List && value.isEmpty) return false;
      }
    }
    return true;
  }

  void _save() {
    if (!_isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写所有必填参数')),
      );
      return;
    }
    final node = ConditionEditorNode.leaf(widget.definition.type, _params);
    Navigator.pop(context, node);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.definition.displayName),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('确定'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (widget.definition.description != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.definition.description!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          ...widget.definition.params.map((def) {
            return buildParamEditor(
              def,
              _params[def.name],
              (value) {
                setState(() {
                  _params[def.name] = value;
                });
              },
            );
          }),
        ],
      ),
    );
  }
}
