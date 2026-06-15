import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qizhengsiyu/domain/entities/models/base_panel_model.dart';
import 'package:qizhengsiyu/domain/entities/models/passage_year_panel_model.dart';
import 'package:qizhengsiyu/domain/entities/models/yuan_le_panel_model.dart';
import 'package:qizhengsiyu/domain/services/yuan_le_panel_builder.dart';
import 'package:qizhengsiyu/presentation/viewmodels/qi_zheng_si_yu_viewmodel.dart';

// ─── 调色板 ──────────────────────────────────────────────────────────────

class _C {
  // 文本颜色
  static const textMain = Color(0xFF1E293B);
  static const textMuted = Color(0xFF64748B);
  static const textLight = Color(0xFF94A3B8);

  // 背景色
  static const pageBg = Color(0xFFF8FAFC);
  static const cardBg = Color(0xFFFFFFFF);
  static const headerBg = Color(0xFFF1F5F9);
  static const dividerColor = Color(0xFFE2E8F0);

  // 状态色
  static const wangColor = Color(0xFF059669); // 旺 - 绿色
  static const shuaiColor = Color(0xFFF59E0B); // 衰 - 橙色
  static const xiColor = Color(0xFF7C3AED); // 喜 - 紫色
  static const leColor = Color(0xFF0EA5E9); // 乐 - 蓝色
}

/// 垣乐展示面板（表格式布局）
///
/// 按照图片#4的排版方式，左侧分组标签，中间星体名称，右侧详细信息
class YuanLeResultPanel extends StatelessWidget {
  const YuanLeResultPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<QiZhengSiYuViewModel>();
    final builder = context.read<YuanLePanelBuilder>();

    return ValueListenableBuilder<BasePanelModel?>(
      valueListenable: vm.uiBasePanelNotifier,
      builder: (context, natalPanel, _) {
        if (natalPanel == null) {
          debugPrint('[YuanLePanel] natalPanel is null');
          return const SizedBox.shrink();
        }

        return ValueListenableBuilder<PassageYearPanelModel?>(
          valueListenable: vm.uiDaXianPanelNotifier,
          builder: (context, transitPanel, _) {
            // 构建垣乐面板是异步操作
            return FutureBuilder<YuanLePanel>(
              future: builder.build(
                natalPanel,
                transitPanel: transitPanel,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox.shrink();
                }

                if (snapshot.hasError) {
                  debugPrint(
                      '[YuanLePanel] Error building panel: ${snapshot.error}');
                  return const SizedBox.shrink();
                }

                final yuanLePanel = snapshot.data;
                if (yuanLePanel == null) {
                  debugPrint('[YuanLePanel] Panel is null');
                  return const SizedBox.shrink();
                }

                debugPrint(
                    '[YuanLePanel] natalStars count: ${yuanLePanel.natalStars.length}');

                if (yuanLePanel.natalStars.isEmpty) {
                  debugPrint('[YuanLePanel] No stars found');
                  return const SizedBox.shrink();
                }

            return Container(
              color: _C.pageBg,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              child: Container(
                decoration: BoxDecoration(
                  color: _C.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0D000000),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                      spreadRadius: -4,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 标题
                      Row(
                        children: [
                          Text(
                            '星体垣乐',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: _C.textMain,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: _C.headerBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${yuanLePanel.natalStars.length} 颗',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: _C.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(
                          height: 1, color: _C.dividerColor, thickness: 1),
                      const SizedBox(height: 16),

                      // 表格式布局
                      _TableLayout(
                        panel: yuanLePanel,
                        hasTransit: transitPanel != null,
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

// ─── 表格布局 ──────────────────────────────────────────────────────────────

class _TableLayout extends StatelessWidget {
  final YuanLePanel panel;
  final bool hasTransit;

  const _TableLayout({
    required this.panel,
    required this.hasTransit,
  });

  @override
  Widget build(BuildContext context) {
    // 按状态分组星体
    final grouped = _groupStarsByStatus(panel.natalStars);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: _calculateTableWidth(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 表头
            _TableHeader(hasTransit: hasTransit),
            const SizedBox(height: 8),

            // 数据行
            ...grouped.entries.map((entry) {
              final status = entry.key;
              final stars = entry.value;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 状态分组标签
                  _StatusGroup(
                    status: status,
                    starCount: stars.length,
                    stars: stars,
                    hasTransit: hasTransit,
                  ),
                  const SizedBox(height: 2),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  /// 按垣位状态分组星体（动态分组）
  Map<String, List<YuanLeStarInfo>> _groupStarsByStatus(
      List<YuanLeStarInfo> stars) {
    final groups = <String, List<YuanLeStarInfo>>{};

    for (final star in stars) {
      final status = star.gongPositionStatus?.name ?? '其他';
      groups.putIfAbsent(status, () => []).add(star);
    }

    return groups;
  }

  /// 计算表格宽度
  double _calculateTableWidth() {
    double width = 60; // 左侧状态标签
    width += 80; // 星体名称列
    width += 120; // 入宿度数列
    width += 120; // 入宫度数列
    width += 50; // 星体状态列
    return width;
  }
}

// ─── 表头 ──────────────────────────────────────────────────────────────────

class _TableHeader extends StatelessWidget {
  final bool hasTransit;

  const _TableHeader({required this.hasTransit});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 左侧状态列
        SizedBox(
          width: 60,
          child: Text(
            '垣位',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _C.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // 星体名称列
        SizedBox(
          width: 80,
          child: Text(
            '星体',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _C.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // 入宿度数列
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                '入宿度数',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _C.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        // 入宫度数列
        Expanded(
          child: Text(
            '入宫度数',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _C.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // 星体状态列 (迟留伏逆等)
        SizedBox(
          width: 50,
          child: Text(
            '状态',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _C.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

// ─── 状态分组 ──────────────────────────────────────────────────────────────

class _StatusGroup extends StatelessWidget {
  final String status;
  final int starCount;
  final List<YuanLeStarInfo> stars;
  final bool hasTransit;

  const _StatusGroup({
    required this.status,
    required this.starCount,
    required this.stars,
    required this.hasTransit,
  });

  Color _getStatusColor() {
    switch (status) {
      case '庙':
        return const Color(0xFF8B5CF6);  // 紫色
      case '旺':
        return _C.wangColor;             // 绿色
      case '喜':
        return _C.xiColor;               // 紫色
      case '乐':
        return _C.leColor;               // 蓝色
      case '衰':
        return _C.shuaiColor;            // 橙色
      case '怒':
        return const Color(0xFFDC2626);  // 红色
      case '凶':
        return const Color(0xFFDC2626);  // 红色
      case '正':
        return const Color(0xFF10B981);  // 绿色
      case '偏':
        return const Color(0xFF6366F1);  // 靛蓝
      case '垣':
        return const Color(0xFF0EA5E9);  // 青色
      case '殿':
        return const Color(0xFF8B5CF6);  // 紫色
      case '贵':
        return const Color(0xFFF59E0B);  // 金色
      default:
        return _C.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 状态标签行
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 左侧状态标签
            SizedBox(
              width: 60,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _getStatusColor(),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 星体列表
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...stars.map((star) => _StarRow(
                        star: star,
                        hasTransit: hasTransit,
                      )),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── 星体数据行 ────────────────────────────────────────────────────────────

class _StarRow extends StatelessWidget {
  final YuanLeStarInfo star;
  final bool hasTransit;

  const _StarRow({
    required this.star,
    required this.hasTransit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 星体名称
          SizedBox(
            width: 80,
            child: Text(
              star.label.isEmpty ? star.star.singleName : star.label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _C.textMain,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // 入宿度数（星宿:度.分）
          Expanded(
            child: Text(
              star.formattedDegree,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: _C.textMain,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // 入宫度数（度.分）
          Expanded(
            child: Text(
              star.formattedGongDegree,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: _C.textMain,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // 星体状态（迟/留/伏/逆，"常"时不显示）
          SizedBox(
            width: 50,
            child: Text(
              _getWalkingStatusDisplay(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: star.walkingStatus != null &&
                        star.walkingStatus != '常'
                    ? _C.wangColor
                    : _C.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  /// 获取迟留伏逆状态显示（"常"时返回空）
  String _getWalkingStatusDisplay() {
    if (star.walkingStatus == null || star.walkingStatus == '常') {
      return '—';
    }
    return star.walkingStatus!;
  }
}
