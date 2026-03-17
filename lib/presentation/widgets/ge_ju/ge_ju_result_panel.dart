import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_result.dart';
import 'package:qizhengsiyu/presentation/viewmodels/qi_zheng_si_yu_viewmodel.dart';

// ─── 调色板（中国风 + 现代感融合）──────────────────────────────────────────────

class _C {
  // 喜格 — 翠绿系
  static const jiBg = Color(0xFFECFDF5);
  static const jiText = Color(0xFF059669);
  static const jiBorder = Color(0xFFD1FAE5);

  // 忌格 — 柔红系
  static const xiongBg = Color(0xFFFFF1F2);
  static const xiongText = Color(0xFFE11D48);
  static const xiongBorder = Color(0xFFFFE4E6);

  // 通用
  static const pageBg = Color(0xFFF8FAFC);
  static const cardBg = Color(0xFFFFFFFF);
  static const textMain = Color(0xFF1E293B);
  static const textMuted = Color(0xFF64748B);
  static const badgeBg = Color(0xFFF1F5F9);
  static const dividerColor = Color(0xFFF1F5F9);
}

// ─── 主入口 Widget ─────────────────────────────────────────────────────────────

/// 命盘格局面板
///
/// 以两个独立卡片显示「政余喜格」和「政余忌格」，格局名以胶囊标签云展示。
/// - [singleColumnMode] 为 true 时两张卡片纵向排列，适合窄屏或详情页
/// - [showDebugBar] 为 true 时在顶部显示调试工具栏（切换优化/经典模式 + 耗时对比）
/// - 默认模式下根据可用宽度自适应（≥720 并排，否则纵向）
class GeJuResultPanel extends StatelessWidget {
  final bool singleColumnMode;
  final bool showDebugBar;

  const GeJuResultPanel({
    super.key,
    this.singleColumnMode = false,
    this.showDebugBar = false,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<GeJuEvaluationSummary?>(
      valueListenable:
          context.read<QiZhengSiYuViewModel>().geJuSummaryNotifier,
      builder: (context, summary, _) {
        if (summary == null) return const SizedBox.shrink();

        final ji = summary.matchedAuspiciousPatterns;
        final xiong = summary.matchedInauspiciousPatterns;

        if (ji.isEmpty && xiong.isEmpty && !showDebugBar) {
          return const SizedBox.shrink();
        }

        return Container(
          color: _C.pageBg,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showDebugBar) _GeJuDebugBar(summary: summary),
              if (ji.isNotEmpty || xiong.isNotEmpty) ...[
                if (showDebugBar) const SizedBox(height: 12),
                singleColumnMode
                    ? _buildSingleColumn(ji, xiong)
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth >= 720) {
                            return _buildRow(ji, xiong);
                          }
                          return _buildSingleColumn(ji, xiong);
                        },
                      ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildRow(List<GeJuResult> ji, List<GeJuResult> xiong) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _GeJuCard(
            title: '政余喜格',
            results: ji,
            tagBg: _C.jiBg,
            tagText: _C.jiText,
            tagBorder: _C.jiBorder,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _GeJuCard(
            title: '政余忌格',
            results: xiong,
            tagBg: _C.xiongBg,
            tagText: _C.xiongText,
            tagBorder: _C.xiongBorder,
          ),
        ),
      ],
    );
  }

  Widget _buildSingleColumn(List<GeJuResult> ji, List<GeJuResult> xiong) {
    return Column(
      children: [
        _GeJuCard(
          title: '政余喜格',
          results: ji,
          tagBg: _C.jiBg,
          tagText: _C.jiText,
          tagBorder: _C.jiBorder,
        ),
        const SizedBox(height: 20),
        _GeJuCard(
          title: '政余忌格',
          results: xiong,
          tagBg: _C.xiongBg,
          tagText: _C.xiongText,
          tagBorder: _C.xiongBorder,
        ),
      ],
    );
  }
}

// ─── Debug 工具栏 ─────────────────────────────────────────────────────────────

class _GeJuDebugBar extends StatelessWidget {
  final GeJuEvaluationSummary summary;

  const _GeJuDebugBar({required this.summary});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<QiZhengSiYuViewModel>();
    final isOptimized = vm.geJuUsePreFilter;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD0D8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 第一行：模式切换按钮 + 标签 ──
          Row(
            children: [
              const Icon(Icons.bug_report, size: 16, color: Color(0xFF6366F1)),
              const SizedBox(width: 6),
              const Text(
                'DEBUG',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF6366F1),
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              _ModeChip(
                label: 'Classic',
                active: !isOptimized,
                onTap: isOptimized ? () => vm.toggleGeJuPreFilter() : null,
              ),
              const SizedBox(width: 6),
              _ModeChip(
                label: 'Optimized',
                active: isOptimized,
                onTap: !isOptimized ? () => vm.toggleGeJuPreFilter() : null,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ── 第二行：统计指标 ──
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              _StatBadge(
                label: 'matched',
                value: '${summary.matchedCount}/${summary.totalCount}',
              ),
              if (summary.evaluationDurationMs != null)
                _StatBadge(
                  label: 'time',
                  value: '${summary.evaluationDurationMs}ms',
                  highlight: true,
                ),
              _StatBadge(
                label: 'preFilter',
                value: '${summary.totalPreFilterRejected}',
              ),
              _StatBadge(
                label: 'noCondition',
                value: '${summary.totalConditionMissing}',
              ),
              if (summary.totalEvaluationErrors > 0)
                _StatBadge(
                  label: 'errors',
                  value: '${summary.totalEvaluationErrors}',
                  highlight: true,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── 模式选择胶囊 ────────────────────────────────────────────────────────────

class _ModeChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback? onTap;

  const _ModeChip({
    required this.label,
    required this.active,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF6366F1) : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: active
                ? const Color(0xFF6366F1)
                : const Color(0xFFB0B8D0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}

// ─── 指标徽章 ─────────────────────────────────────────────────────────────────

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _StatBadge({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
        children: [
          TextSpan(
            text: '$label ',
            style: const TextStyle(color: Color(0xFF9CA3AF)),
          ),
          TextSpan(
            text: value,
            style: TextStyle(
              color: highlight
                  ? const Color(0xFF6366F1)
                  : const Color(0xFF374151),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 格局卡片 ────────────────────────────────────────────────────────────────

class _GeJuCard extends StatelessWidget {
  final String title;
  final List<GeJuResult> results;
  final Color tagBg;
  final Color tagText;
  final Color tagBorder;

  const _GeJuCard({
    required this.title,
    required this.results,
    required this.tagBg,
    required this.tagText,
    required this.tagBorder,
  });

  @override
  Widget build(BuildContext context) {
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
            // ── 标题行：标题 + 数量徽章 ──
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: _C.textMain,
                    letterSpacing: -0.3,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: _C.badgeBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${results.length} 项',
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

            // ── 标签云（Wrap 自适应每行）──
            if (results.isEmpty)
              Text(
                '（无）',
                style: TextStyle(fontSize: 13, color: _C.textMuted),
              )
            else
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: results.map((r) {
                  return _GeJuTag(
                    name: r.patternName,
                    bgColor: tagBg,
                    textColor: tagText,
                    borderColor: tagBorder,
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── 胶囊标签 ────────────────────────────────────────────────────────────────

class _GeJuTag extends StatelessWidget {
  final String name;
  final Color bgColor;
  final Color textColor;
  final Color borderColor;

  const _GeJuTag({
    required this.name,
    required this.bgColor,
    required this.textColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Text(
        name,
        style: TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }
}
