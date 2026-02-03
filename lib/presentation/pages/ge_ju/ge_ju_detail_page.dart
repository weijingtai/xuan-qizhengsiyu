import 'dart:convert';

import 'package:common/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_rule.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju_model.dart';
import 'package:qizhengsiyu/presentation/widgets/ge_ju/condition_tree_view.dart';

/// 格局详情页面
class GeJuDetailPage extends StatelessWidget {
  final GeJuRule rule;
  final bool isBuiltIn;

  const GeJuDetailPage({
    super.key,
    required this.rule,
    required this.isBuiltIn,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(rule.name),
        actions: [
          if (!isBuiltIn)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: '编辑',
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/qizhengsiyu/ge_ju/edit',
                  arguments: rule.id,
                ).then((_) => Navigator.pop(context));
              },
            ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'duplicate',
                child: Row(
                  children: [
                    Icon(Icons.copy, size: 18),
                    SizedBox(width: 8),
                    Text('复制'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'copyJson',
                child: Row(
                  children: [
                    Icon(Icons.data_object, size: 18),
                    SizedBox(width: 8),
                    Text('复制JSON'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildBasicInfoCard(context),
          const SizedBox(height: 12),
          _buildDescriptionCard(context),
          const SizedBox(height: 12),
          _buildConditionCard(context),
          const SizedBox(height: 12),
          _buildJsonCard(context),
        ],
      ),
    );
  }

  Widget _buildBasicInfoCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('基本信息',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildInfoRow('名称', rule.name),
            _buildInfoRow('分类', rule.className),
            if (rule.books.isNotEmpty) _buildInfoRow('书籍', rule.books),
            if (rule.source.isNotEmpty) _buildInfoRow('出处', rule.source),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildChip(_getJiXiongLabel(rule.jiXiong),
                    _getJiXiongColor(rule.jiXiong)),
                _buildChip(_getGeJuTypeLabel(rule.geJuType), Colors.purple),
                _buildChip(_getScopeLabel(rule.scope), Colors.teal),
                if (isBuiltIn)
                  _buildChip('内置', Colors.grey)
                else
                  _buildChip('自定义', Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('描述',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              rule.description.isEmpty ? '(无描述)' : rule.description,
              style: TextStyle(
                fontSize: 14,
                color: rule.description.isEmpty
                    ? Colors.grey.shade500
                    : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConditionCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('判断条件',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ConditionTreeView(condition: rule.conditions),
          ],
        ),
      ),
    );
  }

  Widget _buildJsonCard(BuildContext context) {
    final jsonStr =
        const JsonEncoder.withIndent('  ').convert(rule.toJson());
    return Card(
      child: ExpansionTile(
        title: const Text('JSON 源码',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('复制'),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: jsonStr));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('JSON 已复制到剪贴板')),
                        );
                      },
                    ),
                  ],
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    jsonStr,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color.shade700,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'duplicate':
        Navigator.pushNamed(
          context,
          '/qizhengsiyu/ge_ju/create',
          arguments: {'duplicate': rule.id},
        );
        break;
      case 'copyJson':
        final jsonStr =
            const JsonEncoder.withIndent('  ').convert(rule.toJson());
        Clipboard.setData(ClipboardData(text: jsonStr));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('JSON 已复制到剪贴板')),
        );
        break;
    }
  }

  String _getJiXiongLabel(JiXiongEnum jiXiong) {
    switch (jiXiong) {
      case JiXiongEnum.DA_JI:
        return '大吉';
      case JiXiongEnum.JI:
        return '吉';
      case JiXiongEnum.XIAO_JI:
        return '小吉';
      case JiXiongEnum.PING:
        return '平';
      case JiXiongEnum.XIAO_XIONG:
        return '小凶';
      case JiXiongEnum.XIONG:
        return '凶';
      case JiXiongEnum.DA_XIONG:
        return '大凶';
      case JiXiongEnum.WEI_ZHI:
        return '未知';
    }
  }

  Color _getJiXiongColor(JiXiongEnum jiXiong) {
    switch (jiXiong) {
      case JiXiongEnum.DA_JI:
      case JiXiongEnum.JI:
      case JiXiongEnum.XIAO_JI:
        return Colors.green;
      case JiXiongEnum.PING:
      case JiXiongEnum.WEI_ZHI:
        return Colors.grey;
      case JiXiongEnum.XIAO_XIONG:
      case JiXiongEnum.XIONG:
      case JiXiongEnum.DA_XIONG:
        return Colors.red;
    }
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

  String _getScopeLabel(GeJuScope scope) {
    switch (scope) {
      case GeJuScope.natal:
        return '命盘';
      case GeJuScope.xingxian:
        return '行限';
      case GeJuScope.both:
        return '通用';
    }
  }
}

extension on Color {
  Color get shade700 {
    // Simple darkening for chip text
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness - 0.2).clamp(0.0, 1.0)).toColor();
  }
}
