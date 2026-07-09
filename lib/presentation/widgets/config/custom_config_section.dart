import 'package:flutter/material.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/enums/enum_panel_system_type.dart';
import 'package:qizhengsiyu/theme/app_theme.dart';
import 'package:qizhengsiyu/enums/enum_rahu_ketu_convention.dart';
import 'package:qizhengsiyu/enums/enum_settle_life_body.dart';
import 'package:qizhengsiyu/enums/enum_zi_qi_algorithm.dart';
import 'package:qizhengsiyu/domain/engines/siyu/group/si_yu_group_algorithm.dart';
import 'package:qizhengsiyu/domain/engines/siyu/spec/si_yu_group_spec.dart';
import 'package:qizhengsiyu/domain/engines/siyu/profile/built_in_profiles.dart';
import 'package:qizhengsiyu/presentation/widgets/config/si_yu_profile_selector.dart';
import 'package:qizhengsiyu/presentation/widgets/config/si_yu_group_editor.dart';

import 'package:qizhengsiyu/enums/enum_zhou_tian_model.dart';
import 'package:qizhengsiyu/enums/enum_zero_point_ref.dart';
import 'package:qizhengsiyu/enums/enum_constellation_offset_tier.dart';
import 'package:qizhengsiyu/domain/entities/models/projection_config.dart';
import 'package:qizhengsiyu/domain/managers/panel_system_resolver.dart';

import '../../../domain/entities/models/panel_config.dart';

/// 自定义配置部分
class CustomConfigSection extends StatefulWidget {
  /// 配置变更回调
  final Function(PanelConfig) onConfigChanged;

  /// 初始配置
  final PanelConfig? initialConfig;

  const CustomConfigSection({
    super.key,
    required this.onConfigChanged,
    this.initialConfig,
  });

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

  // 罗计交点约定
  late EnumRahuKetuConvention _rahuKetuConvention;

  // 紫气算法与配置
  late EnumZiQiAlgorithm _ziQiAlgorithm;
  late EnumZiQiPeriod _ziQiPeriod;
  late EnumZiQiEpochSet _ziQiEpochSet;
  late EnumZiQiChiDaoStandard _ziQiChiDaoStandard;

  late String _siYuProfileId;
  late Map<String, SiYuGroupSpec> _siYuOverrides;
  CelestialCoordinateSystem? _siYuCoordinateOverride;

  late EnumZhouTianModel? _zhouTianModel;
  late MappingStrategy _mappingStrategy;
  late HuangChiDaoDiffType? _huangChiDaoDiffType;
  late double _epsilonDeg;
  late double _springEquinoxAnchor;

  late EnumZeroPointRef? _zeroPointRef;
  late ConstellationOffsetTier? _offsetTier;
  late double _constellationOffsetDeg;
  late ConstellationSystemType _constellationSystemType;
  late HouseDivisionSystem _houseDivisionSystem;
  late Map<Enum28Constellations, double>? _starInnDegreeOverrides;

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
        CelestialCoordinateSystem.Ecliptic;
    _panelSystem =
        widget.initialConfig?.panelSystemType ?? PanelSystemType.Tropical;
    _rahuKetuConvention = widget.initialConfig?.rahuKetuConvention ??
        EnumRahuKetuConvention.luoJiangJiSheng;
    _ziQiAlgorithm = widget.initialConfig?.ziQiAlgorithm ??
        EnumZiQiAlgorithm.guoLaoQinTang;
    _ziQiPeriod = widget.initialConfig?.ziQiPeriod ??
        EnumZiQiPeriod.years28;
    _ziQiEpochSet = widget.initialConfig?.ziQiEpochSet ??
        EnumZiQiEpochSet.shouShiNvXiu;
    _ziQiChiDaoStandard = widget.initialConfig?.ziQiChiDaoStandard ??
        EnumZiQiChiDaoStandard.moira;
    _siYuProfileId = widget.initialConfig?.siYuProfileId ?? 'guolao_ecliptic';
    _siYuOverrides = widget.initialConfig?.siYuOverrides != null
        ? Map.from(widget.initialConfig!.siYuOverrides)
        : {};
    _siYuCoordinateOverride = widget.initialConfig?.siYuCoordinateOverride;
    _zhouTianModel = widget.initialConfig?.zhouTianModelOverride;
    final projOverride = widget.initialConfig?.projectionOverride;
    _mappingStrategy = projOverride?.strategy ?? MappingStrategy.linear;
    _huangChiDaoDiffType = projOverride?.huangChiDaoDiffType;
    _epsilonDeg = projOverride?.epsilonDeg ?? 23.90;
    _springEquinoxAnchor = projOverride?.springEquinoxAnchor ?? 0.0;
    _zeroPointRef = widget.initialConfig?.zeroPointRef;
    _offsetTier = widget.initialConfig?.offsetTier;
    _constellationOffsetDeg =
        widget.initialConfig?.constellationOffsetDeg ?? 0.0;
    _constellationSystemType =
        widget.initialConfig?.constellationSystemType ??
            ConstellationSystemType.Classical;
    _houseDivisionSystem =
        widget.initialConfig?.houseDivisionSystem ?? HouseDivisionSystem.equal;
    _classicBook = ["七政四余星道要诀"]; // 暂时硬编码，因为PanelConfig暂时不支持
    _starInnDegreeOverrides = widget.initialConfig?.starInnDegreeOverrides != null
        ? Map.from(widget.initialConfig!.starInnDegreeOverrides!)
        : null;
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
      houseDivisionSystem: _houseDivisionSystem,
      constellationSystemType: _constellationSystemType,
      settleLifeType: base.settleLifeType,
      settleBodyType: base.settleBodyType,
      islifeGongBySunRealTimeLocation: base.islifeGongBySunRealTimeLocation,
      lifeCountingToGong: base.lifeCountingToGong,
      bodyCountingToGong: base.bodyCountingToGong,
      rahuKetuConvention: _rahuKetuConvention,
      ziQiAlgorithm: _ziQiAlgorithm,
      ziQiPeriod: _ziQiPeriod,
      ziQiEpochSet: _ziQiEpochSet,
      ziQiChiDaoStandard: _ziQiChiDaoStandard,
      siYuProfileId: _siYuProfileId,
      siYuOverrides: _siYuOverrides,
      siYuCoordinateOverride: _siYuCoordinateOverride,
      zhouTianModelOverride: _zhouTianModel,
      projectionOverride: _mappingStrategy == MappingStrategy.linear
          ? null
          : ProjectionConfig(
              strategy: MappingStrategy.tuiBianHuangDao,
              huangChiDaoDiffType: _huangChiDaoDiffType,
              epsilonDeg: _epsilonDeg,
              springEquinoxAnchor: _springEquinoxAnchor,
            ),
      zeroPointRef: _zeroPointRef,
      offsetTier: _offsetTier,
      constellationOffsetDeg: _constellationOffsetDeg,
      starInnDegreeOverrides: _starInnDegreeOverrides,
    );
    widget.onConfigChanged(config);
  }

  @override
  Widget build(BuildContext context) {
    final check = PanelSystemResolver().validate(_currentConfig());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!check.isCoherent)
          Container(
            margin: const EdgeInsets.only(bottom: AppTheme.spacing16),
            padding: const EdgeInsets.all(AppTheme.spacing12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...check.warnings.map((w) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(w,
                          style: TextStyle(
                              color: Colors.amber.shade900, fontSize: 13)),
                    )),
                if (check.suggestedFix != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        final fix = check.suggestedFix!;
                        setState(() {
                          _zhouTianModel = fix.zhouTianModelOverride;
                          _offsetTier = fix.offsetTier;
                          _constellationOffsetDeg =
                              fix.constellationOffsetDeg ?? 0.0;
                          if (fix.projectionOverride == null) {
                            _mappingStrategy = MappingStrategy.linear;
                          }
                        });
                        _updateConfig();
                      },
                      icon: Icon(Icons.auto_fix_high,
                          size: 16, color: Colors.amber.shade800),
                      label: Text('一键归正',
                          style: TextStyle(color: Colors.amber.shade800)),
                    ),
                  ),
              ],
            ),
          ),
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
              Column(
                children: _buildCoordinateSystemOptions(
                    context, CelestialCoordinateSystem.values),
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
                      value: PanelSystemType.Tropical,
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
                      value: PanelSystemType.Sidereal,
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

        // 罗计定义选择
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
                '罗计升降交点定义',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: AppTheme.spacing12),
              Row(
                children: [
                  Expanded(
                    child: _buildRadioTile(
                      title: '罗降计升（古法）',
                      subtitle: '罗睺为降交点，计都为升交点。果老/一行等古法所用',
                      value: EnumRahuKetuConvention.luoJiangJiSheng,
                      groupValue: _rahuKetuConvention,
                      onChanged: (value) {
                        setState(() {
                          _rahuKetuConvention = value!;
                        });
                        _updateConfig();
                      },
                    ),
                  ),
                  Expanded(
                    child: _buildRadioTile(
                      title: '罗升计降（新法）',
                      subtitle: '罗睺为升交点，计都为降交点。清后期/印占使用',
                      value: EnumRahuKetuConvention.luoShengJiJiang,
                      groupValue: _rahuKetuConvention,
                      onChanged: (value) {
                        setState(() {
                          _rahuKetuConvention = value!;
                        });
                        _updateConfig();
                      },
                    ),
                  ),
                ],
              ),
              if (_rahuKetuConvention == EnumRahuKetuConvention.luoShengJiJiang)
                Container(
                  margin: const EdgeInsets.only(top: AppTheme.spacing12),
                  padding: const EdgeInsets.all(AppTheme.spacing8),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 16,
                        color: Colors.amber.shade800,
                      ),
                      const SizedBox(width: AppTheme.spacing8),
                      Expanded(
                        child: Text(
                          '与古法正统罗计相反、吉凶互换，仅供比对参考！',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.amber.shade900,
                                    fontSize: 12,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacing16),

        // 紫气算法与配置选择
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
                '紫气算法与历元参数',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: AppTheme.spacing12),

              // 紫气算法
              Text(
                '紫气算法流派',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.secondaryText,
                    ),
              ),
              const SizedBox(height: AppTheme.spacing8),
              DropdownButtonFormField<EnumZiQiAlgorithm>(
                value: _ziQiAlgorithm,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing16,
                    vertical: AppTheme.spacing12,
                  ),
                ),
                items: EnumZiQiAlgorithm.values
                    .map((algo) => DropdownMenuItem(
                          value: algo,
                          child: Text(algo.name),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _ziQiAlgorithm = value!;
                  });
                  _updateConfig();
                },
              ),
              const SizedBox(height: AppTheme.spacing16),

              // 紫气周期
              Text(
                '紫气行度周期',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.secondaryText,
                    ),
              ),
              const SizedBox(height: AppTheme.spacing8),
              Row(
                children: [
                  Expanded(
                    child: _buildRadioTile(
                      title: '28年十闰',
                      subtitle: '周期 10227.1792 日',
                      value: EnumZiQiPeriod.years28,
                      groupValue: _ziQiPeriod,
                      onChanged: (value) {
                        setState(() {
                          _ziQiPeriod = value!;
                        });
                        _updateConfig();
                      },
                    ),
                  ),
                  Expanded(
                    child: _buildRadioTile(
                      title: '29年一闰',
                      subtitle: '周期 10592.0 日',
                      value: EnumZiQiPeriod.years29,
                      groupValue: _ziQiPeriod,
                      onChanged: (value) {
                        setState(() {
                          _ziQiPeriod = value!;
                        });
                        _updateConfig();
                      },
                    ),
                  ),
                ],
              ),

              // 果老历元常数集
              if (_ziQiAlgorithm == EnumZiQiAlgorithm.guoLaoQinTang) ...[
                const SizedBox(height: AppTheme.spacing16),
                Text(
                  '果老历元常数集',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.secondaryText,
                      ),
                ),
                const SizedBox(height: AppTheme.spacing8),
                DropdownButtonFormField<EnumZiQiEpochSet>(
                  value: _ziQiEpochSet,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing16,
                      vertical: AppTheme.spacing12,
                    ),
                  ),
                  items: EnumZiQiEpochSet.values
                      .map((set) => DropdownMenuItem(
                            value: set,
                            child: Text(set.name),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _ziQiEpochSet = value!;
                    });
                    _updateConfig();
                  },
                ),
              ],

              // 天赤道·女宿紫气标准
              if (_coordinateSystem == CelestialCoordinateSystem.Equatorial &&
                  _ziQiEpochSet == EnumZiQiEpochSet.shouShiNvXiu &&
                  _ziQiAlgorithm == EnumZiQiAlgorithm.guoLaoQinTang) ...[
                const SizedBox(height: AppTheme.spacing16),
                Text(
                  '天赤道·女宿紫气标准',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.secondaryText,
                      ),
                ),
                const SizedBox(height: AppTheme.spacing8),
                DropdownButtonFormField<EnumZiQiChiDaoStandard>(
                  value: _ziQiChiDaoStandard,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing16,
                      vertical: AppTheme.spacing12,
                    ),
                    helperText: _ziQiChiDaoStandard == EnumZiQiChiDaoStandard.moira
                        ? 'Moira 实测：与主流软件排盘对齐，锚定2026翼宿点。'
                        : '授时正典：严格符合《授时历》古籍典籍记载。',
                  ),
                  items: EnumZiQiChiDaoStandard.values
                      .map((std) => DropdownMenuItem(
                            value: std,
                            child: Text(std.name),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _ziQiChiDaoStandard = value!;
                    });
                    _updateConfig();
                  },
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacing16),

        // 周天制与黄赤道换算
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
                '周天制与黄赤道换算',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: AppTheme.spacing12),
              Text(
                '周天制',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.secondaryText,
                    ),
              ),
              const SizedBox(height: AppTheme.spacing8),
              Row(
                children: [
                  Expanded(
                    child: _buildRadioTile<EnumZhouTianModel?>(
                      title: '360 度制',
                      subtitle: '现代 360°，默认',
                      value: null,
                      groupValue: _zhouTianModel,
                      onChanged: (value) {
                        setState(() {
                          _zhouTianModel = value;
                        });
                        _updateConfig();
                      },
                    ),
                  ),
                  Expanded(
                    child: _buildRadioTile<EnumZhouTianModel?>(
                      title: '古度 365.25',
                      subtitle: '古周天 365.2575',
                      value: EnumZhouTianModel.degree36525,
                      groupValue: _zhouTianModel,
                      onChanged: (value) {
                        setState(() {
                          _zhouTianModel = value;
                        });
                        _updateConfig();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacing16),
              Text(
                '黄赤道换算',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.secondaryText,
                    ),
              ),
              const SizedBox(height: AppTheme.spacing8),
              DropdownButtonFormField<MappingStrategy>(
                value: _mappingStrategy,
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
                    value: MappingStrategy.linear,
                    child: Text('线性（默认）'),
                  ),
                  DropdownMenuItem(
                    value: MappingStrategy.tuiBianHuangDao,
                    child: Text('推变黄道'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _mappingStrategy = value!;
                  });
                  _updateConfig();
                },
              ),
              if (_mappingStrategy == MappingStrategy.tuiBianHuangDao) ...[
                const SizedBox(height: AppTheme.spacing16),
                Text(
                  '推变黄道算法',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.secondaryText,
                      ),
                ),
                const SizedBox(height: AppTheme.spacing8),
                DropdownButtonFormField<HuangChiDaoDiffType>(
                  value: _huangChiDaoDiffType ?? HuangChiDaoDiffType.shoushi,
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
                      value: HuangChiDaoDiffType.daren,
                      child: Text('大衍进退表'),
                    ),
                    DropdownMenuItem(
                      value: HuangChiDaoDiffType.jiyuan,
                      child: Text('纪元(姚舜辅)'),
                    ),
                    DropdownMenuItem(
                      value: HuangChiDaoDiffType.shoushi,
                      child: Text('授时球面'),
                    ),
                    DropdownMenuItem(
                      value: HuangChiDaoDiffType.hushi,
                      child: Text('弧矢割圆术'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _huangChiDaoDiffType = value;
                    });
                    _updateConfig();
                  },
                ),
                const SizedBox(height: AppTheme.spacing16),
                Text(
                  '黄赤交角 ε',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.secondaryText,
                      ),
                ),
                const SizedBox(height: AppTheme.spacing8),
                TextFormField(
                  initialValue: _epsilonDeg.toString(),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing16,
                      vertical: AppTheme.spacing12,
                    ),
                    helperText: '授时历大距',
                  ),
                  onChanged: (value) {
                    final parsed = double.tryParse(value);
                    if (parsed != null) {
                      setState(() {
                        _epsilonDeg = parsed;
                      });
                      _updateConfig();
                    }
                  },
                ),
                const SizedBox(height: AppTheme.spacing16),
                Text(
                  '春分锚点',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.secondaryText,
                      ),
                ),
                const SizedBox(height: AppTheme.spacing8),
                TextFormField(
                  initialValue: _springEquinoxAnchor.toString(),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing16,
                      vertical: AppTheme.spacing12,
                    ),
                    helperText: '赤道度·古周天',
                  ),
                  onChanged: (value) {
                    final parsed = double.tryParse(value);
                    if (parsed != null) {
                      setState(() {
                        _springEquinoxAnchor = parsed;
                      });
                      _updateConfig();
                    }
                  },
                ),
              ],
              const SizedBox(height: AppTheme.spacing16),
              Text(
                '宫位划分',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.secondaryText,
                    ),
              ),
              const SizedBox(height: AppTheme.spacing8),
              DropdownButtonFormField<HouseDivisionSystem>(
                value: _houseDivisionSystem,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing16,
                    vertical: AppTheme.spacing12,
                  ),
                  helperText: _houseDivisionSystem.description,
                ),
                items: HouseDivisionSystem.values
                    .map((system) => DropdownMenuItem(
                          value: system,
                          child: Text(system.name),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _houseDivisionSystem = value!;
                  });
                  _updateConfig();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacing16),

        // 起点与偏移
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
                '起点与偏移',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: AppTheme.spacing12),
              Text(
                '起点',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.secondaryText,
                    ),
              ),
              const SizedBox(height: AppTheme.spacing8),
              DropdownButtonFormField<EnumZeroPointRef?>(
                value: _zeroPointRef,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing16,
                    vertical: AppTheme.spacing12,
                  ),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('跟随资产（默认）'),
                  ),
                  ...EnumZeroPointRef.values
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e.label),
                          )),
                ],
                onChanged: (value) {
                  setState(() {
                    _zeroPointRef = value;
                  });
                  _updateConfig();
                },
              ),
              const SizedBox(height: AppTheme.spacing16),
              Text(
                '偏移量',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.secondaryText,
                    ),
              ),
              const SizedBox(height: AppTheme.spacing8),
              Row(
                children: ConstellationOffsetTier.values.map((tier) {
                  return Expanded(
                    child: _buildRadioTile<ConstellationOffsetTier?>(
                      title: tier.label,
                      subtitle: '默认 ${tier.defaultOffsetDeg}°',
                      value: tier,
                      groupValue: _offsetTier,
                      onChanged: (value) {
                        setState(() {
                          _offsetTier = value;
                          if (value != null) {
                            _constellationOffsetDeg =
                                value.defaultOffsetDeg;
                          }
                        });
                        _updateConfig();
                      },
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppTheme.spacing12),
              TextFormField(
                initialValue: _constellationOffsetDeg.toString(),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing16,
                    vertical: AppTheme.spacing12,
                  ),
                  helperText: '偏移数值（度），可覆盖档位默认',
                ),
                onChanged: (value) {
                  final parsed = double.tryParse(value);
                  if (parsed != null) {
                    setState(() {
                      _constellationOffsetDeg = parsed;
                    });
                    _updateConfig();
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacing16),

        // 星宿制式（ConstellationSystemType）
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
                '星宿类型',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: AppTheme.spacing12),
              Row(
                children: ConstellationSystemType.values.map((type) {
                  return Expanded(
                    child: _buildRadioTile<ConstellationSystemType>(
                      title: type.name,
                      subtitle: type.description,
                      value: type,
                      groupValue: _constellationSystemType,
                      onChanged: (value) {
                        setState(() {
                          _constellationSystemType = value!;
                        });
                        _updateConfig();
                      },
                    ),
                  );
                }).toList(),
              ),
              ExpansionTile(
                title: const Text('逐宿覆写'),
                children: [
                  ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: Enum28Constellations.values.map((c) {
                        final key = 'starinn_${c.name}';
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 80,
                                child: Text(c.starName, style: const TextStyle(fontSize: 14)),
                              ),
                              Expanded(
                                child: TextFormField(
                                  key: ValueKey(key),
                                  initialValue: _starInnDegreeOverrides?[c]?.toString() ?? '',
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    hintText: '度数',
                                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (text) {
                                    final v = double.tryParse(text);
                                    setState(() {
                                      if (v == null) {
                                        _starInnDegreeOverrides?.remove(c);
                                        if (_starInnDegreeOverrides?.isEmpty ?? true) {
                                          _starInnDegreeOverrides = null;
                                        }
                                      } else {
                                        _starInnDegreeOverrides ??= {};
                                        _starInnDegreeOverrides![c] = v;
                                      }
                                    });
                                    _updateConfig();
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
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
                initialValue: _classicBook.first,
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
                activeThumbColor: AppTheme.primaryColor,
              ),

              // 四余高级配置
              const Divider(),
              const SizedBox(height: AppTheme.spacing12),
              Text(
                '四余自定义推算',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: AppTheme.spacing8),
              SiYuProfileSelector(
                selectedId: _siYuProfileId,
                onChanged: (id) {
                  setState(() {
                    _siYuProfileId = id;
                  });
                  _updateConfig();
                },
              ),
              const SizedBox(height: AppTheme.spacing12),
              ...SiYuGroup.values.map((g) {
                final resolved = BuiltInSiYuProfiles.byId(_siYuProfileId);
                final spec = _siYuOverrides[g.name] ?? resolved.groups[g]!;
                return SiYuGroupEditor(
                  group: g,
                  spec: spec,
                  coordinate: _coordinateSystem,
                  onChanged: (newSpec) {
                    setState(() {
                      _siYuOverrides[g.name] = newSpec;
                    });
                    _updateConfig();
                  },
                );
              }),

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

  BasePanelConfig _currentConfig() {
    return BasePanelConfig(
      celestialCoordinateSystem: _coordinateSystem,
      houseDivisionSystem: _houseDivisionSystem,
      panelSystemType: _panelSystem,
      constellationSystemType: _constellationSystemType,
      settleLifeType: widget.initialConfig?.settleLifeType ??
          EnumSettleLifeType.Mao,
      settleBodyType: widget.initialConfig?.settleBodyType ??
          EnumSettleBodyType.moon,
      islifeGongBySunRealTimeLocation:
          widget.initialConfig?.islifeGongBySunRealTimeLocation ?? true,
      zhouTianModelOverride: _zhouTianModel,
      projectionOverride: _mappingStrategy == MappingStrategy.linear
          ? null
          : ProjectionConfig(
              strategy: MappingStrategy.tuiBianHuangDao,
              huangChiDaoDiffType: _huangChiDaoDiffType,
              epsilonDeg: _epsilonDeg,
              springEquinoxAnchor: _springEquinoxAnchor,
            ),
      zeroPointRef: _zeroPointRef,
      offsetTier: _offsetTier,
      constellationOffsetDeg: _constellationOffsetDeg,
      starInnDegreeOverrides: _starInnDegreeOverrides,
    );
  }

  List<Widget> _buildCoordinateSystemOptions(
      BuildContext context, List<CelestialCoordinateSystem> systems) {
    final subtitles = {
      CelestialCoordinateSystem.Ecliptic: '以黄道面为基准划分十二宫，接近西方占星',
      CelestialCoordinateSystem.Equatorial: '以赤道面为基准划分十二宫，周天 360°',
      CelestialCoordinateSystem.SkyEquatorial:
          '以天赤道面为基准，周天 365.25°合一年之数',
      CelestialCoordinateSystem.PseudoEcliptic:
          '采用不等宫系统，赤道坐标投影推算黄道位置',
    };
    return systems.map((system) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: _buildRadioTile(
          title: system.name,
          subtitle: subtitles[system] ?? system.description,
          value: system,
          groupValue: _coordinateSystem,
          onChanged: (value) {
            setState(() {
              _coordinateSystem = value!;
            });
            _autoFillRecommendedDefaults(value!);
            _updateConfig();
          },
        ),
      );
    }).toList();
  }

  void _autoFillRecommendedDefaults(CelestialCoordinateSystem coord) {
    switch (coord) {
      case CelestialCoordinateSystem.Ecliptic:
      case CelestialCoordinateSystem.Equatorial:
        _zhouTianModel = null;
        _mappingStrategy = MappingStrategy.linear;
        break;
      case CelestialCoordinateSystem.SkyEquatorial:
        _zhouTianModel = EnumZhouTianModel.degree36525;
        _mappingStrategy = MappingStrategy.linear;
        break;
      case CelestialCoordinateSystem.PseudoEcliptic:
        _zhouTianModel = EnumZhouTianModel.degree36525;
        _mappingStrategy = MappingStrategy.tuiBianHuangDao;
        break;
    }
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
