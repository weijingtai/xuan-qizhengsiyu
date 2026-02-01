import 'package:flutter/material.dart';
import 'package:qizhengsiyu/theme/app_theme.dart';

import '../../../enums/enum_school.dart';

/// 流派选择器组件
class SchoolSelector extends StatelessWidget {
  /// 当前选中的流派
  final EnumSchoolType selectedSchool;

  /// 流派选择回调
  final Function(EnumSchoolType) onSchoolSelected;

  const SchoolSelector({
    Key? key,
    required this.selectedSchool,
    required this.onSchoolSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 根据可用宽度决定每行显示的卡片数量
        final double availableWidth = constraints.maxWidth;
        int cardsPerRow = (availableWidth / 320).floor();
        cardsPerRow = cardsPerRow.clamp(1, 3);

        return Wrap(
          spacing: AppTheme.spacing16,
          runSpacing: AppTheme.spacing16,
          children: EnumSchoolType.values.map((school) {
            return _buildSchoolCard(context, school);
          }).toList(),
        );
      },
    );
  }

  /// 构建流派卡片
  Widget _buildSchoolCard(BuildContext context, EnumSchoolType school) {
    final bool isSelected = selectedSchool == school;

    return InkWell(
      onTap: () => onSchoolSelected(school),
      borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 300,
        padding: const EdgeInsets.all(AppTheme.spacing16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFF5F5F5),
              isSelected
                  ? AppTheme.schoolColor.withOpacity(0.2)
                  : const Color(0xFFEFEFEF),
            ],
          ),
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          border: Border.all(
            color: isSelected ? AppTheme.schoolColor : Colors.transparent,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.schoolColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : AppTheme.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 流派图标
            Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                transform: isSelected
                    ? Matrix4.diagonal3Values(1.1, 1.1, 1)
                    : Matrix4.identity(),
                transformAlignment: Alignment.center,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.schoolColor : Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    _getSchoolIcon(school),
                    size: 32,
                    color: isSelected ? Colors.white : AppTheme.primaryText,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacing16),

            // 流派名称
            Center(
              child: Text(
                school.name,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: isSelected
                          ? AppTheme.primaryColor
                          : AppTheme.primaryText,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
              ),
            ),
            const SizedBox(height: AppTheme.spacing8),

            // 流派描述
            Text(
              _getSchoolDescription(school),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacing16),

            // 选择按钮
            Center(
              child: ElevatedButton(
                onPressed: () => onSchoolSelected(school),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isSelected ? AppTheme.schoolColor : AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing24,
                    vertical: AppTheme.spacing8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(isSelected ? '已选择' : '选择'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 获取流派图标
  IconData _getSchoolIcon(EnumSchoolType school) {
    switch (school) {
      case EnumSchoolType.QinTang:
        return Icons.music_note;
      case EnumSchoolType.GuoLao:
        return Icons.elderly;
      case EnumSchoolType.TianGuan:
        return Icons.star;
      case EnumSchoolType.Customerized:
        return Icons.settings;
    }
  }

  /// 获取流派描述
  String _getSchoolDescription(EnumSchoolType school) {
    switch (school) {
      case EnumSchoolType.QinTang:
        return '琴堂派注重音律与命理的结合，以赤道制为主，强调身宫的重要性';
      case EnumSchoolType.GuoLao:
        return '果老派是传统命理学的代表，以黄道制为主，注重星曜的五行属性';
      case EnumSchoolType.TianGuan:
        return '天官派重视天体运行规律，以黄道制为主，注重星曜的相位关系';
      case EnumSchoolType.Customerized:
        return '自定义流派，可根据个人偏好自由设置各项参数';
    }
  }
}
