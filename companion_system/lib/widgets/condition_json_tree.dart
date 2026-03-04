/// 条件 JSON 树形可视化 Widget
library;

import 'dart:convert';
import 'package:flutter/material.dart';

/// 将 conditions JSON 字符串或对象渲染为树形结构。
class ConditionJsonTree extends StatelessWidget {
  /// 传入已解析的 Map，或 null（显示「无条件」）
  final Map<String, dynamic>? conditionMap;

  const ConditionJsonTree({super.key, this.conditionMap});

  /// 从 JSON 字符串构建
  factory ConditionJsonTree.fromString(String? jsonStr) {
    if (jsonStr == null || jsonStr.trim().isEmpty) {
      return const ConditionJsonTree(conditionMap: null);
    }
    try {
      final parsed = jsonDecode(jsonStr);
      if (parsed is Map<String, dynamic>) {
        return ConditionJsonTree(conditionMap: parsed);
      }
    } catch (_) {}
    return const ConditionJsonTree(conditionMap: null);
  }

  @override
  Widget build(BuildContext context) {
    if (conditionMap == null) {
      return Text(
        '（无条件）',
        style: TextStyle(
          color: Theme.of(context).colorScheme.outline,
          fontStyle: FontStyle.italic,
        ),
      );
    }
    return _ConditionNode(node: conditionMap!, depth: 0);
  }
}

class _ConditionNode extends StatelessWidget {
  final Map<String, dynamic> node;
  final int depth;

  const _ConditionNode({required this.node, required this.depth});

  @override
  Widget build(BuildContext context) {
    final type = node['type'] as String? ?? '?';

    switch (type) {
      case 'and':
        return _LogicNode(
          label: 'AND',
          color: const Color(0xFF1565C0),
          children: _parseChildren(node['conditions']),
          depth: depth,
        );
      case 'or':
        return _LogicNode(
          label: 'OR',
          color: const Color(0xFFE65100),
          children: _parseChildren(node['conditions']),
          depth: depth,
        );
      case 'not':
        final child = node['condition'];
        return _LogicNode(
          label: 'NOT',
          color: const Color(0xFFC62828),
          children: child is Map<String, dynamic> ? [child] : [],
          depth: depth,
        );
      default:
        return _LeafNode(node: node, depth: depth);
    }
  }

  List<Map<String, dynamic>> _parseChildren(dynamic raw) {
    if (raw is List) {
      return raw.whereType<Map<String, dynamic>>().toList();
    }
    return [];
  }
}

class _LogicNode extends StatelessWidget {
  final String label;
  final Color color;
  final List<Map<String, dynamic>> children;
  final int depth;

  const _LogicNode({
    required this.label,
    required this.color,
    required this.children,
    required this.depth,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LabelChip(label: label, color: color),
        if (children.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children.map((child) {
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.subdirectory_arrow_right,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: _ConditionNode(node: child, depth: depth + 1),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

class _LeafNode extends StatelessWidget {
  final Map<String, dynamic> node;
  final int depth;

  const _LeafNode({required this.node, required this.depth});

  @override
  Widget build(BuildContext context) {
    final type = node['type'] as String? ?? '?';
    final summary = _buildSummary(node);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 12, color: Colors.black87),
          children: [
            TextSpan(
              text: type,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF37474F),
              ),
            ),
            if (summary.isNotEmpty) ...[
              const TextSpan(text: '  '),
              TextSpan(
                text: summary,
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 将叶节点的非 type 字段拼成一行摘要
  String _buildSummary(Map<String, dynamic> node) {
    final excluded = {'type', 'conditions', 'condition'};
    final parts = <String>[];
    for (final entry in node.entries) {
      if (excluded.contains(entry.key)) continue;
      final v = entry.value;
      String valueStr;
      if (v is List) {
        valueStr = v.join(', ');
      } else if (v is Map) {
        valueStr = '{...}';
      } else {
        valueStr = v.toString();
      }
      parts.add('${entry.key}: $valueStr');
    }
    return parts.join('  |  ');
  }
}

class _LabelChip extends StatelessWidget {
  final String label;
  final Color color;

  const _LabelChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
