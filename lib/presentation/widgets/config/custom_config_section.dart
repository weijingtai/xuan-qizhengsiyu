import 'package:flutter/material.dart';
import 'package:qizhengsiyu/enums/enum_panel_system_type.dart';
import 'package:qizhengsiyu/theme/app_theme.dart';
import 'package:qizhengsiyu/enums/enum_school.dart';

import '../../../domain/entities/models/panel_config.dart';

/// 自定义配置部分
class CustomConfigSection extends StatefulWidget {
  /// 配置变更回调
  final Function(PanelConfig) onConfigChanged;

  /// 初始配置
  final PanelConfig? initialConfig;

  const CustomConfigSection({
    Key? key,
    required this.onConfigChanged,
    this.initialConfig,
  }) : super(key: key);

  @override
  State<CustomConfigSection> createState() => _CustomConfigSectionState();
}

class _CustomConfigSectionState extends State<CustomConfigSection> {
  // 星道制式
  late CelestialCoordinateSystem _coordinateSystem;

  // 星宿制式
  late PanelSystemType _panelSystem;

  // 流派典籍
  late List<String> _classicBook;

  // 是否显示神煞
  // late bool _showGods;

  // 是否显示宫位
  // late bool _showPalaces;

  // 是否使用传统计算
  late bool _useTraditionalCalculation;

  @override
  void initState() {
    super.initState();

    // 初始化配置
    _coordinateSystem = widget.initialConfig?.celestialCoordinateSystem ??
        CelestialCoordinateSystem.ecliptic;
    _panelSystem =
        widget.initialConfig?.panelSystemType ?? PanelSystemType.tropical;
    _classicBook = ["七政四余星道要诀"]; // 暂时硬编码，因为PanelConfig暂时不支持
    // _showGods = widget.initialConfig?.sh ?? true;
    // _showPalaces = widget.initialConfig?.showPalaces ?? true;
    // _useTraditionalCalculation =
    // widget.initialConfig?.useTraditionalCalculation ?? false;
    _useTraditionalCalculation = false;
  }

  void _updateConfig() {
    final base = widget.initialConfig ?? PanelConfig.defaultPanelConfig();

    final config = PanelConfig(
      celestialCoordinateSystem: _coordinateSystem,
      panelSystemType: _panelSystem,
      // Fields we don't control, take from base
      houseDivisionSystem: base.houseDivisionSystem,
      constellationSystemType: base.constellationSystemType,
      settleLifeType: base.settleLifeType,
      settleBodyType: base.settleBodyType,
      islifeGongBySunRealTimeLocation: base.islifeGongBySunRealTimeLocation,
      lifeCountingToGong: base.lifeCountingToGong,
      bodyCountingToGong: base.bodyCountingToGong,
    );
    widget.onConfigChanged(config);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 星道制式选择
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          padding: const EdgeInsets.all(AppTheme.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '星道制式',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: AppTheme.spacing12),
              Row(
                children: [
                  Expanded(
                    child: _buildRadioTile(
                      title: '黄道制',
                      subtitle: '以黄道十二宫为基础',
                      value: CelestialCoordinateSystem.ecliptic,
                      groupValue: _coordinateSystem,
                      onChanged: (value) {
                        setState(() {
                          _coordinateSystem = value!;
                        });
                        _updateConfig();
                      },
                    ),
                  ),
                  Expanded(
                    child: _buildRadioTile(
                      title: '赤道制',
                      subtitle: '以赤道十二宫为基础',
                      value: CelestialCoordinateSystem.equatorial,
                      groupValue: _coordinateSystem,
                      onChanged: (value) {
                        setState(() {
                          _coordinateSystem = value!;
                        });
                        _updateConfig();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacing16),

        // 星宿制式选择
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          padding: const EdgeInsets.all(AppTheme.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '星宿制式',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: AppTheme.spacing12),
              Row(
                children: [
                  Expanded(
                    child: _buildRadioTile(
                      title: '回归制',
                      subtitle: '春分点为起点',
                      value: PanelSystemType.tropical,
                      groupValue: _panelSystem,
                      onChanged: (value) {
                        setState(() {
                          _panelSystem = value!;
                        });
                        _updateConfig();
                      },
                    ),
                  ),
                  Expanded(
                    child: _buildRadioTile(
                      title: '恒星制',
                      subtitle: '以实际星座为基础',
                      value: PanelSystemType.sidereal,
                      groupValue: _panelSystem,
                      onChanged: (value) {
                        setState(() {
                          _panelSystem = value!;
                        });
                        _updateConfig();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacing16),

        // 流派典籍选择
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          padding: const EdgeInsets.all(AppTheme.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '流派典籍',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: AppTheme.spacing12),
              DropdownButtonFormField<String>(
                value: _classicBook.first,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing16,
                    vertical: AppTheme.spacing12,
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: '七政四余星道要诀',
                    child: Text('七政四余星道要诀'),
                  ),
                  DropdownMenuItem(
                    value: '果老星宗',
                    child: Text('果老星宗'),
                  ),
                  DropdownMenuItem(
                    value: '天官星经',
                    child: Text('天官星经'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _classicBook = [value!];
                  });
                  _updateConfig();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacing16),

        // 高级选项
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          padding: const EdgeInsets.all(AppTheme.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '高级选项',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: AppTheme.spacing12),

              // // 显示神煞选项
              // SwitchListTile(
              //   title: const Text('显示神煞'),
              //   subtitle: const Text('在命盘中显示各种神煞'),
              //   value: _showGods,
              //   onChanged: (value) {
              //     setState(() {
              //       _showGods = value;
              //     });
              //     _updateConfig();
              //   },
              //   contentPadding: EdgeInsets.zero,
              //   activeColor: AppTheme.primaryColor,
              // ),

              // // 显示宫位选项
              // SwitchListTile(
              //   title: const Text('显示宫位'),
              //   subtitle: const Text('在命盘中显示十二宫位'),
              //   value: _showPalaces,
              //   onChanged: (value) {
              //     setState(() {
              //       _showPalaces = value;
              //     });
              //     _updateConfig();
              //   },
              //   contentPadding: EdgeInsets.zero,
              //   activeColor: AppTheme.primaryColor,
              // ),

              // 使用传统计算选项
              SwitchListTile(
                title: const Text('使用传统计算'),
                subtitle: const Text('使用古法计算星体位置'),
                value: _useTraditionalCalculation,
                onChanged: (value) {
                  setState(() {
                    _useTraditionalCalculation = value;
                  });
                  _updateConfig();
                },
                contentPadding: EdgeInsets.zero,
                activeColor: AppTheme.primaryColor,
              ),

              if (_useTraditionalCalculation)
                Container(
                  margin: const EdgeInsets.only(left: AppTheme.spacing16),
                  padding: const EdgeInsets.all(AppTheme.spacing8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 16,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: AppTheme.spacing8),
                      Expanded(
                        child: Text(
                          '传统计算方法可能与现代天文学有所差异，但更符合古代命理学理论',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.primaryColor,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        // 配置说明
        Padding(
          padding: const EdgeInsets.only(top: AppTheme.spacing16),
          child: Text(
            '注：不同流派对星道制式和星宿制式有不同偏好，请根据您的需求选择',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.secondaryText,
                  fontStyle: FontStyle.italic,
                ),
          ),
        ),
      ],
    );
  }

  /// 构建单选按钮项
  Widget _buildRadioTile<T>({
    required String title,
    required String subtitle,
    required T value,
    required T groupValue,
    required ValueChanged<T?> onChanged,
  }) {
    return Card(
      elevation: 0,
      color: value == groupValue
          ? AppTheme.primaryColor.withOpacity(0.1)
          : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: value == groupValue
              ? AppTheme.primaryColor
              : Colors.grey.shade300,
          width: value == groupValue ? 2 : 1,
        ),
      ),
      child: RadioListTile<T>(
        title: Text(
          title,
          style: TextStyle(
            fontWeight:
                value == groupValue ? FontWeight.bold : FontWeight.normal,
            color: value == groupValue
                ? AppTheme.primaryColor
                : AppTheme.primaryText,
          ),
        ),
        subtitle: Text(subtitle),
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        activeColor: AppTheme.primaryColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing8,
          vertical: AppTheme.spacing4,
        ),
      ),
    );
  }
}
