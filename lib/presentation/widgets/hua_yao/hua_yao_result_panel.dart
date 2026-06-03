import 'package:metaphysics_core/enums.dart';
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
    '人元禄',
    '地元禄',
    '天元禄',
    '科甲',
    '天经',
    '地纬',
    '局主',
    '职元',
    '值难',
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

  /// 排版分组及组内顺序（基于参考图的折行方案，不依赖 ShenShaType）
  static const _displayGroupOrder = [
    // 果老十天化曜 + 天嗣
    ['天禄', '天暗', '天福', '天耗', '天荫', '天贵', '天刑', '天印', '天囚', '天权', '天嗣'],
    // 天干神煞
    ['爵神', '喜神', '禄神', '催官', '寿元', '印星', '官星', '魁星', '文星', '科甲', '科名'],
    // 地支化曜
    ['产星', '血忌', '血支', '仁元', '人元禄', '地元禄', '天元禄', '马元', '禄元', '地驿', '天马'],
    // 命宫/其他
    ['伤官', '地纬', '天经', '局主', '职元', '值难', '生官'],
  ];

  List<_HuaYaoGroup> _groupItems(List<_HuaYaoDisplayItem> items) {
    final itemMap = {for (final i in items) i.name: i};
    final used = <String>{};
    final groups = <_HuaYaoGroup>[];

    for (final nameList in _displayGroupOrder) {
      final groupItems = <_HuaYaoDisplayItem>[];
      for (final name in nameList) {
        final item = itemMap[name];
        if (item != null) {
          groupItems.add(item);
          used.add(name);
        }
      }
      groups.add(_HuaYaoGroup(items: groupItems));
    }

    // 未匹配的项追加到最后一组
    final remaining = items.where((i) => !used.contains(i.name)).toList();
    if (remaining.isNotEmpty) {
      if (groups.isNotEmpty) {
        groups.last = _HuaYaoGroup(items: [...groups.last.items, ...remaining]);
      } else {
        groups.add(_HuaYaoGroup(items: remaining));
      }
    }
    return groups;
  }
}

class _HuaYaoGroup {
  final List<_HuaYaoDisplayItem> items;
  const _HuaYaoGroup({required this.items});
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

    final totalCount =
        nonEmptyGroups.fold<int>(0, (sum, g) => sum + g.items.length);

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
            // 标题
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
                    '$totalCount 项',
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
            const SizedBox(height: 12),

            // 按分组折行，组间用分隔线隔开，无分组标题
            for (int i = 0; i < nonEmptyGroups.length; i++) ...[
              if (i > 0) ...[
                const SizedBox(height: 12),
                const Divider(height: 1, color: _C.dividerColor),
                const SizedBox(height: 12),
              ],
              _buildGroupRows(nonEmptyGroups[i].items),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建一个分组的行式布局（名称行 + 阴阳胶囊行）
  Widget _buildGroupRows(List<_HuaYaoDisplayItem> items) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 名称行
          Row(
            children: items.map((item) => _nameCell(item.name)).toList(),
          ),
          const SizedBox(height: 4),
          // 阴阳胶囊行
          Row(
            children: items.map((item) => _capsuleCell(item)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _nameCell(String name) {
    return Container(
      width: 36,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      child: Text(
        name,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: _C.textMain,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  /// 阴阳胶囊：上半本命（暖色），下半流年（冷色），始终双色显示
  Widget _capsuleCell(_HuaYaoDisplayItem item) {
    final showTransit = !item.natalOnly && item.transitStar != null;
    return Container(
      width: 36,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 上：本命（暖色）
          Container(
            height: 22,
            alignment: Alignment.center,
            color: _C.natalBg,
            child: Text(
              item.natalStar.singleName,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _C.natalText,
              ),
            ),
          ),
          // 下：流年（冷色）或占位符
          Container(
            height: 22,
            alignment: Alignment.center,
            color: showTransit ? _C.transitBg : _C.badgeBg,
            child: Text(
              showTransit ? item.transitStar!.singleName : '—',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: showTransit ? _C.transitText : _C.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
