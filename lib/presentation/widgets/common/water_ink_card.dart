import 'package:flutter/material.dart';
import 'package:qizhengsiyu/theme/app_theme.dart';

/// 水墨风格卡片组件
class WaterInkCard extends StatefulWidget {
  /// 卡片标题
  final String title;
  
  /// 卡片内容
  final Widget child;
  
  /// 是否选中
  final bool isSelected;
  
  /// 点击回调
  final VoidCallback? onTap;
  
  /// 卡片图标
  final IconData? icon;

  const WaterInkCard({
    Key? key,
    required this.title,
    required this.child,
    this.isSelected = false,
    this.onTap,
    this.icon,
  }) : super(key: key);

  @override
  State<WaterInkCard> createState() => _WaterInkCardState();
}

class _WaterInkCardState extends State<WaterInkCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF5F5F5), Color(0xFFEFEFEF)],
            ),
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            border: Border.all(
              color: widget.isSelected 
                  ? AppTheme.primaryColor 
                  : _isHovering 
                      ? AppTheme.primaryColor.withOpacity(0.5) 
                      : Colors.transparent,
              width: widget.isSelected ? 3 : 1,
            ),
            boxShadow: _isHovering || widget.isSelected
                ? AppTheme.cardShadow
                : null,
          ),
          padding: const EdgeInsets.all(AppTheme.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (widget.icon != null)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      transform: _isHovering 
                          ? Matrix4.diagonal3Values(1.1, 1.1, 1) 
                          : Matrix4.identity(),
                      transformAlignment: Alignment.center,
                      child: Icon(
                        widget.icon,
                        size: 32,
                        color: widget.isSelected 
                            ? AppTheme.primaryColor 
                            : AppTheme.primaryText,
                      ),
                    ),
                  const SizedBox(width: AppTheme.spacing8),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: widget.isSelected 
                            ? AppTheme.primaryColor 
                            : AppTheme.primaryText,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacing16),
              widget.child,
            ],
          ),
        ),
      ),
    );
  }
}