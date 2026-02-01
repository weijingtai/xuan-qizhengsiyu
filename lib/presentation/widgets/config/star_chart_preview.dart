import 'package:common/enums.dart';
import 'package:flutter/material.dart';
import 'package:qizhengsiyu/theme/app_theme.dart';

import '../../../domain/entities/models/panel_config.dart';
import '../../../enums/enum_panel_system_type.dart';


/// 星盘预览组件
class StarChartPreview extends StatelessWidget {
  /// 命盘配置
  final BasePanelConfig config;

  /// 预览高度
  final double height;

  const StarChartPreview({
    Key? key,
    required this.config,
    this.height = 300,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 预览说明
        Text(
          '星盘预览（根据当前配置生成）',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AppTheme.spacing16),

        // 星盘预览区域
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            border: Border.all(
              color: const Color(0xFFEEEEEE),
              width: 1,
            ),
          ),
          child: Center(
            child: _buildPreviewContent(context),
          ),
        ),

        // 预览信息
        const SizedBox(height: AppTheme.spacing16),
        _buildPreviewInfo(context),
      ],
    );
  }

  /// 构建预览内容
  Widget _buildPreviewContent(BuildContext context) {
    // 这里应该根据配置生成实际的星盘预览
    // 目前使用占位符
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.auto_graph,
          size: 64,
          color: AppTheme.primaryColor.withOpacity(0.5),
        ),
        const SizedBox(height: AppTheme.spacing16),
        Text(
          '星盘生成中...',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: AppTheme.spacing8),
        Text(
          '完成配置后将显示完整星盘',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  /// 构建预览信息
  Widget _buildPreviewInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 配置类型
        Row(
          children: [
            const Icon(Icons.info_outline, size: 16),
            const SizedBox(width: AppTheme.spacing8),
            Text(
              // '配置类型: ${config.queryType == EnumQueryType.destiny ? '命理运势' : '占卜事情'}',
              '配置类型: <未完成>',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacing8),

        // 流派信息
        Row(
          children: [
            const Icon(Icons.school_outlined, size: 16),
            const SizedBox(width: AppTheme.spacing8),
            Text(
              // '流派: ${config.schoolType.name}',
              '流派: <未完成>',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacing8),

        // 星道制式
        Row(
          children: [
            const Icon(Icons.settings_outlined, size: 16),
            const SizedBox(width: AppTheme.spacing8),
            Text(
              '星道制式: ${config.celestialCoordinateSystem == CelestialCoordinateSystem.ecliptic ? '黄道制' : '赤道制'}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ],
    );
  }
}
