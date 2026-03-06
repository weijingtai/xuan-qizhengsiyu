import 'package:common/enums.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_result.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju_model.dart';
import 'package:qizhengsiyu/presentation/viewmodels/qi_zheng_si_yu_viewmodel.dart';

// ─── 调色板 ───────────────────────────────────────────────────────────────────

class _GeJuColors {
  // 吉 — 松花绿系
  static const jiPrimary = Color(0xFF1C4A34);
  static const jiAccent = Color(0xFF2E7D52);
  static const jiLight = Color(0xFFEAF4EE);
  static const jiBorder = Color(0xFF5A9C75);

  // 凶 — 朱砂红系
  static const xiongPrimary = Color(0xFF6B1A1A);
  static const xiongAccent = Color(0xFF9C2D2D);
  static const xiongLight = Color(0xFFF9EDED);
  static const xiongBorder = Color(0xFFC05050);

  // 通用
  static const gold = Color(0xFFB8963E);
  static const parchment = Color(0xFFF8F3E8);
  static const inkLight = Color(0xFF6B6355);
  static const inkFaint = Color(0xFF9E9789);
}

// ─── 主入口 Widget ─────────────────────────────────────────────────────────────

/// 命盘格局面板
///
/// 置于星盘下方，显示吉/凶两类格局 Card 列表。
/// 通过 [QiZhengSiYuViewModel.geJuSummaryNotifier] 监听评估结果。
class GeJuResultPanel extends StatefulWidget {
  const GeJuResultPanel({super.key});

  @override
  State<GeJuResultPanel> createState() => _GeJuResultPanelState();
}

class _GeJuResultPanelState extends State<GeJuResultPanel> {
  bool _isLoading = false;

  Future<void> _evaluate() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      await context.read<QiZhengSiYuViewModel>().evaluateGeJu(onlyMatched: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<GeJuEvaluationSummary?>(
      valueListenable:
          context.read<QiZhengSiYuViewModel>().geJuSummaryNotifier,
      builder: (context, summary, _) {
        return Container(
          color: _GeJuColors.parchment,
          padding: const EdgeInsets.fromLTRB(12, 20, 12, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SectionTitle(
                onEvaluate: _isLoading ? null : _evaluate,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 16),
              if (summary == null && !_isLoading)
                _EmptyHint(onTap: _evaluate)
              else if (_isLoading && summary == null)
                const _LoadingPlaceholder()
              else if (summary != null)
                _ResultBody(summary: summary),
            ],
          ),
        );
      },
    );
  }
}

// ─── 节标题 ───────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final VoidCallback? onEvaluate;
  final bool isLoading;

  const _SectionTitle({required this.onEvaluate, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 左侧装饰线
        Expanded(child: _OrnamentalDivider(reversed: true)),
        const SizedBox(width: 12),
        Column(
          children: [
            Text(
              '命 盘 格 局',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 3,
                color: _GeJuColors.jiPrimary,
              ),
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: onEvaluate,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: isLoading
                    ? SizedBox(
                        key: const ValueKey('loading'),
                        width: 72,
                        height: 22,
                        child: Center(
                          child: SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              color: _GeJuColors.gold,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        key: const ValueKey('btn'),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 2),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: _GeJuColors.gold, width: 0.8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '◈ 测算格局',
                          style: TextStyle(
                            fontSize: 11,
                            color: _GeJuColors.gold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(child: _OrnamentalDivider()),
      ],
    );
  }
}

// ─── 装饰分割线 ───────────────────────────────────────────────────────────────

class _OrnamentalDivider extends StatelessWidget {
  final bool reversed;
  const _OrnamentalDivider({this.reversed = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!reversed) ...[
          Expanded(
            child: Divider(
              color: _GeJuColors.gold.withOpacity(0.4),
              thickness: 0.8,
            ),
          ),
          const SizedBox(width: 4),
          Text('◆', style: TextStyle(fontSize: 8, color: _GeJuColors.gold)),
          const SizedBox(width: 4),
          Text('◇', style: TextStyle(fontSize: 6, color: _GeJuColors.gold)),
        ] else ...[
          Text('◇', style: TextStyle(fontSize: 6, color: _GeJuColors.gold)),
          const SizedBox(width: 4),
          Text('◆', style: TextStyle(fontSize: 8, color: _GeJuColors.gold)),
          const SizedBox(width: 4),
          Expanded(
            child: Divider(
              color: _GeJuColors.gold.withOpacity(0.4),
              thickness: 0.8,
            ),
          ),
        ],
      ],
    );
  }
}

// ─── 空状态 / 占位 ─────────────────────────────────────────────────────────────

class _EmptyHint extends StatelessWidget {
  final VoidCallback onTap;
  const _EmptyHint({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          border: Border.all(
              color: _GeJuColors.gold.withOpacity(0.25), width: 0.8),
          borderRadius: BorderRadius.circular(4),
        ),
        alignment: Alignment.center,
        child: Text(
          '点击「测算格局」以查看命盘中的吉凶格局',
          style: TextStyle(
            fontSize: 13,
            color: _GeJuColors.inkFaint,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      alignment: Alignment.center,
      child: Text(
        '正在推演格局…',
        style: TextStyle(fontSize: 13, color: _GeJuColors.inkFaint),
      ),
    );
  }
}

// ─── 结果主体 ─────────────────────────────────────────────────────────────────

class _ResultBody extends StatelessWidget {
  final GeJuEvaluationSummary summary;
  const _ResultBody({required this.summary});

  @override
  Widget build(BuildContext context) {
    final ji = summary.matchedAuspiciousPatterns;
    final xiong = summary.matchedInauspiciousPatterns;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _GeJuGroupCard(
            title: '吉  格',
            count: ji.length,
            results: ji,
            primaryColor: _GeJuColors.jiPrimary,
            accentColor: _GeJuColors.jiAccent,
            lightColor: _GeJuColors.jiLight,
            borderColor: _GeJuColors.jiBorder,
            badgeColor: _GeJuColors.jiAccent,
            headerIcon: '☽',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _GeJuGroupCard(
            title: '凶  格',
            count: xiong.length,
            results: xiong,
            primaryColor: _GeJuColors.xiongPrimary,
            accentColor: _GeJuColors.xiongAccent,
            lightColor: _GeJuColors.xiongLight,
            borderColor: _GeJuColors.xiongBorder,
            badgeColor: _GeJuColors.xiongAccent,
            headerIcon: '☿',
          ),
        ),
      ],
    );
  }
}

// ─── 吉/凶 分组 Card ──────────────────────────────────────────────────────────

class _GeJuGroupCard extends StatelessWidget {
  final String title;
  final int count;
  final List<GeJuResult> results;
  final Color primaryColor;
  final Color accentColor;
  final Color lightColor;
  final Color borderColor;
  final Color badgeColor;
  final String headerIcon;

  const _GeJuGroupCard({
    required this.title,
    required this.count,
    required this.results,
    required this.primaryColor,
    required this.accentColor,
    required this.lightColor,
    required this.borderColor,
    required this.badgeColor,
    required this.headerIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(color: borderColor.withOpacity(0.45), width: 1),
      ),
      color: lightColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ──
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: primaryColor,
              // 顶部细线
              border: Border(
                top: BorderSide(color: _GeJuColors.gold, width: 1.5),
              ),
            ),
            child: Row(
              children: [
                Text(headerIcon,
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        fontWeight: FontWeight.w300)),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          // ── Body ──
          if (results.isEmpty)
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
              child: Text(
                count == 0 ? '本命盘中无此类格局' : '加载中…',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12,
                    color: primaryColor.withOpacity(0.5),
                    letterSpacing: 0.5),
              ),
            )
          else
            ...results.asMap().entries.map((entry) {
              final idx = entry.key;
              final result = entry.value;
              return Column(
                children: [
                  if (idx > 0)
                    Divider(
                      height: 1,
                      thickness: 0.5,
                      color: borderColor.withOpacity(0.25),
                      indent: 10,
                      endIndent: 10,
                    ),
                  _GeJuItemCard(
                    result: result,
                    accentColor: accentColor,
                    primaryColor: primaryColor,
                  ),
                ],
              );
            }),
        ],
      ),
    );
  }
}

// ─── 单条格局 Item ────────────────────────────────────────────────────────────

class _GeJuItemCard extends StatelessWidget {
  final GeJuResult result;
  final Color accentColor;
  final Color primaryColor;

  const _GeJuItemCard({
    required this.result,
    required this.accentColor,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 名称行 ──
          Row(
            children: [
              Expanded(
                child: Text(
                  result.patternName,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              _JiXiongBadge(
                  jiXiong: result.jiXiong, baseColor: accentColor),
            ],
          ),

          // ── 描述 ──
          if (result.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              result.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: _GeJuColors.inkLight,
                height: 1.5,
              ),
            ),
          ],

          // ── 格局类型 + 出处 ──
          const SizedBox(height: 5),
          Row(
            children: [
              _GeJuTypeBadge(
                  type: result.geJuType, baseColor: accentColor),
              const Spacer(),
              if (result.source.isNotEmpty)
                Text(
                  result.source,
                  style: TextStyle(
                    fontSize: 10,
                    color: _GeJuColors.inkFaint,
                    letterSpacing: 0.3,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── 吉凶 Badge ───────────────────────────────────────────────────────────────

class _JiXiongBadge extends StatelessWidget {
  final JiXiongEnum jiXiong;
  final Color baseColor;

  const _JiXiongBadge({required this.jiXiong, required this.baseColor});

  @override
  Widget build(BuildContext context) {
    final label = jiXiong.name; // 中文字符，来自 const JiXiongEnum(this.name)
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          color: Colors.white,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ─── 格局类型 Badge ────────────────────────────────────────────────────────────

class _GeJuTypeBadge extends StatelessWidget {
  final GeJuType type;
  final Color baseColor;

  const _GeJuTypeBadge({required this.type, required this.baseColor});

  static String _label(GeJuType t) {
    switch (t) {
      case GeJuType.gui:
        return '贵';
      case GeJuType.fu:
        return '富';
      case GeJuType.pin:
        return '贫';
      case GeJuType.jian:
        return '贱';
      case GeJuType.yao:
        return '夭';
      case GeJuType.shou:
        return '寿';
      case GeJuType.xian:
        return '贤';
      case GeJuType.yu:
        return '愚';
      case GeJuType.other:
        return '其';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: baseColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: baseColor.withOpacity(0.35), width: 0.7),
      ),
      child: Text(
        _label(type),
        style: TextStyle(
          fontSize: 10,
          color: baseColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
