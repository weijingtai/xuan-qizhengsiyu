import 'package:flutter/material.dart';
import 'package:qizhengsiyu/presentation/models/condition_editor_node.dart';
import 'package:qizhengsiyu/presentation/models/condition_type_registry.dart';
import 'package:qizhengsiyu/presentation/widgets/ge_ju/condition_leaf_editor.dart';
import 'package:qizhengsiyu/presentation/widgets/ge_ju/condition_type_picker.dart';
import 'package:qizhengsiyu/l10n/generated/app_localizations.dart';

/// 可交互的条件树编辑器
class ConditionTreeEditor extends StatelessWidget {
  final ConditionEditorNode? rootNode;
  final bool readOnly;
  final ValueChanged<ConditionEditorNode?> onChanged;

  const ConditionTreeEditor({
    super.key,
    required this.rootNode,
    required this.readOnly,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (rootNode == null) {
      if (readOnly) {
        return Text(
          '(无判断条件)',
          style: TextStyle(
              color: Colors.grey.shade500, fontStyle: FontStyle.italic),
        );
      }
      return _buildEmptyState(context);
    }
    return _buildNode(context, rootNode!, null, 0);
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(
        child: Column(
          children: [
            Text('(无判断条件)',
                style: TextStyle(color: Colors.grey.shade500)),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.add, size: 18),
              label: const Text('添加根条件'),
              onPressed: () => _addRootCondition(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addRootCondition(BuildContext context) async {
    final result = await showConditionTypePicker(context);
    if (result == null || !context.mounted) return;

    if (result.isLogic) {
      onChanged(ConditionEditorNode.logic(result.logicType!));
    } else {
      final node = await showConditionLeafEditor(
        context,
        definition: result.definition!,
      );
      if (node != null) {
        onChanged(node);
      }
    }
  }

  Widget _buildNode(BuildContext context, ConditionEditorNode node,
      ConditionEditorNode? parent, int depth) {
    if (node.isLogic) {
      return _buildLogicNode(context, node, parent, depth);
    } else {
      return _buildLeafNode(context, node, parent, depth);
    }
  }

  Widget _buildLogicNode(BuildContext context, ConditionEditorNode node,
      ConditionEditorNode? parent, int depth) {
    final color = _logicColor(node.conditionType);
    final label = _logicLabel(node.conditionType);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logic label with actions
        Row(
          children: [
            _buildLogicBadge(label, color),
            if (!readOnly) ...[
              const SizedBox(width: 4),
              _NodePopupMenu(
                isLogic: true,
                conditionType: node.conditionType,
                onDelete: () => _deleteNode(node, parent),
                onWrap: (logicType) => _wrapNode(node, parent, logicType),
                onChangeLogic: (newType) =>
                    _changeLogicType(node, parent, newType),
              ),
            ],
          ],
        ),
        // Children
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < node.children.length; i++) ...[
                if (i > 0) const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTreeLine(),
                    const SizedBox(width: 4),
                    Expanded(
                      child: _buildNode(
                          context, node.children[i], node, depth + 1),
                    ),
                  ],
                ),
              ],
              // Add button for logic nodes
              if (!readOnly && _canAddChild(node)) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildTreeLine(),
                    const SizedBox(width: 4),
                    _AddChildButton(
                      onPressed: () => _addChild(context, node),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  bool _canAddChild(ConditionEditorNode node) {
    if (!node.isLogic) return false;
    if (node.isNot && node.children.isNotEmpty) return false;
    return true;
  }

  Widget _buildLeafNode(BuildContext context, ConditionEditorNode node,
      ConditionEditorNode? parent, int depth) {
    String description;
    try {
      description = node.describe();
    } catch (_) {
      description = '${node.displayName}: ${node.params}';
    }

    return GestureDetector(
      onTap: readOnly ? null : () => _editLeaf(context, node, parent),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                description,
                style: const TextStyle(fontSize: 13),
              ),
            ),
            if (!readOnly) ...[
              const SizedBox(width: 4),
              _NodePopupMenu(
                isLogic: false,
                conditionType: node.conditionType,
                onDelete: () => _deleteNode(node, parent),
                onWrap: (logicType) => _wrapNode(node, parent, logicType),
                onChangeLogic: null,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _editLeaf(BuildContext context, ConditionEditorNode node,
      ConditionEditorNode? parent) async {
    final definition = ConditionTypeRegistry.getByType(node.conditionType);
    if (definition == null) return;

    final result = await showConditionLeafEditor(
      context,
      definition: definition,
      existingParams: Map<String, dynamic>.from(node.params),
    );
    if (result == null) return;

    // Replace the node in-place
    final newRoot = rootNode!.copy(generateNewId: false);
    if (newRoot.id == node.id) {
      onChanged(result);
    } else {
      newRoot.replaceChild(node.id, result);
      onChanged(newRoot);
    }
  }

  Future<void> _addChild(
      BuildContext context, ConditionEditorNode parent) async {
    final result = await showConditionTypePicker(context);
    if (result == null || !context.mounted) return;

    ConditionEditorNode? newChild;
    if (result.isLogic) {
      newChild = ConditionEditorNode.logic(result.logicType!);
    } else {
      newChild = await showConditionLeafEditor(
        context,
        definition: result.definition!,
      );
    }

    if (newChild == null) return;

    final newRoot = rootNode!.copy(generateNewId: false);
    final targetParent = newRoot.findChild(parent.id);
    if (targetParent != null) {
      targetParent.addChild(newChild);
    }
    onChanged(newRoot);
  }

  void _deleteNode(ConditionEditorNode node, ConditionEditorNode? parent) {
    if (parent == null) {
      // Deleting root
      onChanged(null);
      return;
    }
    final newRoot = rootNode!.copy(generateNewId: false);
    _removeNodeFromTree(newRoot, node.id);
    onChanged(newRoot);
  }

  void _removeNodeFromTree(ConditionEditorNode root, String nodeId) {
    root.removeChild(nodeId);
    for (var child in root.children) {
      _removeNodeFromTree(child, nodeId);
    }
  }

  void _wrapNode(ConditionEditorNode node, ConditionEditorNode? parent,
      String logicType) {
    if (parent == null) {
      // Wrapping root
      final wrapper =
          ConditionEditorNode.logic(logicType, children: [rootNode!]);
      onChanged(wrapper);
      return;
    }
    final newRoot = rootNode!.copy(generateNewId: false);
    _wrapNodeInTree(newRoot, node.id, logicType);
    onChanged(newRoot);
  }

  void _wrapNodeInTree(
      ConditionEditorNode parent, String nodeId, String logicType) {
    for (int i = 0; i < parent.children.length; i++) {
      if (parent.children[i].id == nodeId) {
        final original = parent.children[i];
        parent.children[i] =
            ConditionEditorNode.logic(logicType, children: [original]);
        return;
      }
      _wrapNodeInTree(parent.children[i], nodeId, logicType);
    }
  }

  void _changeLogicType(ConditionEditorNode node, ConditionEditorNode? parent,
      String newType) {
    final newRoot = rootNode!.copy(generateNewId: false);
    final target = newRoot.findChild(node.id);
    if (target != null) {
      target.conditionType = newType;
    }
    onChanged(newRoot);
  }

  // ============================================================
  // Style helpers (matching ConditionTreeView)
  // ============================================================

  Widget _buildLogicBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildTreeLine() {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Icon(
        Icons.subdirectory_arrow_right,
        size: 14,
        color: Colors.grey.shade400,
      ),
    );
  }

  static Color _logicColor(String type) {
    switch (type) {
      case 'and':
        return Colors.blue;
      case 'or':
        return Colors.orange;
      case 'not':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  static String _logicLabel(String type) {
    switch (type) {
      case 'and':
        return 'AND';
      case 'or':
        return 'OR';
      case 'not':
        return 'NOT';
      default:
        return type.toUpperCase();
    }
  }
}

// ============================================================
// Supporting widgets
// ============================================================

class _NodePopupMenu extends StatelessWidget {
  final bool isLogic;
  final String conditionType;
  final VoidCallback onDelete;
  final void Function(String logicType) onWrap;
  final void Function(String newType)? onChangeLogic;

  const _NodePopupMenu({
    required this.isLogic,
    required this.conditionType,
    required this.onDelete,
    required this.onWrap,
    required this.onChangeLogic,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, size: 18, color: Colors.grey.shade600),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      itemBuilder: (context) => [
        if (isLogic && onChangeLogic != null) ...[
          if (conditionType != 'and')
            const PopupMenuItem(value: 'toAnd', child: Text('改为 AND')),
          if (conditionType != 'or')
            const PopupMenuItem(value: 'toOr', child: Text('改为 OR')),
          if (conditionType != 'not')
            const PopupMenuItem(value: 'toNot', child: Text('改为 NOT')),
          const PopupMenuDivider(),
        ],
        const PopupMenuItem(value: 'wrapAnd', child: Text('包裹 AND')),
        const PopupMenuItem(value: 'wrapOr', child: Text('包裹 OR')),
        const PopupMenuItem(value: 'wrapNot', child: Text('包裹 NOT')),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'delete',
          child: Text(AppLocalizations.of(context)!.delete, style: TextStyle(color: Colors.red.shade700)),
        ),
      ],
      onSelected: (action) {
        switch (action) {
          case 'toAnd':
            onChangeLogic?.call('and');
            break;
          case 'toOr':
            onChangeLogic?.call('or');
            break;
          case 'toNot':
            onChangeLogic?.call('not');
            break;
          case 'wrapAnd':
            onWrap('and');
            break;
          case 'wrapOr':
            onWrap('or');
            break;
          case 'wrapNot':
            onWrap('not');
            break;
          case 'delete':
            onDelete();
            break;
        }
      },
    );
  }
}

class _AddChildButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _AddChildButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: Colors.grey.shade300,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, size: 14, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Text(
              '添加子条件',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
