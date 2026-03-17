import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qizhengsiyu/domain/entities/models/base_panel_model.dart';
import 'package:qizhengsiyu/domain/entities/models/passage_year_panel_model.dart';
import 'package:qizhengsiyu/domain/entities/models/yuan_le_panel_model.dart';
import 'package:qizhengsiyu/domain/services/yuan_le_panel_builder.dart';
import 'package:qizhengsiyu/presentation/viewmodels/qi_zheng_si_yu_viewmodel.dart';
import 'package:common/enums.dart';
import 'package:qizhengsiyu/enums/enum_star_position_status.dart';

// ─── 调色板 ──────────────────────────────────────────────────────────────

class _CV2 {
  // 基础颜色
  static const textMain = Color(0xFF1E293B);
  static const textMuted = Color(0xFF64748B);
  static const pageBg = Color(0xFFF8FAFC);
  static const cardBg = Color(0xFFFFFFFF);
  static const headerBg = Color(0xFFF1F5F9);
  static const dividerColor = Color(0xFFE2E8F0);

  // 状态颜色 (v5.html)
  static const statusMiao = Color(0xFFEF4444);
  static const statusMiaoBg = Color(0xFFFEF2F2);
  static const statusWang = Color(0xFF8B5CF6);
  static const statusWangBg = Color(0xFFF5F3FF);
  static const statusLe = Color(0xFFF97316);
  static const statusLeBg = Color(0xFFFFF7ED);
  static const statusXi = Color(0xFFEAB308);
  static const statusXiBg = Color(0xFFFEFCE8);
  static const statusNone = Color(0xFF64748B);
  static const statusNoneBg = Color(0xFFF8FAFC);

  // 动态状态 (逆行/运行状态)
  static const walkingNegativeColor = Color(0xFF10B981); // 翠绿 (也即 retrogradeColor)
  static const walkingNegativeBg = Color(0xFFECFDF5);
  static const walkingPositiveColor = Color(0xFF0EA5E9); // 天蓝
  static const walkingPositiveBg = Color(0xFFF0F9FF);

  @Deprecated('Use walkingNegativeColor')
  static const retrogradeColor = walkingNegativeColor;
  @Deprecated('Use walkingNegativeBg')
  static const retrogradeBg = walkingNegativeBg;
}

/// 垣乐展示面板 V2（表格式布局）
class YuanLeResultPanelV2 extends StatefulWidget {
  const YuanLeResultPanelV2({super.key});

  @override
  State<YuanLeResultPanelV2> createState() => _YuanLeResultPanelV2State();
}

class _YuanLeResultPanelV2State extends State<YuanLeResultPanelV2> {
  int _currentPageIndex = 0;
  Future<YuanLePanel>? _cachedFuture;
  BasePanelModel? _lastNatalPanel;
  PassageYearPanelModel? _lastTransitPanel;

  void _handlePageChanged(int index) {
    setState(() {
      _currentPageIndex = index;
    });
  }

  Future<YuanLePanel> _getFuture(
      BasePanelModel natalPanel, PassageYearPanelModel? transitPanel) {
    if (_cachedFuture != null &&
        identical(_lastNatalPanel, natalPanel) &&
        identical(_lastTransitPanel, transitPanel)) {
      return _cachedFuture!;
    }
    _lastNatalPanel = natalPanel;
    _lastTransitPanel = transitPanel;
    _cachedFuture = YuanLePanelBuilder.build(
      natalPanel,
      transitPanel: transitPanel,
    );
    return _cachedFuture!;
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<QiZhengSiYuViewModel>();

    return ValueListenableBuilder<BasePanelModel?>(
      valueListenable: vm.uiBasePanelNotifier,
      builder: (context, natalPanel, _) {
        if (natalPanel == null) return const SizedBox.shrink();

        return ValueListenableBuilder<PassageYearPanelModel?>(
          valueListenable: vm.uiDaXianPanelNotifier,
          builder: (context, transitPanel, _) {
            return FutureBuilder<YuanLePanel>(
              future: _getFuture(natalPanel, transitPanel),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();

                final yuanLePanel = snapshot.data!;
                final hasTransit =
                    transitPanel != null && yuanLePanel.transitStars != null;

                return Container(
                  color: _CV2.pageBg,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _CV2.cardBg,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0D000000),
                          blurRadius: 25,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (hasTransit)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Row(
                                children: [
                                  const Spacer(),
                                  _PanelSwitcher(
                                    currentPageIndex: _currentPageIndex,
                                    onPageChanged: _handlePageChanged,
                                  ),
                                ],
                              ),
                            ),
                          _V2SwitchableTableLayout(
                            natalStars: yuanLePanel.natalStars,
                            transitStars: yuanLePanel.transitStars ?? [],
                            currentPageIndex: _currentPageIndex,
                            showTransit: hasTransit,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _V2SwitchableTableLayout extends StatefulWidget {
  final List<YuanLeStarInfo> natalStars;
  final List<YuanLeStarInfo> transitStars;
  final int currentPageIndex;
  final bool showTransit;

  const _V2SwitchableTableLayout({
    required this.natalStars,
    required this.transitStars,
    required this.currentPageIndex,
    required this.showTransit,
  });

  @override
  State<_V2SwitchableTableLayout> createState() =>
      _V2SwitchableTableLayoutState();
}

class _V2SwitchableTableLayoutState extends State<_V2SwitchableTableLayout> {
  int _prevPageIndex = 0;

  @override
  void didUpdateWidget(covariant _V2SwitchableTableLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    _prevPageIndex = oldWidget.currentPageIndex;
  }

  @override
  Widget build(BuildContext context) {
    final bodyLifeStars =
        widget.natalStars.where((s) => s.isBodyLifeMaster).toList();
    final ordinaryStars = (!widget.showTransit || widget.currentPageIndex == 0)
        ? widget.natalStars.where((s) => !s.isBodyLifeMaster).toList()
        : widget.transitStars.where((s) => !s.isBodyLifeMaster).toList();

    final slideForward = widget.currentPageIndex > _prevPageIndex;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        width: 552, // Reduced to fit optimized column widths
        decoration: BoxDecoration(
          border: Border.all(color: _CV2.dividerColor.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            ...bodyLifeStars
                .asMap()
                .entries
                .map((e) => _buildStarRow(e.value, isEven: e.key.isEven)),
            if (widget.showTransit)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  final isIncoming =
                      child.key == ValueKey(widget.currentPageIndex);
                  final tween = slideForward
                      ? (isIncoming
                          ? Tween(begin: const Offset(0.2, 0), end: Offset.zero)
                          : Tween(
                              begin: const Offset(-0.2, 0), end: Offset.zero))
                      : (isIncoming
                          ? Tween(
                              begin: const Offset(-0.2, 0), end: Offset.zero)
                          : Tween(
                              begin: const Offset(0.2, 0), end: Offset.zero));
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                        position: tween.animate(animation), child: child),
                  );
                },
                child: Column(
                  key: ValueKey(widget.currentPageIndex),
                  children: ordinaryStars
                      .asMap()
                      .entries
                      .map((e) => _buildStarRow(e.value,
                          isEven: (e.key + bodyLifeStars.length).isEven))
                      .toList(),
                ),
              )
            else
              Column(
                children: ordinaryStars
                    .asMap()
                    .entries
                    .map((e) => _buildStarRow(e.value,
                        isEven: (e.key + bodyLifeStars.length).isEven))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarRow(YuanLeStarInfo star, {bool isEven = false}) {
    final hasGong = star.gongPositionStatus != null;
    final hasInn = star.innPositionStatus != null;
    final gongColor = _getStatusColor(star.gongPositionStatus);
    final innColor = _getStatusColor(star.innPositionStatus);

    // 背景颜色采用 斑马纹 + 实时动态Tag的浅色
    final bgColor = _getStatusBgColor(star, isEven);

    return Container(
      color: bgColor,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Container(
              width: 42,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (hasGong || hasInn)
                    Container(
                      width: 5,
                      height: 28,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              color: hasGong
                                  ? gongColor
                                  : (hasInn ? innColor : Colors.transparent),
                            ),
                          ),
                          if (hasGong && hasInn)
                            Expanded(
                              child: Container(
                                color: innColor,
                              ),
                            ),
                        ],
                      ),
                    ),
                  if (star.label.isEmpty)
                    SizedBox(
                      width: 8,
                    ),
                  Text(
                    star.label.isEmpty ? star.star.singleName : star.label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: _CV2.textMain),
                  ),
                ],
              )),
          Container(
            width: 72,
            child: Align(
              alignment: Alignment.center,
              child: _V2StatusBadge(
                gongStatus: star.gongPositionStatus,
                innStatus: star.innPositionStatus,
              ),
            ),
          ),
          SizedBox(
            width: 160,
            child: _V2DegreeColumn(
              label: star.constellationName,
              formattedDegree: star.formattedDegree.split(' ').last,
              progress: star.degree / star.constellationTotalDegree,
              color: innColor == _CV2.statusNone
                  ? const Color(0xFF94A3B8)
                  : innColor,
            ),
          ),
          SizedBox(
            width: 160,
            child: _V2DegreeColumn(
              label: star.gongName,
              formattedDegree:
                  '${star.formattedGongDegree.substring(star.gongName.length)}/30.00',
              progress: star.gongDegree / 30,
              color: gongColor == _CV2.statusNone
                  ? const Color(0xFF94A3B8)
                  : gongColor,
            ),
          ),
          SizedBox(
              width: 40,
              child: Align(
                  alignment: Alignment.centerRight,
                  child: _V2DynamicStatus(star))),
        ],
      ),
    );
  }

  Color _getStatusColor(EnumStarGongPositionStatusType? status) {
    if (status == null) return _CV2.statusNone;
    switch (status) {
      case EnumStarGongPositionStatusType.Miao:
        return _CV2.statusMiao;
      case EnumStarGongPositionStatusType.Wang:
        return _CV2.statusWang;
      case EnumStarGongPositionStatusType.Le:
        return _CV2.statusLe;
      case EnumStarGongPositionStatusType.Xi:
        return _CV2.statusXi;
      case EnumStarGongPositionStatusType.Dian:
        return const Color(0xFF1E293B);
      default:
        return _CV2.statusNone;
    }
  }

  Color _getStatusBgColor(YuanLeStarInfo star, bool isEven) {
    // 基础背景
    Color baseBg = isEven ? Colors.white : _CV2.statusNoneBg;

    final status = star.walkingStatus;
    if (status != null && status != '常') {
      final isNegative = _isWalkingNegative(star);
      final overlayColor =
          isNegative ? _CV2.walkingNegativeBg : _CV2.walkingPositiveBg;
      return Color.alphaBlend(overlayColor.withOpacity(0.5), baseBg);
    }

    return baseBg;
  }

  bool _isWalkingNegative(YuanLeStarInfo star) {
    final status = star.walkingStatus;
    if (status == null || status == '常') return false;

    // 只处理五星：金木水火土
    const fiveStars = [
      EnumStars.Mercury,
      EnumStars.Venus,
      EnumStars.Mars,
      EnumStars.Jupiter,
      EnumStars.Saturn
    ];
    if (!fiveStars.contains(star.star)) return false;

    if (['迟', '留', '伏', '逆'].contains(status)) return true;
    if (status == '速' && star.star == EnumStars.Venus) return true;

    return false;
  }
}

class _V2StatusBadge extends StatelessWidget {
  final EnumStarGongPositionStatusType? gongStatus;
  final EnumStarGongPositionStatusType? innStatus;
  const _V2StatusBadge({this.gongStatus, this.innStatus});

  @override
  Widget build(BuildContext context) {
    if (gongStatus == null && innStatus == null) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (gongStatus != null) _buildOneBadge(gongStatus!, isGong: true),
        if (gongStatus != null && innStatus != null) const SizedBox(width: 4),
        if (innStatus != null) _buildOneBadge(innStatus!, isGong: false),
      ],
    );
  }

  Widget _buildOneBadge(EnumStarGongPositionStatusType status,
      {required bool isGong}) {
    Color color;
    Color bgColor;
    switch (status) {
      case EnumStarGongPositionStatusType.Miao:
        color = _CV2.statusMiao;
        bgColor = _CV2.statusMiaoBg;
        break;
      case EnumStarGongPositionStatusType.Wang:
        color = _CV2.statusWang;
        bgColor = _CV2.statusWangBg;
        break;
      case EnumStarGongPositionStatusType.Le:
        color = _CV2.statusLe;
        bgColor = _CV2.statusLeBg;
        break;
      case EnumStarGongPositionStatusType.Xi:
        color = _CV2.statusXi;
        bgColor = _CV2.statusXiBg;
        break;
      case EnumStarGongPositionStatusType.Dian:
        color = Colors.white;
        bgColor = const Color(0xFF1E293B);
        break;
      default:
        color = _CV2.textMuted;
        bgColor = _CV2.statusNoneBg;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(isGong ? 100 : 4),
        border: color != Colors.white && color != _CV2.textMuted
            ? Border.all(color: color.withOpacity(0.3), width: 2)
            : null,
      ),
      child: Text(
        status.name,
        style:
            TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: color),
      ),
    );
  }
}

class _V2DegreeColumn extends StatelessWidget {
  final String label;
  final String formattedDegree;
  final double progress;
  final Color color;
  const _V2DegreeColumn(
      {required this.label,
      required this.formattedDegree,
      required this.progress,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            ..._buildDegreeText(formattedDegree),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          width: 120,
          height: 5,
          decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(2.5)),
          clipBehavior: Clip.antiAlias,
          child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                  decoration: BoxDecoration(
                      color: color, borderRadius: BorderRadius.circular(2.5)))),
        ),
      ],
    );
  }

  List<Widget> _buildDegreeText(String text) {
    // text 格式通常为 "当前度数/总度数" (例如 "14.30/30.00")
    if (!text.contains('/')) {
      return [
        Text('$label $text',
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _CV2.textMain))
      ];
    }

    final parts = text.split('/');
    final current = parts[0]; // 入宿度数
    final total = parts[1]; // 星宿固定度数

    // 基础颜色 (星宿名、星宿固定度数、斜杠) - 与进度条颜色一致
    final baseColor =
        (color == _CV2.statusNone || color == const Color(0xFF94A3B8))
            ? _CV2.textMuted
            : color;

    return [
      Text('$label $total / ',
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: baseColor)),
      Text(current,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: _CV2.textMuted)),
    ];
  }
}

class _V2DynamicStatus extends StatelessWidget {
  final YuanLeStarInfo star;
  const _V2DynamicStatus(this.star);

  @override
  Widget build(BuildContext context) {
    final status = star.walkingStatus;
    if (status == null || status == '常') return const SizedBox.shrink();

    // 运行状态逻辑划分 (只处理五星: 金木水火土)
    final fiveStars = [
      EnumStars.Mercury,
      EnumStars.Venus,
      EnumStars.Mars,
      EnumStars.Jupiter,
      EnumStars.Saturn
    ];
    if (!fiveStars.contains(star.star)) return const SizedBox.shrink();

    // 正负向判断
    bool isNegative = false;
    if (['迟', '留', '伏', '逆'].contains(status)) {
      isNegative = true;
    } else if (status == '速') {
      // 金星之速为负，其他为正
      isNegative = (star.star == EnumStars.Venus);
    }

    final color =
        isNegative ? _CV2.walkingNegativeColor : _CV2.walkingPositiveColor;
    final bgColor =
        isNegative ? _CV2.walkingNegativeBg : _CV2.walkingPositiveBg;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration:
          BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
      child: Text(status,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: color,
              fontStyle: FontStyle.italic)),
    );
  }
}

class _PanelSwitcher extends StatelessWidget {
  final int currentPageIndex;
  final Function(int) onPageChanged;
  const _PanelSwitcher(
      {required this.currentPageIndex, required this.onPageChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
          color: _CV2.headerBg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          _SwitchOption(
              label: '本命',
              isActive: currentPageIndex == 0,
              onTap: () => onPageChanged(0)),
          _SwitchOption(
              label: '流年',
              isActive: currentPageIndex == 1,
              onTap: () => onPageChanged(1)),
        ],
      ),
    );
  }
}

class _SwitchOption extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _SwitchOption(
      {required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
            color: isActive ? _CV2.statusWang : Colors.transparent,
            borderRadius: BorderRadius.circular(10)),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : _CV2.textMuted)),
      ),
    );
  }
}
