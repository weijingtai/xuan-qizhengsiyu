import 'dart:convert';

import 'package:common/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_annotation.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_condition_set.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_rule.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju_model.dart';
import 'package:qizhengsiyu/presentation/viewmodels/ge_ju_detail_viewmodel.dart';
import 'package:qizhengsiyu/presentation/widgets/ge_ju/condition_tree_view.dart';

/// 格局详情页面
class GeJuDetailPage extends StatefulWidget {
  final String ruleId;

  const GeJuDetailPage({
    super.key,
    required this.ruleId,
  });

  @override
  State<GeJuDetailPage> createState() => _GeJuDetailPageState();
}

class _GeJuDetailPageState extends State<GeJuDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GeJuDetailViewModel>().load(widget.ruleId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GeJuDetailViewModel>(
      builder: (context, viewModel, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(viewModel.rule?.name ?? '格局详情'),
            actions: [
              if (viewModel.canEdit)
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: '编辑',
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/qizhengsiyu/ge_ju/edit',
                      arguments: widget.ruleId,
                    ).then((_) => viewModel.load(widget.ruleId));
                  },
                ),
              PopupMenuButton<String>(
                onSelected: (value) => _handleMenuAction(context, viewModel, value),
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
                    value: 'saveAs',
                    child: Row(
                      children: [
                        Icon(Icons.save_as, size: 18),
                        SizedBox(width: 8),
                        Text('另存为'),
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
                  if (viewModel.canEdit)
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('删除', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
          body: _buildBody(viewModel),
        );
      },
    );
  }

  Widget _buildBody(GeJuDetailViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(viewModel.errorMessage!, style: TextStyle(color: Colors.red.shade700)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => viewModel.load(widget.ruleId),
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (viewModel.rule == null) {
      return const Center(child: Text('格局不存在'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildBasicInfoCard(context, viewModel),
        const SizedBox(height: 12),
        _buildAnnotationsCard(context, viewModel),
        const SizedBox(height: 12),
        _buildConditionSetsCard(context, viewModel),
      ],
    );
  }

  Widget _buildBasicInfoCard(BuildContext context, GeJuDetailViewModel viewModel) {
    final rule = viewModel.rule!;
    final ann = viewModel.primaryAnnotation;

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
            if (rule.aliases.isNotEmpty)
              _buildInfoRow('别名', rule.aliases.map((a) => a.name).join(', ')),
            if (rule.disambiguationNote != null)
              _buildInfoRow('消歧', rule.disambiguationNote!),
            if (ann?.className != null) _buildInfoRow('分类', ann!.className!),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                if (ann?.jiXiong != null)
                  _buildChip(_getJiXiongLabel(ann!.jiXiong!),
                      _getJiXiongColor(ann.jiXiong!)),
                if (ann?.geJuType != null)
                  _buildChip(_getGeJuTypeLabel(ann!.geJuType!), Colors.purple),
                _buildChip(_getScopeLabel(rule.scope), Colors.teal),
                if (viewModel.isBuiltIn)
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

  Widget _buildAnnotationsCard(BuildContext context, GeJuDetailViewModel viewModel) {
    final annotations = viewModel.annotations;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('注解 (${annotations.length} 条)',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            if (annotations.isEmpty)
              Text('(无注解)', style: TextStyle(color: Colors.grey.shade500))
            else
              ...annotations.map((ann) => _buildAnnotationItem(context, viewModel, ann)),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnotationItem(BuildContext context, GeJuDetailViewModel viewModel, GeJuAnnotation ann) {
    final isBuiltIn = ann.isBuiltIn;
    final schoolLabel = ann.schools?.join('/') ?? '';
    final sourceLabel = ann.source?.bookName ?? '';
    final prefix = isBuiltIn ? '[内置]' : '[用户]';
    final metaLabel = [schoolLabel, sourceLabel].where((s) => s.isNotEmpty).join(' · ');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '$prefix ${metaLabel.isNotEmpty ? metaLabel : "注解"}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isBuiltIn ? Colors.grey.shade700 : Colors.blue.shade700,
                ),
              ),
              if (!isBuiltIn) ...[
                const Spacer(),
                InkWell(
                  onTap: () => _confirmDeleteAnnotation(context, viewModel, ann),
                  child: Icon(Icons.delete_outline, size: 16, color: Colors.red.shade300),
                ),
              ],
            ],
          ),
          if (ann.description != null && ann.description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 4),
              child: Text(
                ann.description!,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
              ),
            ),
          const Divider(height: 12),
        ],
      ),
    );
  }

  Widget _buildConditionSetsCard(BuildContext context, GeJuDetailViewModel viewModel) {
    final conditionSets = viewModel.conditionSets;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('判断方案 (${conditionSets.length} 套)',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (conditionSets.isEmpty)
              Text('(无判断方案)', style: TextStyle(color: Colors.grey.shade500))
            else
              ...conditionSets.map((cs) => _buildConditionSetItem(context, viewModel, cs)),
          ],
        ),
      ),
    );
  }

  Widget _buildConditionSetItem(BuildContext context, GeJuDetailViewModel viewModel, GeJuConditionSet cs) {
    final isBuiltIn = cs.isBuiltIn;
    final prefix = isBuiltIn ? '[内置]' : '[用户]';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$prefix ${cs.label}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isBuiltIn ? Colors.grey.shade700 : Colors.blue.shade700,
                  ),
                ),
              ),
              // Fork button
              InkWell(
                onTap: () async {
                  final forked = await viewModel.forkConditionSet(cs.id);
                  if (forked != null && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('已创建方案副本: ${forked.label}')),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.orange.withOpacity(0.5)),
                  ),
                  child: Text(
                    'Fork',
                    style: TextStyle(fontSize: 10, color: Colors.orange.shade700),
                  ),
                ),
              ),
              if (!isBuiltIn) ...[
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => _confirmDeleteConditionSet(context, viewModel, cs),
                  child: Icon(Icons.delete_outline, size: 16, color: Colors.red.shade300),
                ),
              ],
            ],
          ),
          if (cs.derivedFrom != null)
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 2),
              child: Text(
                '基于: ${cs.derivedFrom}',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ),
          if (cs.conditions != null)
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 4),
              child: ConditionTreeView(condition: cs.conditions),
            )
          else
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 4),
              child: Text('(无条件)', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
            ),
          const Divider(height: 12),
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
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 14)),
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
          color: HSLColor.fromColor(color)
              .withLightness((HSLColor.fromColor(color).lightness - 0.2).clamp(0.0, 1.0))
              .toColor(),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, GeJuDetailViewModel viewModel, String action) {
    switch (action) {
      case 'duplicate':
        Navigator.pushNamed(
          context,
          '/qizhengsiyu/ge_ju/create',
          arguments: {'duplicate': widget.ruleId},
        );
        break;
      case 'saveAs':
        Navigator.pushNamed(
          context,
          '/qizhengsiyu/ge_ju/create',
          arguments: {'saveAs': widget.ruleId},
        );
        break;
      case 'copyJson':
        if (viewModel.rule != null) {
          final jsonStr = const JsonEncoder.withIndent('  ')
              .convert(viewModel.rule!.toJson());
          Clipboard.setData(ClipboardData(text: jsonStr));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('JSON 已复制到剪贴板')),
          );
        }
        break;
      case 'delete':
        _confirmDeleteRule(context, viewModel);
        break;
    }
  }

  Future<void> _confirmDeleteRule(BuildContext context, GeJuDetailViewModel viewModel) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除格局 "${viewModel.rule?.name}" 吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await viewModel.deleteRule();
      if (success && context.mounted) {
        Navigator.pop(context);
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(viewModel.errorMessage ?? '删除失败')),
        );
      }
    }
  }

  Future<void> _confirmDeleteAnnotation(BuildContext context, GeJuDetailViewModel viewModel, GeJuAnnotation ann) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除注解'),
        content: const Text('确定要删除该注解吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await viewModel.deleteAnnotation(ann.id);
    }
  }

  Future<void> _confirmDeleteConditionSet(BuildContext context, GeJuDetailViewModel viewModel, GeJuConditionSet cs) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除判断方案'),
        content: Text('确定要删除方案 "${cs.label}" 吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await viewModel.deleteConditionSet(cs.id);
    }
  }

  String _getJiXiongLabel(JiXiongEnum jiXiong) {
    switch (jiXiong) {
      case JiXiongEnum.DA_JI: return '大吉';
      case JiXiongEnum.JI: return '吉';
      case JiXiongEnum.XIAO_JI: return '小吉';
      case JiXiongEnum.PING: return '平';
      case JiXiongEnum.XIAO_XIONG: return '小凶';
      case JiXiongEnum.XIONG: return '凶';
      case JiXiongEnum.DA_XIONG: return '大凶';
      case JiXiongEnum.WEI_ZHI: return '未知';
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
      case GeJuType.pin: return '贫';
      case GeJuType.jian: return '贱';
      case GeJuType.fu: return '富';
      case GeJuType.gui: return '贵';
      case GeJuType.yao: return '夭';
      case GeJuType.shou: return '寿';
      case GeJuType.xian: return '贤';
      case GeJuType.yu: return '愚';
    }
  }

  String _getScopeLabel(GeJuScope scope) {
    switch (scope) {
      case GeJuScope.natal: return '命盘';
      case GeJuScope.xingxian: return '行限';
      case GeJuScope.both: return '通用';
    }
  }
}
