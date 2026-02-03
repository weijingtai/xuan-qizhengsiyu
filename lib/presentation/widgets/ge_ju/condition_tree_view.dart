import 'package:flutter/material.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_condition.dart';

/// 条件树展示组件（只读）
class ConditionTreeView extends StatelessWidget {
  final GeJuCondition? condition;

  const ConditionTreeView({super.key, this.condition});

  @override
  Widget build(BuildContext context) {
    if (condition == null) {
      return Text(
        '(无判断条件)',
        style: TextStyle(color: Colors.grey.shade500, fontStyle: FontStyle.italic),
      );
    }
    return _buildConditionNode(context, condition!, 0);
  }

  Widget _buildConditionNode(BuildContext context, GeJuCondition cond, int depth) {
    if (cond is AndCondition) {
      return _buildLogicNode(context, 'AND', Colors.blue, cond.conditions, depth);
    } else if (cond is OrCondition) {
      return _buildLogicNode(context, 'OR', Colors.orange, cond.conditions, depth);
    } else if (cond is NotCondition) {
      return _buildNotNode(context, cond, depth);
    } else {
      return _buildLeafNode(context, cond, depth);
    }
  }

  Widget _buildLogicNode(
    BuildContext context,
    String label,
    Color color,
    List<GeJuCondition> children,
    int depth,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLogicLabel(label, color),
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < children.length; i++) ...[
                if (i > 0) const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTreeLine(depth),
                    const SizedBox(width: 4),
                    Expanded(
                      child: _buildConditionNode(context, children[i], depth + 1),
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

  Widget _buildNotNode(BuildContext context, NotCondition cond, int depth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLogicLabel('NOT', Colors.red),
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTreeLine(depth),
              const SizedBox(width: 4),
              Expanded(
                child: _buildConditionNode(context, cond.condition, depth + 1),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeafNode(BuildContext context, GeJuCondition cond, int depth) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        cond.describe(),
        style: const TextStyle(fontSize: 13),
      ),
    );
  }

  Widget _buildLogicLabel(String label, Color color) {
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

  Widget _buildTreeLine(int depth) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Icon(
        Icons.subdirectory_arrow_right,
        size: 14,
        color: Colors.grey.shade400,
      ),
    );
  }
}
