import 'package:common/enums.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qizhengsiyu/domain/entities/models/base_panel_model.dart';
import 'package:qizhengsiyu/domain/entities/models/passage_year_panel_model.dart';
import 'package:qizhengsiyu/enums/enum_hua_yao_shen_sha.dart';
import 'package:qizhengsiyu/presentation/viewmodels/qi_zheng_si_yu_viewmodel.dart';

// ─── 调色板（与 GeJuResultPanel 保持一致的设计语言）──────────────────────────────

class _C {
  // 本命色系 — 暖色（琥珀/橙）
  static const natalBg = Color(0xFFFFFBEB);
  static const natalText = Color(0xFFD97706);
  static const natalBorder = Color(0xFFFDE68A);

  // 流年色系 — 冷色（靛蓝）
  static const transitBg = Color(0xFFEEF2FF);
  static const transitText = Color(0xFF4F46E5);
  static const transitBorder = Color(0xFFC7D2FE);

  // 吉色系
  static const jiColor = Color(0xFF059669);
  // 凶色系
  static const xiongColor = Color(0xFFE11D48);
  // 平色系
  static const pingColor = Color(0xFF64748B);

  // 通用
  static const pageBg = Color(0xFFF8FAFC);
  static const cardBg = Color(0xFFFFFFFF);
  static const textMain = Color(0xFF1E293B);
  static const textMuted = Color(0xFF64748B);
  static const badgeBg = Color(0xFFF1F5F9);
  static const dividerColor = Color(0xFFF1F5F9);
}

// ─── 化曜展示数据模型 ──────────────────────────────────────────────────────────

class _HuaYaoDisplayItem {
  final String name;
  final JiXiongEnum jiXiong;
  final ShenShaType type;
  final EnumStars natalStar;
  final EnumStars? transitStar;
  final bool natalOnly;

  const _HuaYaoDisplayItem({
    required this.name,
    required this.jiXiong,
    required this.type,
    required this.natalStar,
    this.transitStar,
    this.natalOnly = false,
  });
}

// ─── 主入口 Widget ─────────────────────────────────────────────────────────────

/// 天星化曜面板
///
/// 以四个分组 Section Card 展示本命与流年化曜对比。
/// 每个 Section 内部为竖排列的化曜列，水平可滚动。
class HuaYaoResultPanel extends StatelessWidget {
  const HuaYaoResultPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<QiZhengSiYuViewModel>();

    return ValueListenableBuilder<BasePanelModel?>(
      valueListenable: vm.uiBasePanelNotifier,
      builder: (context, natalPanel, _) {
        if (natalPanel == null || natalPanel.huaYaoMapper.isEmpty) {
          return const SizedBox.shrink();
        }

        return ValueListenableBuilder<PassageYearPanelModel?>(
          valueListenable: vm.uiDaXianPanelNotifier,
          builder: (context, transitPanel, _) {
            final items = _buildDisplayItems(natalPanel, transitPanel);
            if (items.isEmpty) return const SizedBox.shrink();

            final groups = _groupItems(items);

            return Container(
              color: _C.pageBg,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: _HuaYaoUnifiedCard(
                groups: groups,
                hasTransit: transitPanel != null,
              ),
            );
          },
        );
      },
    );
  }

  /// 这些化曜基于命宫/固定条件推算，流年不改变结果，不显示流年星
  static const _natalOnlyNames = {
    '人元禄', '地元禄', '天元禄', '科甲', '天经', '地纬', '局主', '职元', '值难',
  };

  List<_HuaYaoDisplayItem> _buildDisplayItems(
    BasePanelModel natalPanel,
    PassageYearPanelModel? transitPanel,
  ) {
    final natalMap = natalPanel.huaYaoMapper;
    final transitMap = transitPanel?.huaYaoMapper;

    return natalMap.entries.map((e) {
      final showTransit = !_natalOnlyNames.contains(e.key.name);
      final transitStar = showTransit
          ? transitMap?.entries
              .where((t) => t.key.name == e.key.name)
              .firstOrNull
              ?.value
          : null;
      return _HuaYaoDisplayItem(
        name: e.key.name,
        jiXiong: e.key.jiXiong,
        type: e.key.type,
        natalStar: e.value,
        transitStar: transitStar,
        natalOnly: !showTransit,
      );
    }).toList();
  }

  List<_HuaYaoGroup> _groupItems(List<_HuaYaoDisplayItem> items) {
    // 果老十天化曜（天禄/天暗/天福/天耗/天荫/天贵/天刑/天印/天囚/天权）
    final group1 = items.where((i) => i.type == ShenShaType.GuoLao).toList();

    // 天干神煞（科名/文星/魁星/官星/印星/催官/禄神/禄元/仁元/喜神/生官/伤官/天官/天嗣）
    final group2 = items.where((i) => i.type == ShenShaType.TianGan).toList();

    // 地支化曜
    final group3 = items.where((i) =>
        i.type == ShenShaType.DiZhi_year || i.type == ShenShaType.DiZhi_month).toList();

    // 其他化曜
    final group4 = items.where((i) =>
        i.type == ShenShaType.MingGong ||
        i.type == ShenShaType.Others ||
        i.type == ShenShaType.NaYin ||
        i.type == ShenShaType.NaJia).toList();

    return [
      _HuaYaoGroup(title: '十天化曜', items: group1),
      _HuaYaoGroup(title: '天干神煞', items: group2),
      _HuaYaoGroup(title: '地支化曜', items: group3),
      _HuaYaoGroup(title: '其他化曜', items: group4),
    ];
  }
}

class _HuaYaoGroup {
  final String title;
  final List<_HuaYaoDisplayItem> items;
  const _HuaYaoGroup({required this.title, required this.items});
}

// ─── Unified 卡片（合并所有分组到一个卡片）─────────────────────────────────────

class _HuaYaoUnifiedCard extends StatelessWidget {
  final List<_HuaYaoGroup> groups;
  final bool hasTransit;

  const _HuaYaoUnifiedCard({
    required this.groups,
    required this.hasTransit,
  });

  @override
  Widget build(BuildContext context) {
    final nonEmptyGroups = groups.where((g) => g.items.isNotEmpty).toList();
    if (nonEmptyGroups.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 25,
            offset: Offset(0, 10),
            spreadRadius: -5,
          ),
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 10,
            offset: Offset(0, 8),
            spreadRadius: -6,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 总标题
            Row(
              children: [
                Text(
                  '化曜神煞',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: _C.textMain,
                    letterSpacing: -0.3,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: _C.badgeBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${nonEmptyGroups.fold<int>(0, (sum, g) => sum + g.items.length)} 项',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _C.textMuted,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1, color: _C.dividerColor),
            const SizedBox(height: 18),

            // 所有分组
            for (int groupIdx = 0; groupIdx < nonEmptyGroups.length; groupIdx++) ...[
              if (groupIdx > 0) ...[
                const SizedBox(height: 20),
                const Divider(height: 1, color: _C.dividerColor),
                const SizedBox(height: 18),
              ],
              _HuaYaoGroupSection(
                group: nonEmptyGroups[groupIdx],
                hasTransit: hasTransit,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── 分组小节（在unified卡片内显示）──────────────────────────────────────────

class _HuaYaoGroupSection extends StatelessWidget {
  final _HuaYaoGroup group;
  final bool hasTransit;

  const _HuaYaoGroupSection({
    required this.group,
    required this.hasTransit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 分组标题
        Row(
          children: [
            Text(
              group.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _C.textMain,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _C.badgeBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${group.items.length} 项',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: _C.textMuted,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 化曜列表（水平滚动）
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: group.items.map((item) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _buildHuaYaoItem(item, hasTransit),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildHuaYaoItem(
    _HuaYaoDisplayItem item,
    bool hasTransit,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 化曜名称
        SizedBox(
          width: 48,
          child: Text(
            item.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _C.textMain,
              overflow: TextOverflow.ellipsis,
            ),
            maxLines: 2,
          ),
        ),
        const SizedBox(height: 6),

        // 吉凶标记
        Container(
          width: 48,
          height: 20,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: item.jiXiong == JiXiongEnum.JI
                ? const Color(0xFFECFDF5)
                : item.jiXiong == JiXiongEnum.XIONG
                    ? const Color(0xFFFEF2F2)
                    : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: item.jiXiong == JiXiongEnum.JI
                  ? const Color(0xFFA7F3D0)
                  : item.jiXiong == JiXiongEnum.XIONG
                      ? const Color(0xFFFECACA)
                      : const Color(0xFFE2E8F0),
              width: 0.5,
            ),
          ),
          child: Text(
            item.jiXiong == JiXiongEnum.JI
                ? '吉'
                : item.jiXiong == JiXiongEnum.XIONG
                    ? '凶'
                    : '平',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: item.jiXiong == JiXiongEnum.JI
                  ? _C.jiColor
                  : item.jiXiong == JiXiongEnum.XIONG
                      ? _C.xiongColor
                      : _C.pingColor,
            ),
          ),
        ),
        const SizedBox(height: 6),

        // 本命星（单字）
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _C.natalBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _C.natalBorder, width: 0.5),
          ),
          child: Text(
            item.natalStar.singleName,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _C.natalText,
            ),
          ),
        ),

        if (hasTransit && !item.natalOnly) ...[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 2),
            child: Text('│',
                style: TextStyle(fontSize: 10, color: _C.textMuted)),
          ),

          // 流年星（单字）
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _C.transitBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _C.transitBorder, width: 0.5),
            ),
            child: Text(
              item.transitStar?.singleName ?? '—',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: item.transitStar != null
                    ? _C.transitText
                    : _C.textMuted,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
