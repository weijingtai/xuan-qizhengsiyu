import 'package:flutter/material.dart';
import 'package:qizhengsiyu/theme/app_theme.dart';

/// 响应式网格布局
class ResponsiveGrid extends StatelessWidget {
  /// 子组件列表
  final List<Widget> children;
  
  /// 列间距
  final double columnSpacing;
  
  /// 行间距
  final double rowSpacing;
  
  /// 最小列宽
  final double minColumnWidth;
  
  /// 最大列数
  final int maxColumns;

  const ResponsiveGrid({
    Key? key,
    required this.children,
    this.columnSpacing = AppTheme.spacing16,
    this.rowSpacing = AppTheme.spacing16,
    this.minColumnWidth = 300,
    this.maxColumns = 3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 计算当前可以显示的列数
        final double availableWidth = constraints.maxWidth;
        int columns = (availableWidth / (minColumnWidth + columnSpacing)).floor();
        columns = columns.clamp(1, maxColumns);
        
        // 计算实际列宽
        final double columnWidth = (availableWidth - (columnSpacing * (columns - 1))) / columns;
        
        // 创建网格
        return Wrap(
          spacing: columnSpacing,
          runSpacing: rowSpacing,
          children: children.map((child) {
            return SizedBox(
              width: columnWidth,
              child: child,
            );
          }).toList(),
        );
      },
    );
  }
}