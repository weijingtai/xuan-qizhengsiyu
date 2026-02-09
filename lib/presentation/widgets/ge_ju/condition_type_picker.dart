import 'package:flutter/material.dart';
import 'package:qizhengsiyu/presentation/models/condition_type_registry.dart';

/// 条件类型选择结果
class ConditionTypePickerResult {
  /// 逻辑类型: 'and', 'or', 'not'；为 null 时表示选择了叶子条件
  final String? logicType;

  /// 叶子条件定义；为 null 时表示选择了逻辑类型
  final ConditionTypeDefinition? definition;

  const ConditionTypePickerResult._({this.logicType, this.definition});

  factory ConditionTypePickerResult.logic(String type) =>
      ConditionTypePickerResult._(logicType: type);

  factory ConditionTypePickerResult.leaf(ConditionTypeDefinition def) =>
      ConditionTypePickerResult._(definition: def);

  bool get isLogic => logicType != null;
  bool get isLeaf => definition != null;
}

/// 显示条件类型选择器底部弹窗
Future<ConditionTypePickerResult?> showConditionTypePicker(
    BuildContext context) {
  return showModalBottomSheet<ConditionTypePickerResult>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => const _ConditionTypePickerSheet(),
  );
}

class _ConditionTypePickerSheet extends StatelessWidget {
  const _ConditionTypePickerSheet();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle bar
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Text(
                    '添加条件',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Content
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  const SizedBox(height: 12),
                  // Logic operators section
                  const Text(
                    '逻辑运算',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _LogicChip(
                        label: 'AND (且)',
                        color: Colors.blue,
                        onTap: () => Navigator.pop(
                          context,
                          ConditionTypePickerResult.logic('and'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _LogicChip(
                        label: 'OR (或)',
                        color: Colors.orange,
                        onTap: () => Navigator.pop(
                          context,
                          ConditionTypePickerResult.logic('or'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _LogicChip(
                        label: 'NOT (非)',
                        color: Colors.red,
                        onTap: () => Navigator.pop(
                          context,
                          ConditionTypePickerResult.logic('not'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  // Categorized conditions
                  ...ConditionTypeRegistry.categories.map(
                    (category) => _CategorySection(category: category),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LogicChip extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _LogicChip({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withOpacity(0.4)),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final String category;

  const _CategorySection({required this.category});

  @override
  Widget build(BuildContext context) {
    final types = ConditionTypeRegistry.getByCategory(category);
    if (types.isEmpty) return const SizedBox.shrink();

    return ExpansionTile(
      title: Text(
        category,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      initiallyExpanded: false,
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 8),
      children: types.map((def) {
        return ListTile(
          dense: true,
          contentPadding: const EdgeInsets.only(left: 8),
          title: Text(def.displayName),
          subtitle: def.description != null
              ? Text(
                  def.description!,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                )
              : null,
          trailing: const Icon(Icons.add, size: 20),
          onTap: () => Navigator.pop(
            context,
            ConditionTypePickerResult.leaf(def),
          ),
        );
      }).toList(),
    );
  }
}
