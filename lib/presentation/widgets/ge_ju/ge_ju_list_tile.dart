import 'package:common/enums.dart';
import 'package:flutter/material.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_annotation.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_rule.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju_model.dart';

/// 格局列表项组件
class GeJuListTile extends StatelessWidget {
  final GeJuRule rule;
  final GeJuAnnotation? annotation;
  final bool isBuiltIn;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onDuplicate;

  const GeJuListTile({
    super.key,
    required this.rule,
    this.annotation,
    required this.isBuiltIn,
    this.onTap,
    this.onDelete,
    this.onDuplicate,
  });

  @override
  Widget build(BuildContext context) {
    final jiXiong = annotation?.jiXiong ?? JiXiongEnum.PING;
    final geJuType = annotation?.geJuType ?? GeJuType.pin;
    final className = annotation?.className ?? '未分类';
    final description = annotation?.description ?? '';
    final source = annotation?.source?.bookName ?? '';

    return ListTile(
      onTap: onTap,
      leading: Icon(
        isBuiltIn ? Icons.lock : Icons.edit_note,
        color: isBuiltIn ? Colors.grey : Colors.blue,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              rule.name,
              style: const TextStyle(fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          _buildJiXiongChip(jiXiong),
          const SizedBox(width: 4),
          _buildTypeChip(geJuType),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Row(
            children: [
              _buildCategoryChip(className),
              if (source.isNotEmpty) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    source,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description.isEmpty ? '(无描述)' : description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      trailing: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert),
        onSelected: (value) {
          switch (value) {
            case 'duplicate':
              onDuplicate?.call();
              break;
            case 'delete':
              onDelete?.call();
              break;
          }
        },
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
          if (!isBuiltIn)
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 18, color: Colors.red),
                  const SizedBox(width: 8),
                  const Text('删除', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
        ],
      ),
      isThreeLine: true,
    );
  }

  Widget _buildJiXiongChip(JiXiongEnum jiXiong) {
    Color color;
    String label;
    switch (jiXiong) {
      case JiXiongEnum.DA_JI:
        color = Colors.green;
        label = '大吉';
        break;
      case JiXiongEnum.JI:
        color = Colors.green;
        label = '吉';
        break;
      case JiXiongEnum.XIAO_JI:
        color = Colors.green;
        label = '小吉';
        break;
      case JiXiongEnum.XIONG:
        color = Colors.red;
        label = '凶';
        break;
      case JiXiongEnum.DA_XIONG:
        color = Colors.red;
        label = '大凶';
        break;
      case JiXiongEnum.XIAO_XIONG:
        color = Colors.red;
        label = '小凶';
        break;
      case JiXiongEnum.PING:
        color = Colors.grey;
        label = '平';
        break;
      case JiXiongEnum.WEI_ZHI:
        color = Colors.grey;
        label = '未知';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildTypeChip(GeJuType geJuType) {
    String label = _getGeJuTypeLabel(geJuType);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.purple.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: Colors.purple.shade700,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String className) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        className,
        style: TextStyle(fontSize: 10, color: Colors.blue.shade700),
      ),
    );
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
      case GeJuType.other:
        return '其他';
    }
  }
}
